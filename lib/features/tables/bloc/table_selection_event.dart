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

class RefreshTables extends TableSelectionEvent {
  const RefreshTables();
}

class ToggleFavorite extends TableSelectionEvent {
  final int tableId;

  const ToggleFavorite(this.tableId);

  @override
  List<Object?> get props => [tableId];
}

class LoadFavorites extends TableSelectionEvent {
  const LoadFavorites();
}

class CloseTable extends TableSelectionEvent {
  final int tableId;
  final String tableName;

  const CloseTable(this.tableId, this.tableName);

  @override
  List<Object?> get props => [tableId, tableName];
}

class ClearClosedTablePdf extends TableSelectionEvent {
  const ClearClosedTablePdf();
}
