class MenuItemModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String itemCode;
  final String itemName;
  final double rate;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    this.categoryName = '',
    required this.itemCode,
    required this.itemName,
    required this.rate,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String? ?? '',
      itemCode: json['itemCode']?.toString() ?? '',
      itemName: json['itemName'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'itemCode': itemCode,
      'itemName': itemName,
      'rate': rate,
    };
  }
}

class OrderItemModel {
  final MenuItemModel item;
  int quantity;

  OrderItemModel({
    required this.item,
    this.quantity = 1,
  });

  double get totalPrice => item.rate * quantity;

  OrderItemModel copyWith({int? quantity}) {
    return OrderItemModel(
      item: item,
      quantity: quantity ?? this.quantity,
    );
  }
}
