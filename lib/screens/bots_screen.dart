import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/restaurant_notifier.dart';
import '../widgets/custom_app_bar.dart';

class BotsScreen extends ConsumerWidget {
  const BotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);
    final restaurantNotifier = ref.read(restaurantProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bots Management',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: restaurantNotifier.addBot,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Bot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: restaurantState.bots.isEmpty
                        ? null
                        : restaurantNotifier.removeBot,
                    icon: const Icon(Icons.remove),
                    label: const Text('Remove Bot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Bots',
                    value: restaurantState.bots.length.toString(),
                    color: Colors.purple,
                    icon: Icons.smart_toy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Idle',
                    value: restaurantState.idleBots.length.toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Cooking',
                    value: restaurantState.cookingBots.length.toString(),
                    color: Colors.orange,
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Orders',
                    value: restaurantState.bots
                        .fold<int>(0, (sum, bot) => sum + bot.completedOrders)
                        .toString(),
                    color: Colors.blue,
                    icon: Icons.analytics,
                  ),
                ),
              ],
            ),
          ),

          // Bots List
          Expanded(
            child: restaurantState.bots.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.precision_manufacturing_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bots available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a bot to start processing orders',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: restaurantState.bots.length,
                    itemBuilder: (context, index) {
                      final bot = restaurantState.bots[index];
                      return _BotCard(bot: bot, index: index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BotCard extends StatelessWidget {
  final Bot bot;
  final int index;

  const _BotCard({
    required this.bot,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStateColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStateColor(), width: 2),
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: _getStateColor().shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bot.id,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created: ${_formatDateTime(bot.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(bot: bot),
              ],
            ),

            const SizedBox(height: 16),

            // Current Task (if cooking)
            if (bot.state == BotState.cooking && bot.currentOrder != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Currently Cooking',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bot.currentOrder!.foodItem.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (bot.currentOrder!.guestClass == GuestClass.vip)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.star, size: 10, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'VIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order ID: ${bot.currentOrder!.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Performance Metrics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Metrics',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricItem(
                          label: 'Orders Completed',
                          value: bot.completedOrders.toString(),
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricItem(
                          label: 'Avg Cooking Time',
                          value: bot.completedOrders > 0
                              ? '${bot.averageCookingTimeSeconds.toStringAsFixed(1)}s'
                              : 'N/A',
                          icon: Icons.timer_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricItem(
                          label: 'Total Cook Time',
                          value: '${bot.totalCookingTime.inSeconds}s',
                          icon: Icons.access_time_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricItem(
                          label: 'Status',
                          value: bot.state.displayName,
                          icon: _getStateIcon(),
                          valueColor: _getStateColor().shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getStateColor() {
    switch (bot.state) {
      case BotState.idle:
        return Colors.green;
      case BotState.cooking:
        return Colors.orange;
      case BotState.off:
        return Colors.grey;
    }
  }

  IconData _getStateIcon() {
    switch (bot.state) {
      case BotState.idle:
        return Icons.check_circle;
      case BotState.cooking:
        return Icons.local_fire_department;
      case BotState.off:
        return Icons.power_off;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final Bot bot;

  const _StatusChip({required this.bot});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (bot.state) {
      case BotState.idle:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case BotState.cooking:
        color = Colors.orange;
        icon = Icons.local_fire_department;
        break;
      case BotState.off:
        color = Colors.grey;
        icon = Icons.power_off;
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
            bot.state.displayName,
            style: TextStyle(
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

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
