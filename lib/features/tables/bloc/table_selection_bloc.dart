import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/core/services/bill_cache_service.dart';
import 'package:hotel/features/tables/bloc/table_selection_event.dart';
import 'package:hotel/features/tables/bloc/table_selection_state.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';
import 'package:hotel/features/tables/data/repositories/table_repository.dart';

class TableSelectionBloc extends Bloc<TableSelectionEvent, TableSelectionState> {
  final TableRepository _repository;

  TableSelectionBloc({TableRepository? repository})
      : _repository = repository ?? TableRepository(),
        super(const TableSelectionState()) {
    on<LoadTables>(_onLoadTables);
    on<SelectSection>(_onSelectSection);
    on<SelectTable>(_onSelectTable);
    on<RefreshTables>(_onRefreshTables);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<CloseTable>(_onCloseTable);
    on<ClearClosedTablePdf>(_onClearClosedTablePdf);
  }

  Future<void> _onLoadTables(
    LoadTables event,
    Emitter<TableSelectionState> emit,
  ) async {
    emit(state.copyWith(status: TableSelectionStatus.loading));

    try {
      final sections = await _repository.getTablesBySection();
      final favoriteIds = _repository.getFavoriteTableIds();
      final favoriteTables = _repository.getFavoriteTables();

      // Clear cached bills for tables no longer closed
      await _clearStaleBillCaches(sections);

      emit(state.copyWith(
        status: TableSelectionStatus.success,
        sections: sections,
        favoriteTableIds: favoriteIds,
        favoriteTables: favoriteTables,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TableSelectionStatus.failure,
        errorMessage: 'Failed to load tables: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshTables(
    RefreshTables event,
    Emitter<TableSelectionState> emit,
  ) async {
    emit(state.copyWith(status: TableSelectionStatus.loading));

    try {
      final sections = await _repository.getTablesBySection(forceRefresh: true);
      final favoriteIds = _repository.getFavoriteTableIds();
      final favoriteTables = _repository.getFavoriteTables();

      // Clear cached bills for tables no longer closed
      await _clearStaleBillCaches(sections);

      emit(state.copyWith(
        status: TableSelectionStatus.success,
        sections: sections,
        favoriteTableIds: favoriteIds,
        favoriteTables: favoriteTables,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TableSelectionStatus.failure,
        errorMessage: 'Failed to refresh tables: ${e.toString()}',
      ));
    }
  }

  Future<void> _clearStaleBillCaches(List<TableSection> sections) async {
    final closedTableIds = <int>{};
    for (final section in sections) {
      for (final table in section.tables) {
        if (table.isClosed) {
          closedTableIds.add(table.id);
        }
      }
    }
    await BillCacheService.clearStaleBills(closedTableIds);
  }

  void _onSelectSection(
    SelectSection event,
    Emitter<TableSelectionState> emit,
  ) {
    if (event.section == state.selectedSection) {
      // Deselect if same section is tapped
      emit(state.copyWith(clearSelectedSection: true));
    } else {
      emit(state.copyWith(selectedSection: event.section));
    }
  }

  void _onSelectTable(
    SelectTable event,
    Emitter<TableSelectionState> emit,
  ) {
    // Search in current section tables or favorites
    DiningTableModel? table;

    for (final t in state.currentSectionTables) {
      if (t.id == event.tableId) {
        table = t;
        break;
      }
    }

    // If not found in current section, search all sections
    if (table == null) {
      for (final section in state.sections) {
        for (final t in section.tables) {
          if (t.id == event.tableId) {
            table = t;
            break;
          }
        }
        if (table != null) break;
      }
    }

    if (table != null) {
      emit(state.copyWith(selectedTable: table));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<TableSelectionState> emit,
  ) async {
    await _repository.toggleFavorite(event.tableId);
    final favoriteIds = _repository.getFavoriteTableIds();
    final favoriteTables = _repository.getFavoriteTables();

    emit(state.copyWith(
      favoriteTableIds: favoriteIds,
      favoriteTables: favoriteTables,
    ));
  }

  void _onLoadFavorites(
    LoadFavorites event,
    Emitter<TableSelectionState> emit,
  ) {
    final favoriteIds = _repository.getFavoriteTableIds();
    final favoriteTables = _repository.getFavoriteTables();

    emit(state.copyWith(
      favoriteTableIds: favoriteIds,
      favoriteTables: favoriteTables,
    ));
  }

  Future<void> _onCloseTable(
    CloseTable event,
    Emitter<TableSelectionState> emit,
  ) async {
    emit(state.copyWith(closingTableId: event.tableId));

    try {
      final responseData = await _repository.closeTable(event.tableId);

      // Extract PDF base64, billNo, and netAmount from response
      Uint8List? pdfBytes;
      int? billNo;
      double? netAmount;
      String? pdfBase64;
      final data = responseData?['data'];
      if (data is Map<String, dynamic>) {
        pdfBase64 = data['pdfBase64'] as String?;
        if (pdfBase64 != null && pdfBase64.isNotEmpty) {
          pdfBytes = base64Decode(pdfBase64);
        }
        billNo = data['billNo'] as int?;
        final rawNetAmount = data['netAmount'];
        if (rawNetAmount is num) {
          netAmount = rawNetAmount.toDouble();
        }
      }

      // Cache the bill response for re-access until paid or status changes
      if (pdfBase64 != null && billNo != null && netAmount != null) {
        await BillCacheService.cacheBill(
          event.tableId,
          pdfBase64: pdfBase64,
          billNo: billNo,
          netAmount: netAmount,
          tableName: event.tableName,
        );
      }

      // Refresh tables to get updated status from server
      final sections = await _repository.getTablesBySection(forceRefresh: true);
      final favoriteIds = _repository.getFavoriteTableIds();
      final favoriteTables = _repository.getFavoriteTables();

      emit(state.copyWith(
        status: TableSelectionStatus.success,
        sections: sections,
        favoriteTableIds: favoriteIds,
        favoriteTables: favoriteTables,
        clearClosingTableId: true,
        closedTablePdfBytes: pdfBytes,
        closedTableName: event.tableName,
        closedTableBillNo: billNo,
        closedTableNetAmount: netAmount,
        closedTableId: event.tableId,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to close table: ${e.toString()}',
        clearClosingTableId: true,
      ));
    }
  }

  void _onClearClosedTablePdf(
    ClearClosedTablePdf event,
    Emitter<TableSelectionState> emit,
  ) {
    emit(state.copyWith(clearClosedTablePdf: true));
  }
}
