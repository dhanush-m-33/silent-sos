import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  String password; // stored as plain text for now (hash in production)

  @HiveField(5)
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  /// Returns a copy with updated fields
  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, phone: $phone, email: $email)';
}
