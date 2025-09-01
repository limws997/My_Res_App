import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/restaurant_notifier.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/system_overview_card.dart';
import '../widgets/control_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantState = ref.watch(restaurantProvider);
    final restaurantNotifier = ref.read(restaurantProvider.notifier);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Restaurant Control Panel'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // System Overview
            SystemOverviewCard(state: restaurantState),

            const SizedBox(height: 24),

            // Control Panel
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Control Panel',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Order Creation Section
                    _buildSectionTitle(context, 'Order Creation'),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ControlButton(
                            label: 'New Normal \nGuest Order',
                            icon: Icons.add_shopping_cart,
                            color: Colors.blue,
                            onPressed: () => _showOrderCreationDialog(
                              context,
                              GuestClass.normal,
                              restaurantNotifier,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ControlButton(
                            label: 'New VIP \nGuest Order',
                            icon: Icons.star,
                            color: Colors.amber,
                            onPressed: () => _showOrderCreationDialog(
                              context,
                              GuestClass.vip,
                              restaurantNotifier,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ControlButton(
                            label: 'New Customer\nOrder',
                            icon: Icons.new_label,
                            color: Colors.cyan,
                            onPressed: () => _showOrderCreationDialog(
                              context,
                              null,
                              restaurantNotifier,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Bot Management Section
                    _buildSectionTitle(context, 'Bot Management'),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ControlButton(
                            label: '+ Bot',
                            icon: Icons.add_circle,
                            color: Colors.green,
                            onPressed: restaurantNotifier.addBot,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ControlButton(
                            label: '- Bot',
                            icon: Icons.remove_circle,
                            color: Colors.red,
                            onPressed: restaurantState.bots.isEmpty
                                ? null
                                : restaurantNotifier.removeBot,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Order Management Section
                    _buildSectionTitle(context, 'Order Management'),
                    const SizedBox(height: 12),

                    ControlButton(
                      label: 'Cancel Pending Order',
                      icon: Icons.cancel_outlined,
                      color: Colors.orange,
                      onPressed: restaurantState.pendingOrders.isEmpty
                          ? null
                          : () => _showCancelOrderDialog(
                              context, restaurantState, restaurantNotifier),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Navigation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(context, 'View Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _NavigationButton(
                            label: 'Orders',
                            icon: Icons.list_alt,
                            route: '/orders',
                            count: restaurantState.pendingOrders.length +
                                restaurantState.cookingOrders.length +
                                restaurantState.completedOrders.length,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NavigationButton(
                            label: 'Bots',
                            icon: Icons.precision_manufacturing,
                            route: '/bots',
                            count: restaurantState.bots.length,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
        ),
      ],
    );
  }

// A function to show a dialog for creating a new order.
  void _showOrderCreationDialog(
    BuildContext context,
    GuestClass? guestClass,
    RestaurantNotifier notifier,
  ) {
    // Use a StatefulBuilder to manage the state of the dropdowns inside the dialog.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final List<Customer> existingCustomers = [
          Customer(id: 'cust-01', name: 'Soh wyik', guestClass: GuestClass.vip),
          Customer(
              id: 'cust-02', name: 'Izzuddin', guestClass: GuestClass.normal),
          Customer(id: 'cust-03', name: 'Thinaah', guestClass: GuestClass.vip),
          Customer(id: 'cust-04', name: 'Shida', guestClass: GuestClass.normal),
        ];

        Customer? selectedCustomer;
        FoodItem? selectedFoodItem;

        if (guestClass != null) {
          selectedCustomer = guestClass == GuestClass.normal
              ? Customer.normalEmpty()
              : Customer.vipEmpty();
        } else {
          selectedCustomer = existingCustomers.first;
        }

        selectedFoodItem = FoodItem.burgerA; // Default selection

        return StatefulBuilder(
          builder: (context, setState) {
            final dialogTitle = guestClass != null
                ? 'Create ${guestClass.displayName} Guest Order'
                : 'Create Customer Order';

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(dialogTitle)),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (guestClass == null) ...[
                    const Text('Select customer:'),
                    DropdownButton<Customer>(
                      value: selectedCustomer,
                      items: existingCustomers.map((customer) {
                        return DropdownMenuItem<Customer>(
                          value: customer,
                          child: Text(
                              '${customer.name} (${customer.guestClass.displayName})'),
                        );
                      }).toList(),
                      onChanged: (Customer? newValue) {
                        setState(() {
                          selectedCustomer = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Select food item:'),
                  DropdownButton<FoodItem>(
                    value: selectedFoodItem,
                    items: FoodItem.values.map((food) {
                      return DropdownMenuItem<FoodItem>(
                        value: food,
                        child:
                            Text('${food.name} (${food.cookingTimeSeconds}s)'),
                      );
                    }).toList(),
                    onChanged: (FoodItem? newValue) {
                      setState(() {
                        selectedFoodItem = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCustomer != null &&
                          selectedFoodItem != null) {
                        notifier.createOrder(
                            customer: selectedCustomer!,
                            foodItem: selectedFoodItem);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Create Order'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelOrderDialog(
    BuildContext context,
    RestaurantState state,
    RestaurantNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select order to cancel:'),
            const SizedBox(height: 16),
            ...state.pendingOrders.map((order) => ListTile(
                  title: Text(order.foodItem.name),
                  subtitle: Text(
                      '${order.guestClass.displayName} - ${order.id.substring(0, 8)}...'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      notifier.cancelOrder(order.id);
                      Navigator.of(context).pop();
                    },
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  final int? count;

  const _NavigationButton({
    required this.label,
    required this.icon,
    required this.route,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go(route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          if (count != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
