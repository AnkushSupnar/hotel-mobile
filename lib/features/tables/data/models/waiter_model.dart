import 'package:equatable/equatable.dart';

class WaiterModel extends Equatable {
  final int id;
  final String name;
  final String fullName;

  const WaiterModel({
    required this.id,
    required this.name,
    required this.fullName,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
    };
  }

  @override
  List<Object?> get props => [id, name, fullName];
}
