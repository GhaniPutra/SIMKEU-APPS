// lib/models/category_model.dart
// Model kategori produk

class CategoryModel {
  final int    id;
  final String name;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id          : json['id'] as int,
        name        : json['name'] as String,
        description : json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id'          : id,
        'name'        : name,
        'description' : description,
      };
}
