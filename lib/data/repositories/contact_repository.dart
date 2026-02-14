import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact_model.dart';

/// Repository handling all Emergency Contact data operations via Hive.
class ContactRepository {
  static const String _boxName = 'contacts';

  Box<ContactModel> get _box => Hive.box<ContactModel>(_boxName);

  // ─── CREATE ────────────────────────────────────────────────

  /// Adds a new emergency contact.
  Future<void> addContact(ContactModel contact) async {
    await _box.put(contact.id, contact);
  }

  // ─── READ ──────────────────────────────────────────────────

  /// Returns all emergency contacts sorted by name.
  List<ContactModel> getAllContacts() {
    final contacts = _box.values.toList();
    contacts.sort((a, b) => a.name.compareTo(b.name));
    return contacts;
  }

  /// Returns a single contact by ID, or null if not found.
  ContactModel? getContactById(String id) {
    return _box.get(id);
  }

  /// Returns true if a phone number is already saved.
  bool phoneExists(String phone) {
    // Normalize by stripping spaces and dashes for comparison
    final normalized = phone.replaceAll(RegExp(r'[\s\-]'), '');
    return _box.values.any(
      (c) => c.phone.replaceAll(RegExp(r'[\s\-]'), '') == normalized,
    );
  }

  /// Returns the count of saved contacts.
  int get contactCount => _box.length;

  /// Returns true if there are no contacts saved.
  bool get isEmpty => _box.isEmpty;

  /// Returns all phone numbers as a plain list (used for SMS dispatch).
  List<String> getAllPhoneNumbers() {
    return _box.values.map((c) => c.phone).toList();
  }

  // ─── UPDATE ────────────────────────────────────────────────

  /// Updates an existing contact.
  Future<void> updateContact(ContactModel contact) async {
    await _box.put(contact.id, contact);
  }

  // ─── DELETE ────────────────────────────────────────────────

  /// Deletes a contact by ID.
  Future<void> deleteContact(String id) async {
    await _box.delete(id);
  }

  /// Deletes all contacts (used for testing / full reset).
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ─── LISTENABLE ────────────────────────────────────────────

  /// Returns a listenable for reactive UI updates.
  /// Use with ValueListenableBuilder in ContactsScreen.
  ValueListenable<Box<ContactModel>> get listenable => _box.listenable();
}
