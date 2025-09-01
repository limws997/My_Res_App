import 'package:flutter/material.dart';
import '../models/models.dart';

class SystemOverviewCard extends StatelessWidget {
  final RestaurantState state;

  const SystemOverviewCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                /// Icon
                const SizedBox(width: 8),
                Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status indicators
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'Pending',
                    count: state.pendingOrders.length,
                    color: Colors.orange,
                    icon: Icons.hourglass_empty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Cooking',
                    count: state.cookingOrders.length,
                    color: Colors.blue,
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Complete',
                    count: state.completedOrders.length,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'Bots',
                    count: state.bots.length,
                    color: Colors.purple,
                    icon: Icons.smart_toy,
                    subtitle: '${state.idleBots.length} idle',
                  ),
                ),
              ],
            ),

            if (state.pendingOrders.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Next in Queue:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state.pendingOrders.first.guestClass == GuestClass.vip
                      ? Colors.amber.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        state.pendingOrders.first.guestClass == GuestClass.vip
                            ? Colors.amber.shade200
                            : Colors.blue.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.pendingOrders.first.guestClass == GuestClass.vip
                          ? Icons.star
                          : Icons.person,
                      color:
                          state.pendingOrders.first.guestClass == GuestClass.vip
                              ? Colors.amber.shade700
                              : Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${state.pendingOrders.first.foodItem.name} (${state.pendingOrders.first.guestClass.displayName})',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: state.pendingOrders.first.guestClass ==
                                  GuestClass.vip
                              ? Colors.amber.shade800
                              : Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.pendingOrders.first.foodItem.cookingTimeSeconds}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const _StatusCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.subtitle,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
