import 'package:equatable/equatable.dart';

abstract class TableSelectionEvent extends Equatable {
  const TableSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTables extends TableSelectionEvent {
  const LoadTables();
}

class SelectSection extends TableSelectionEvent {
  final String? section;

  const SelectSection(this.section);

  @override
  List<Object?> get props => [section];
}

class SelectTable extends TableSelectionEvent {
  final int tableId;

  const SelectTable(this.tableId);

  @override
  List<Object?> get props => [tableId];
}
