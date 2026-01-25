import 'package:equatable/equatable.dart';
import 'package:hotel/features/tables/data/models/dining_table_model.dart';

enum TableSelectionStatus { initial, loading, success, failure }

class TableSelectionState extends Equatable {
  final TableSelectionStatus status;
  final List<TableSection> sections;
  final String? selectedSection;
  final DiningTableModel? selectedTable;
  final String? errorMessage;
  final List<int> favoriteTableIds;
  final List<DiningTableModel> favoriteTables;

  // Special section name for favorites
  static const String favoritesSection = 'Favorites';

  const TableSelectionState({
    this.status = TableSelectionStatus.initial,
    this.sections = const [],
    this.selectedSection,
    this.selectedTable,
    this.errorMessage,
    this.favoriteTableIds = const [],
    this.favoriteTables = const [],
  });

  TableSelectionState copyWith({
    TableSelectionStatus? status,
    List<TableSection>? sections,
    String? selectedSection,
    DiningTableModel? selectedTable,
    String? errorMessage,
    bool clearSelectedSection = false,
    List<int>? favoriteTableIds,
    List<DiningTableModel>? favoriteTables,
  }) {
    return TableSelectionState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      selectedSection: clearSelectedSection ? null : (selectedSection ?? this.selectedSection),
      selectedTable: selectedTable ?? this.selectedTable,
      errorMessage: errorMessage,
      favoriteTableIds: favoriteTableIds ?? this.favoriteTableIds,
      favoriteTables: favoriteTables ?? this.favoriteTables,
    );
  }

  List<DiningTableModel> get currentSectionTables {
    if (selectedSection == null) {
      // Show favorites when no section selected
      return favoriteTables;
    }
    if (selectedSection == favoritesSection) {
      return favoriteTables;
    }
    final section = sections.firstWhere(
      (s) => s.name == selectedSection,
      orElse: () => const TableSection(name: '', tables: []),
    );
    return section.tables;
  }

  bool isFavorite(int tableId) {
    return favoriteTableIds.contains(tableId);
  }

  @override
  List<Object?> get props => [
        status,
        sections,
        selectedSection,
        selectedTable,
        errorMessage,
        favoriteTableIds,
        favoriteTables,
      ];
}
