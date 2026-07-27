import 'package:shared_preferences/shared_preferences.dart';

import '../enums/role_user_enum.dart';

class SharedPrefHelper {
  static const String _keyRoleUser = 'role_user';
  static const String _keyUserId = 'user_id';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyKelasMapelId = 'kelasMapelId';

  /// ======================
  /// USER ID
  /// ======================
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  /// ======================
  /// ROLES
  /// ======================

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRoleUser, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRoleUser);
  }

  static Future<UserRole?> getRoleEnum() async {
    final roleString = await getRole(); // ambil String
    if (roleString == null) return null;

    return roleString.toUserRole(); // 🔥 convert ke enum
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRoleUser);
  }

  /// ======================
  /// TOKEN
  /// ======================
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// ======================
  /// KELAS MAPEL ID
  /// ======================
  static Future<void> saveKelasMapelId(int kelasMapelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyKelasMapelId, kelasMapelId);
  }

  static Future<int?> getKelasMapelId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyKelasMapelId);
  }

  /// ======================
  /// CLEAR ALL
  /// ======================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
