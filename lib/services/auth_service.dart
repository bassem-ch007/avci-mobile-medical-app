import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../database/database_tables.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _sessionUserIdKey = 'current_user_id';

  final AppDatabase _database = AppDatabase.instance;

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final existingUser = await getUserByEmail(email);

    if (existingUser != null) {
      throw Exception('An account already exists with this email');
    }

    final user = UserModel(
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      createdAt: DateTime.now(),
    );

    final id = await _database.insert(DatabaseTables.users, user.toMap());

    final createdUser = user.copyWith(id: id);

    await _saveSession(id);

    return createdUser;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final user = await getUserByEmail(email);

    if (user == null || user.password != password) {
      throw Exception('Invalid email or password');
    }

    await _saveSession(user.id!);

    return user;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final result = await _database.query(
      DatabaseTables.users,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      orderBy: 'id DESC',
    );

    if (result.isEmpty) return null;

    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(int id) async {
    final result = await _database.query(
      DatabaseTables.users,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getCurrentUserFromSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionUserIdKey);

    if (id == null) return null;

    return getUserById(id);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionUserIdKey, userId);
  }
}
