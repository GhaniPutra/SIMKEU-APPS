// lib/models/user_model.dart
// Model data user yang sedang login

class UserModel {
  final int    id;
  final String name;
  final String email;
  final int storeId;
  final String role;
  final List<String> permissions;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.storeId,
    required this.role,
    required this.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id    : json['id']    as int,
        name  : json['name']  as String,
        email : json['email'] as String,
        storeId: int.tryParse(json['store_id']?.toString() ?? '') ?? 0,
        role: json['role']?.toString() ?? '',
        permissions: (json['permissions'] as List<dynamic>? ?? const [])
            .map((permission) => permission.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id'    : id,
        'name'  : name,
        'email' : email,
        'store_id': storeId,
        'role': role,
        'permissions': permissions,
      };
}
