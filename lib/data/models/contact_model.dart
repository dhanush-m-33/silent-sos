import 'package:hive/hive.dart';

part 'contact_model.g.dart';

@HiveType(typeId: 1)
class ContactModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  DateTime addedAt;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.addedAt,
  });

  /// Returns a copy with updated fields
  ContactModel copyWith({
    String? name,
    String? phone,
  }) {
    return ContactModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addedAt: addedAt,
    );
  }

  @override
  String toString() => 'ContactModel(id: $id, name: $name, phone: $phone)';
}
