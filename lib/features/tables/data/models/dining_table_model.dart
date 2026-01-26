class DiningTableModel {
  final int id;
  final String tableName;
  final String section;
  final String status;
  final int? sequence;

  const DiningTableModel({
    required this.id,
    required this.tableName,
    required this.section,
    this.status = 'Available',
    this.sequence,
  });

  factory DiningTableModel.fromJson(Map<String, dynamic> json) {
    return DiningTableModel(
      id: json['tableId'] as int,
      tableName: json['tableName'] as String,
      section: json['section'] as String,
      status: json['status'] as String? ?? 'Available',
      sequence: json['sequence'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': id,
      'tableName': tableName,
      'section': section,
      'status': status,
      'sequence': sequence,
    };
  }

  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isOngoing => status.toLowerCase() == 'ongoing';
  bool get isClosed => status.toLowerCase() == 'close' || status.toLowerCase() == 'closed';
}

class TableSection {
  final String name;
  final List<DiningTableModel> tables;

  const TableSection({
    required this.name,
    required this.tables,
  });
}
