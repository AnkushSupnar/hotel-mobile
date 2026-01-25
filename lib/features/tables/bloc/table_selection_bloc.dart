import 'package:flutter_bloc/flutter_bloc.dart';
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
}
