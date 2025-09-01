import 'package:uuid/uuid.dart';

// Food items with cooking times
enum FoodItem {
  burgerA(name: 'Burger A', cookingTimeSeconds: 10),
  burgerB(name: 'Burger B', cookingTimeSeconds: 15),
  fries(name: 'Fries', cookingTimeSeconds: 8),
  friesB(name: 'FriesB', cookingTimeSeconds: 9),
  chicken(name: 'Chicken', cookingTimeSeconds: 12),
  chickenB(name: 'ChickenB', cookingTimeSeconds: 15),
  fish(name: 'Fish Burger', cookingTimeSeconds: 18),
  nuggets(name: 'Nuggets', cookingTimeSeconds: 6),
  luxuryBurgerSet(name: 'Luxury burger set', cookingTimeSeconds: 55);

  const FoodItem({required this.name, required this.cookingTimeSeconds});
  final String name;
  final int cookingTimeSeconds;
}

// A class representing a customer
class Customer {
  final String id;
  final String name;
  final GuestClass guestClass;

  Customer({
    required this.id,
    required this.name,
    required this.guestClass,
  });

  // Factory constructor for an empty/guest customer.
  factory Customer.vipEmpty() {
    return Customer(
      id: 'guest',
      name: 'Guest',
      guestClass: GuestClass.vip,
    );
  }

  factory Customer.normalEmpty() {
    return Customer(
      id: 'guest',
      name: 'Guest',
      guestClass: GuestClass.normal,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    GuestClass? guestClass,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      guestClass: guestClass ?? this.guestClass,
    );
  }
}

// Guest class for order priority
enum GuestClass {
  vip(displayName: 'VIP', priority: 1),
  normal(displayName: 'Normal', priority: 2);

  final String displayName;
  final int priority;
  const GuestClass({required this.displayName, required this.priority});
}

// Order states
enum OrderState {
  pending('PENDING'),
  cooking('COOKING'),
  complete('COMPLETE');

  const OrderState(this.displayName);
  final String displayName;
}

// Bot states
enum BotState {
  idle('IDLE'),
  cooking('COOKING'),
  off('OFF');

  const BotState(this.displayName);
  final String displayName;
}

// Order model
class Order {
  final String id;
  final FoodItem foodItem;
  final GuestClass guestClass;
  OrderState state;
  final DateTime createdAt;
  DateTime? cookingStartedAt;
  DateTime? completedAt;
  String? assignedBotId;
  Customer? customer;

  Order(
      {required this.id,
      required this.foodItem,
      required this.guestClass,
      this.state = OrderState.pending,
      DateTime? createdAt,
      this.cookingStartedAt,
      this.completedAt,
      this.assignedBotId,
      this.customer})
      : createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    String? id,
    FoodItem? foodItem,
    GuestClass? guestClass,
    OrderState? state,
    DateTime? createdAt,
    DateTime? cookingStartedAt,
    DateTime? completedAt,
    String? assignedBotId,
    Customer? customer,
  }) {
    return Order(
        id: id ?? this.id,
        foodItem: foodItem ?? this.foodItem,
        guestClass: guestClass ?? this.guestClass,
        state: state ?? this.state,
        createdAt: createdAt ?? this.createdAt,
        cookingStartedAt: cookingStartedAt ?? this.cookingStartedAt,
        completedAt: completedAt ?? this.completedAt,
        assignedBotId: assignedBotId ?? this.assignedBotId,
        customer: customer ?? this.customer);
  }

  Duration? get cookingDuration {
    if (cookingStartedAt != null && completedAt != null) {
      return completedAt!.difference(cookingStartedAt!);
    }
    return null;
  }

  @override
  String toString() {
    return 'Order(id: $id, food: ${foodItem.name}, class: ${guestClass.displayName}, state: ${state.displayName})';
  }
}

// Bot model with performance metrics
class Bot {
  final String id;
  BotState state;
  final DateTime createdAt;
  Order? currentOrder;

  // Performance metrics
  int completedOrders;
  Duration totalCookingTime;

  Bot({
    required this.id,
    this.state = BotState.idle,
    DateTime? createdAt,
    this.currentOrder,
    this.completedOrders = 0,
    Duration? totalCookingTime,
  })  : createdAt = createdAt ?? DateTime.now(),
        totalCookingTime = totalCookingTime ?? Duration.zero;

  Bot copyWith({
    String? id,
    BotState? state,
    DateTime? createdAt,
    Order? currentOrder,
    int? completedOrders,
    Duration? totalCookingTime,
    bool clearCurrentOrder = false,
  }) {
    return Bot(
      id: id ?? this.id,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      currentOrder:
          clearCurrentOrder ? null : (currentOrder ?? this.currentOrder),
      completedOrders: completedOrders ?? this.completedOrders,
      totalCookingTime: totalCookingTime ?? this.totalCookingTime,
    );
  }

  double get averageCookingTimeSeconds {
    if (completedOrders == 0) return 0.0;
    return totalCookingTime.inMilliseconds / completedOrders / 1000.0;
  }

  @override
  String toString() {
    return 'Bot(id: $id, state: ${state.displayName}, completed: $completedOrders, avgTime: ${averageCookingTimeSeconds.toStringAsFixed(1)}s)';
  }
}

// System state model
class RestaurantState {
  final List<Customer> customers;
  final List<Order> pendingOrders;
  final List<Order> cookingOrders;
  final List<Order> completedOrders;
  final List<Bot> bots;

  const RestaurantState({
    this.customers = const [],
    this.pendingOrders = const [],
    this.cookingOrders = const [],
    this.completedOrders = const [],
    this.bots = const [],
  });

  RestaurantState copyWith({
    List<Order>? pendingOrders,
    List<Order>? cookingOrders,
    List<Order>? completedOrders,
    List<Bot>? bots,
  }) {
    return RestaurantState(
      pendingOrders: pendingOrders ?? this.pendingOrders,
      cookingOrders: cookingOrders ?? this.cookingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      bots: bots ?? this.bots,
    );
  }

  // Helper getters
  List<Bot> get idleBots =>
      bots.where((bot) => bot.state == BotState.idle).toList();
  List<Bot> get cookingBots =>
      bots.where((bot) => bot.state == BotState.cooking).toList();
  int get totalOrdersCompleted => completedOrders.length;

  @override
  String toString() {
    return 'RestaurantState(pending: ${pendingOrders.length}, cooking: ${cookingOrders.length}, completed: ${completedOrders.length}, bots: ${bots.length})';
  }
}

// Utility class for generating orders
class OrderGenerator {
  static final _uuid = Uuid();

  static Order createOrder({
    required GuestClass guestClass,
    required Customer customer,
    FoodItem? foodItem,
  }) {
    final selectedFood = foodItem;

    return Order(
        id: _uuid.v4(),
        foodItem: selectedFood ?? FoodItem.burgerA,
        guestClass: guestClass,
        customer: customer);
  }
}

// Utility class for generating bots
class BotGenerator {
  static int _counter = 0;

  static Bot createBot() {
    _counter++;
    return Bot(
      id: 'Bot-$_counter',
    );
  }
}
