import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SyncItemStatus { pending, syncing, completed, failed }

class SyncItemState {
  final String name;
  final IconData icon;
  final Color color;
  final SyncItemStatus status;
  final int itemCount;
  final String? errorMessage;

  const SyncItemState({
    required this.name,
    required this.icon,
    required this.color,
    this.status = SyncItemStatus.pending,
    this.itemCount = 0,
    this.errorMessage,
  });

  SyncItemState copyWith({
    SyncItemStatus? status,
    int? itemCount,
    String? errorMessage,
  }) {
    return SyncItemState(
      name: name,
      icon: icon,
      color: color,
      status: status ?? this.status,
      itemCount: itemCount ?? this.itemCount,
      errorMessage: errorMessage,
    );
  }
}

class SyncDataState extends Equatable {
  final List<SyncItemState> items;
  final bool isSyncing;

  const SyncDataState({
    required this.items,
    this.isSyncing = false,
  });

  int get completedCount =>
      items.where((i) => i.status == SyncItemStatus.completed).length;

  int get failedCount =>
      items.where((i) => i.status == SyncItemStatus.failed).length;

  SyncDataState copyWith({
    List<SyncItemState>? items,
    bool? isSyncing,
  }) {
    return SyncDataState(
      items: items ?? this.items,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [items.map((i) => '${i.name}:${i.status}:${i.itemCount}:${i.errorMessage}').toList(), isSyncing];
}
