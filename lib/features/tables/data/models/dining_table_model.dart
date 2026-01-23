class DiningTableModel {
  final int id;
  final String tableName;
  final String section;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiningTableModel({
    required this.id,
    required this.tableName,
    required this.section,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiningTableModel.fromJson(Map<String, dynamic> json) {
    return DiningTableModel(
      id: json['id'] as int,
      tableName: json['table_name'] as String,
      section: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'description': section,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TableSection {
  final String name;
  final List<DiningTableModel> tables;

  const TableSection({
    required this.name,
    required this.tables,
  });
}
