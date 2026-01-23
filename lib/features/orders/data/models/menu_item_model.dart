class MenuItemModel {
  final int id;
  final int categoryId;
  final String itemCode;
  final String itemName;
  final double rate;

  const MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.itemCode,
    required this.itemName,
    required this.rate,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as int,
      categoryId: json['catid'] as int,
      itemCode: json['item_code']?.toString() ?? '',
      itemName: json['item_name'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
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
