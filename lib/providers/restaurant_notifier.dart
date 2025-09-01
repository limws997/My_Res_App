import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/models.dart';

class RestaurantNotifier extends StateNotifier<RestaurantState> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  final Map<String, Timer> _cookingTimers = {};

  RestaurantNotifier() : super(const RestaurantState()) {
    _logger.i('🏪 Restaurant Order Management System Initialized');
  }

  @override
  void dispose() {
    // Cancel all active timers
    for (final timer in _cookingTimers.values) {
      timer.cancel();
    }
    _cookingTimers.clear();
    super.dispose();
  }

// Create a new order and place it in the correct position in the queue.
  void createOrder({
    required Customer customer,
    FoodItem? foodItem,
  }) {
    final order = OrderGenerator.createOrder(
      guestClass: customer.guestClass,
      foodItem: foodItem,
      customer: customer,
    );

    // Create a new list with the new order added
    final updatedPending = [...state.pendingOrders, order];

    // Sort the entire list based on priority and creation time
    updatedPending.sort((a, b) {
      // 1. Compare by GuestClass priority first (VIP comes before Normal)
      final priorityComparison =
          a.guestClass.priority.compareTo(b.guestClass.priority);
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // 2. If priorities are the same, compare by creation time
      return a.createdAt.compareTo(b.createdAt);
    });

    // Update the state with the newly sorted list
    state = state.copyWith(pendingOrders: updatedPending);

    // Log the new order with the correct guest class from the customer
    _logger.i(
        'New ${order.guestClass.displayName} Order Created: ${order.id} - ${order.foodItem.name}');

    // Try to assign to available bot
    _tryAssignOrderToBot();
  }

  // Add new bot to the system
  void addBot() {
    final bot = BotGenerator.createBot();
    final updatedBots = [...state.bots, bot];

    state = state.copyWith(bots: updatedBots);

    _logger.i('🤖 Bot Added: ${bot.id}');

    // Try to assign pending order to this new bot
    _tryAssignOrderToBot();
  }

  // Remove the most recently added bot
  void removeBot() {
    if (state.bots.isEmpty) {
      _logger.e('❌ No bots available to remove');
      return;
    }

    // Get the most recently added bot (last in list)
    final botToRemove = state.bots.last;
    final updatedBots = List<Bot>.from(state.bots)..removeLast();

    // Handle bot removal based on its current state
    if (botToRemove.state == BotState.cooking &&
        botToRemove.currentOrder != null) {
      // Bot is cooking - cancel timer and re-queue order with high priority
      _cancelCookingTimer(botToRemove.currentOrder!.id);

      final interruptedOrder = botToRemove.currentOrder!.copyWith(
        state: OrderState.pending,
        assignedBotId: null,
        cookingStartedAt: null,
      );

      // Remove from cooking orders
      final updatedCookingOrders = state.cookingOrders
          .where((order) => order.id != interruptedOrder.id)
          .toList();

      // Place interrupted order at the very front of pending queue (highest priority)
      final updatedPendingOrders = [interruptedOrder, ...state.pendingOrders];

      state = state.copyWith(
        bots: updatedBots,
        pendingOrders: updatedPendingOrders,
        cookingOrders: updatedCookingOrders,
      );

      _logger.e(
          '🛑 Bot ${botToRemove.id} removed while cooking order ${interruptedOrder.id}. Order re-queued with highest priority.');
    } else {
      // Bot is idle - simple removal
      state = state.copyWith(bots: updatedBots);
      _logger.w('🗑️ Bot ${botToRemove.id} removed (was idle)');
    }

    // Try to assign pending orders to remaining bots
    _tryAssignOrderToBot();
  }

  // Cancel a pending order
  void cancelOrder(String orderId) {
    final orderToCancel = state.pendingOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Order not found in pending queue'),
    );

    final updatedPending =
        state.pendingOrders.where((order) => order.id != orderId).toList();

    state = state.copyWith(pendingOrders: updatedPending);

    _logger.w(
        '🚫 Order Cancelled: ${orderToCancel.id} - ${orderToCancel.foodItem.name}');
  }

  // Try to assign pending orders to available bots
  void _tryAssignOrderToBot() {
    if (state.pendingOrders.isEmpty || state.idleBots.isEmpty) {
      return;
    }

    final nextOrder = state.pendingOrders.first;
    final availableBot = state.idleBots.first;

    // Start cooking the order
    _startCooking(nextOrder, availableBot);
  }

  // Start cooking process
  void _startCooking(Order order, Bot bot) {
    final cookingStartTime = DateTime.now();

    // Update order state
    final updatedOrder = order.copyWith(
      state: OrderState.cooking,
      assignedBotId: bot.id,
      cookingStartedAt: cookingStartTime,
    );

    // Update bot state
    final updatedBot = bot.copyWith(
      state: BotState.cooking,
      currentOrder: updatedOrder,
    );

    // Update state lists
    final updatedPendingOrders =
        state.pendingOrders.where((o) => o.id != order.id).toList();

    final updatedCookingOrders = [...state.cookingOrders, updatedOrder];

    final updatedBots = state.bots.map((b) {
      return b.id == bot.id ? updatedBot : b;
    }).toList();

    state = state.copyWith(
      pendingOrders: updatedPendingOrders,
      cookingOrders: updatedCookingOrders,
      bots: updatedBots,
    );

    _logger.i(
        '👨‍🍳 Bot ${bot.id} started cooking order ${order.id} - ${order.foodItem.name} (ETA: ${order.foodItem.cookingTimeSeconds}s)');

    // Set up cooking timer
    _cookingTimers[order.id] = Timer(
      Duration(seconds: order.foodItem.cookingTimeSeconds),
      () => _completeCooking(order.id),
    );
  }

  // Complete cooking process
  void _completeCooking(String orderId) {
    final cookingOrder = state.cookingOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => throw Exception('Cooking order not found'),
    );

    final assignedBot = state.bots.firstWhere(
      (bot) => bot.id == cookingOrder.assignedBotId,
      orElse: () => throw Exception('Assigned bot not found'),
    );

    final completionTime = DateTime.now();
    final cookingDuration =
        completionTime.difference(cookingOrder.cookingStartedAt!);

    // Update order to completed
    final completedOrder = cookingOrder.copyWith(
      state: OrderState.complete,
      completedAt: completionTime,
    );

    // Update bot metrics and set back to idle
    final updatedBot = assignedBot.copyWith(
      state: BotState.idle,
      completedOrders: assignedBot.completedOrders + 1,
      totalCookingTime: assignedBot.totalCookingTime + cookingDuration,
      clearCurrentOrder: true,
    );

    // Update state lists
    final updatedCookingOrders =
        state.cookingOrders.where((order) => order.id != orderId).toList();

    final updatedCompletedOrders = [...state.completedOrders, completedOrder];

    final updatedBots = state.bots.map((bot) {
      return bot.id == assignedBot.id ? updatedBot : bot;
    }).toList();

    state = state.copyWith(
      cookingOrders: updatedCookingOrders,
      completedOrders: updatedCompletedOrders,
      bots: updatedBots,
    );

    // Clean up timer
    _cookingTimers.remove(orderId);

    _logger.i(
        '✅ Order ${completedOrder.id} completed by Bot ${assignedBot.id} in ${cookingDuration.inSeconds}s');
    _logger.i(
        '📊 Bot ${assignedBot.id} stats: ${updatedBot.completedOrders} orders, avg ${updatedBot.averageCookingTimeSeconds.toStringAsFixed(1)}s');

    // Try to assign next pending order to this now-idle bot
    _tryAssignOrderToBot();
  }

  // Cancel cooking timer (used when bot is removed)
  void _cancelCookingTimer(String orderId) {
    final timer = _cookingTimers.remove(orderId);
    timer?.cancel();
  }
}

// Provider for the restaurant state
final restaurantProvider =
    StateNotifierProvider<RestaurantNotifier, RestaurantState>(
  (ref) => RestaurantNotifier(),
);
