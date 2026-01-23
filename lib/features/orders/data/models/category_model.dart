class CategoryModel {
  final int id;
  final String name;
  final bool hasStock;
  final bool isPurchasable;

  const CategoryModel({
    required this.id,
    required this.name,
    this.hasStock = false,
    this.isPurchasable = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['category'] as String,
      hasStock: json['stock'] == 'Y',
      isPurchasable: json['purchase'] == 'Y',
    );
  }
}
