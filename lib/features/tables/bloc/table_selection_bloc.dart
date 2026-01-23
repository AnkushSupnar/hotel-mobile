import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel/features/tables/bloc/table_selection_event.dart';
import 'package:hotel/features/tables/bloc/table_selection_state.dart';
import 'package:hotel/features/tables/data/repositories/table_repository.dart';

class TableSelectionBloc extends Bloc<TableSelectionEvent, TableSelectionState> {
  final TableRepository _repository;

  TableSelectionBloc({TableRepository? repository})
      : _repository = repository ?? TableRepository(),
        super(const TableSelectionState()) {
    on<LoadTables>(_onLoadTables);
    on<SelectSection>(_onSelectSection);
    on<SelectTable>(_onSelectTable);
  }

  Future<void> _onLoadTables(
    LoadTables event,
    Emitter<TableSelectionState> emit,
  ) async {
    emit(state.copyWith(status: TableSelectionStatus.loading));

    try {
      final sections = await _repository.getTablesBySection();
      emit(state.copyWith(
        status: TableSelectionStatus.success,
        sections: sections,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TableSelectionStatus.failure,
        errorMessage: 'Failed to load tables',
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
    final table = state.currentSectionTables.firstWhere(
      (t) => t.id == event.tableId,
    );
    emit(state.copyWith(selectedTable: table));
  }
}
