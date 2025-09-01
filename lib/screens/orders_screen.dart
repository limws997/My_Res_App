import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/restaurant_notifier.dart';
import '../widgets/custom_app_bar.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Orders Management',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.red.shade50,
              child: TabBar(
                labelColor: Colors.red.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.red.shade700,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.hourglass_empty),
                    text: 'Pending (${restaurantState.pendingOrders.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.local_fire_department),
                    text: 'Cooking (${restaurantState.cookingOrders.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.check_circle),
                    text:
                        'Complete (${restaurantState.completedOrders.length})',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OrdersList(
                    orders: restaurantState.pendingOrders,
                    state: OrderState.pending,
                    emptyMessage: 'No pending orders',
                    emptyIcon: Icons.inbox_outlined,
                  ),
                  _OrdersList(
                    orders: restaurantState.cookingOrders,
                    state: OrderState.cooking,
                    emptyMessage: 'No orders being cooked',
                    emptyIcon: Icons.local_fire_department_outlined,
                  ),
                  _OrdersList(
                    orders: restaurantState.completedOrders,
                    state: OrderState.complete,
                    emptyMessage: 'No completed orders yet',
                    emptyIcon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final List<Order> orders;
  final OrderState state;
  final String emptyMessage;
  final IconData emptyIcon;

  const _OrdersList({
    required this.orders,
    required this.state,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order, index: index + 1);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final int index;

  const _OrderCard({
    required this.order,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantNotifier = ref.read(restaurantProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getStateColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStateColor()),
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStateColor().shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.foodItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (order.guestClass == GuestClass.vip)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,
                                      size: 12, color: Colors.white),
                                  SizedBox(width: 2),
                                  Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(
                        'ID: ${order.id.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(order: order),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.people,
                    label: 'Customer Name',
                    value: '${order.customer?.name}s',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Cooking Time',
                    value: '${order.foodItem.cookingTimeSeconds}s',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.schedule,
                    label: 'Created',
                    value: _formatDateTime(order.createdAt),
                  ),
                  if (order.cookingStartedAt != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.play_arrow,
                      label: 'Cooking Started',
                      value: _formatDateTime(order.cookingStartedAt!),
                    ),
                  ],
                  if (order.completedAt != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.check,
                      label: 'Completed',
                      value: _formatDateTime(order.completedAt!),
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.timer,
                      label: 'Actual Duration',
                      value: '${order.cookingDuration?.inSeconds ?? 0}s',
                    ),
                  ],
                  if (order.assignedBotId != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.smart_toy,
                      label: 'Assigned Bot',
                      value: order.assignedBotId!,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            if (order.state == OrderState.pending) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showCancelConfirmation(context, restaurantNotifier),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  MaterialColor _getStateColor() {
    switch (order.state) {
      case OrderState.pending:
        return Colors.orange;
      case OrderState.cooking:
        return Colors.blue;
      case OrderState.complete:
        return Colors.green;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showCancelConfirmation(
      BuildContext context, RestaurantNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Are you sure you want to cancel this order?\n\n${order.foodItem.name} (${order.customer?.name})\n${order.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.cancelOrder(order.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Order order;

  const _StatusChip({required this.order});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (order.state) {
      case OrderState.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case OrderState.cooking:
        color = Colors.blue;
        icon = Icons.local_fire_department;
        break;
      case OrderState.complete:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            order.state.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
