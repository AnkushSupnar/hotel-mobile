import 'package:equatable/equatable.dart';

abstract class SyncDataEvent extends Equatable {
  const SyncDataEvent();

  @override
  List<Object?> get props => [];
}

class StartFullSync extends SyncDataEvent {
  const StartFullSync();
}

class RetrySync extends SyncDataEvent {
  final int index;

  const RetrySync(this.index);

  @override
  List<Object?> get props => [index];
}
