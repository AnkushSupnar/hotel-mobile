import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

class RefreshDashboard extends DashboardEvent {
  final Completer<void>? completer;

  RefreshDashboard({this.completer});

  @override
  List<Object?> get props => [];
}
