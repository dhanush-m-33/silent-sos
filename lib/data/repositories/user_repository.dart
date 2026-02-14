import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

/// Repository handling all User data operations via Hive.
/// Only one user is ever stored (single-user app).
class UserRepository {
  static const String _boxName = 'user';

  Box<UserModel> get _box => Hive.box<UserModel>(_boxName);

  // ─── CREATE ────────────────────────────────────────────────

  /// Saves a new user. Clears any existing user first.
  Future<void> saveUser(UserModel user) async {
    await _box.clear(); // only one user at a time
    await _box.put(user.id, user);
  }

  // ─── READ ──────────────────────────────────────────────────

  /// Returns the stored user, or null if not logged in.
  UserModel? getUser() {
    if (_box.isEmpty) return null;
    return _box.values.first;
  }

  /// Returns true if a user is saved (i.e. logged in).
  bool isLoggedIn() => _box.isNotEmpty;

  /// Checks if an email is already registered.
  bool emailExists(String email) {
    return _box.values.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
  }

  /// Validates login credentials. Returns user on success, null on failure.
  UserModel? validateLogin(String email, String password) {
    try {
      return _box.values.firstWhere(
        (u) =>
            u.email.toLowerCase() == email.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // ─── UPDATE ────────────────────────────────────────────────

  /// Updates the stored user's details.
  Future<void> updateUser(UserModel updatedUser) async {
    await _box.put(updatedUser.id, updatedUser);
  }

  // ─── DELETE ────────────────────────────────────────────────

  /// Logs out — clears user from Hive.
  Future<void> logout() async {
    await _box.clear();
  }
}
