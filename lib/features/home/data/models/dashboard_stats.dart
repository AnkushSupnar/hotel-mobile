import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalTables;
  final int freeTables;
  final int activeOrders;
  final int kitchenQueueItems;
  final double todaysSales;
  final int todaysBillCount;
  final List<RecentActivity> recentActivities;

  const DashboardStats({
    this.totalTables = 0,
    this.freeTables = 0,
    this.activeOrders = 0,
    this.kitchenQueueItems = 0,
    this.todaysSales = 0.0,
    this.todaysBillCount = 0,
    this.recentActivities = const [],
  });

  int get occupiedTables => totalTables - freeTables;

  @override
  List<Object?> get props => [
        totalTables,
        freeTables,
        activeOrders,
        kitchenQueueItems,
        todaysSales,
        todaysBillCount,
        recentActivities,
      ];
}

class RecentActivity extends Equatable {
  final String title;
  final String subtitle;
  final String time;
  final ActivityType type;

  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  @override
  List<Object?> get props => [title, subtitle, time, type];
}

enum ActivityType {
  newOrder,
  orderReady,
  billGenerated,
  billPaid,
  tableOccupied,
}
