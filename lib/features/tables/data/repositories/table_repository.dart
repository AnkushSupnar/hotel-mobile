import 'package:hotel/features/tables/data/models/dining_table_model.dart';

class TableRepository {
  // Mock data - will be replaced with API calls later
  Future<List<DiningTableModel>> getTables() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockTables;
  }

  Future<List<TableSection>> getTablesBySection() async {
    final tables = await getTables();
    final Map<String, List<DiningTableModel>> sectionMap = {};

    for (final table in tables) {
      if (!sectionMap.containsKey(table.section)) {
        sectionMap[table.section] = [];
      }
      sectionMap[table.section]!.add(table);
    }

    // Sort sections and tables within sections
    final sortedSections = sectionMap.keys.toList()..sort();

    return sortedSections.map((section) {
      final sectionTables = sectionMap[section]!;
      // Sort tables by extracting number from table name
      sectionTables.sort((a, b) {
        final aNum = int.tryParse(a.tableName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.tableName.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });
      return TableSection(name: section, tables: sectionTables);
    }).toList();
  }

  static final List<DiningTableModel> _mockTables = [
    // Section A
    DiningTableModel(id: 1, tableName: 'A1', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 2, tableName: 'A2', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 3, tableName: 'A3', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 4, tableName: 'A4', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 6, tableName: 'A5', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 7, tableName: 'A6', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 8, tableName: 'A7', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 9, tableName: 'A8', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 10, tableName: 'A9', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 11, tableName: 'A10', section: 'A', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section B
    DiningTableModel(id: 12, tableName: 'B1', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 13, tableName: 'B2', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 14, tableName: 'B3', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 15, tableName: 'B4', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 16, tableName: 'B5', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 17, tableName: 'B6', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 18, tableName: 'B7', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 19, tableName: 'B8', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 20, tableName: 'B9', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 21, tableName: 'B10', section: 'B', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section C
    DiningTableModel(id: 22, tableName: 'C1', section: 'C', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 23, tableName: 'C2', section: 'C', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 24, tableName: 'C3', section: 'C', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 25, tableName: 'C4', section: 'C', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 26, tableName: 'C5', section: 'C', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section D
    DiningTableModel(id: 27, tableName: 'D1', section: 'D', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 28, tableName: 'D2', section: 'D', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 29, tableName: 'D3', section: 'D', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 30, tableName: 'D4', section: 'D', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 31, tableName: 'D5', section: 'D', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section E
    DiningTableModel(id: 32, tableName: 'E1', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 33, tableName: 'E2', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 34, tableName: 'E3', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 35, tableName: 'E4', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 36, tableName: 'E5', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 37, tableName: 'E6', section: 'E', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section G
    DiningTableModel(id: 5, tableName: 'G1', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 38, tableName: 'G2', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 39, tableName: 'G3', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 40, tableName: 'G4', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 41, tableName: 'G5', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 42, tableName: 'G6', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 43, tableName: 'G7', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 44, tableName: 'G8', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 45, tableName: 'G9', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 46, tableName: 'G10', section: 'G', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section V
    DiningTableModel(id: 47, tableName: 'V1', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 48, tableName: 'V2', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 49, tableName: 'V3', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 50, tableName: 'V4', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 51, tableName: 'V5', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 52, tableName: 'V6', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 53, tableName: 'V7', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 54, tableName: 'V8', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 55, tableName: 'V9', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 56, tableName: 'V10', section: 'V', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section P
    DiningTableModel(id: 57, tableName: 'P1', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 58, tableName: 'P2', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 59, tableName: 'P3', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 60, tableName: 'P4', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 61, tableName: 'P5', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 62, tableName: 'P6', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 63, tableName: 'P7', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 64, tableName: 'P8', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 65, tableName: 'P9', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 66, tableName: 'P10', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 67, tableName: 'P11', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 68, tableName: 'P12', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 74, tableName: 'P13', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 75, tableName: 'P14', section: 'P', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section HP
    DiningTableModel(id: 69, tableName: 'HP', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 70, tableName: 'HP1', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 71, tableName: 'HP2', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 72, tableName: 'HP3', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 73, tableName: 'HP4', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 76, tableName: 'HP5', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 77, tableName: 'HP6', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 78, tableName: 'HP7', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 79, tableName: 'HP8', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 80, tableName: 'HP9', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 81, tableName: 'HP10', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 82, tableName: 'HP11', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 83, tableName: 'HP12', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 84, tableName: 'HP13', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 85, tableName: 'HP14', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 86, tableName: 'HP15', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
    DiningTableModel(id: 87, tableName: 'HP16', section: 'HP', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),

    // Section W
    DiningTableModel(id: 88, tableName: 'W1', section: 'W', createdAt: DateTime(2025, 11, 8), updatedAt: DateTime(2025, 11, 8)),
  ];
}
