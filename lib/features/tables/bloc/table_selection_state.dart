import 'package:equatable/equatable.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

enum TableSelectionStatus { initial, loading, success, failure }

class TableSelectionState extends Equatable {
  final TableSelectionStatus status;
  final List<TableSection> sections;
  final String? selectedSection;
  final DiningTableModel? selectedTable;
  final String? errorMessage;

  const TableSelectionState({
    this.status = TableSelectionStatus.initial,
    this.sections = const [],
    this.selectedSection,
    this.selectedTable,
    this.errorMessage,
  });

  TableSelectionState copyWith({
    TableSelectionStatus? status,
    List<TableSection>? sections,
    String? selectedSection,
    DiningTableModel? selectedTable,
    String? errorMessage,
    bool clearSelectedSection = false,
  }) {
    return TableSelectionState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      selectedSection: clearSelectedSection ? null : (selectedSection ?? this.selectedSection),
      selectedTable: selectedTable ?? this.selectedTable,
      errorMessage: errorMessage,
    );
  }

  List<DiningTableModel> get currentSectionTables {
    if (selectedSection == null) return [];
    final section = sections.firstWhere(
      (s) => s.name == selectedSection,
      orElse: () => const TableSection(name: '', tables: []),
    );
    return section.tables;
  }

  @override
  List<Object?> get props => [status, sections, selectedSection, selectedTable, errorMessage];
}
