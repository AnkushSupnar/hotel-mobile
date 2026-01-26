import 'package:equatable/equatable.dart';

class BankModel extends Equatable {
  final int id;
  final String bankName;
  final String displayName;
  final String ifsc;

  const BankModel({
    required this.id,
    required this.bankName,
    required this.displayName,
    required this.ifsc,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] as int,
      bankName: json['bankName'] as String,
      displayName: json['displayName'] as String,
      ifsc: json['ifsc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'displayName': displayName,
      'ifsc': ifsc,
    };
  }

  @override
  List<Object?> get props => [id, bankName, displayName, ifsc];
}
