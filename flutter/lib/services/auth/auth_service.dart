// ignore_for_file: avoid_print

import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/helper/shared_pref_helper.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  /// Login dengan NIP/NUPTK/NISN dan password bcrypt
  static Future<Map<String, dynamic>?> loginWithIdentifier(
    String identifier,
    String password,
  ) async {
    try {
      final userRes = await client
          .from('users')
          .select()
          .eq('nip_nuptk_nisn', identifier)
          .filter('deleted_at', 'is', null)
          .maybeSingle();

      if (userRes == null) return null;

      final userId = userRes['id'].toString();
      final storedHash = userRes['password'] as String?;

      if (storedHash == null || !BCrypt.checkpw(password, storedHash)) {
        return null;
      }

      final role = userRes['role'];
      if (role == null) return null;

      // 👉 SIMPAN KE LOCAL VIA HELPER
      await SharedPrefHelper.saveUserId(userId);
      await SharedPrefHelper.saveRole(role.toString());
      await SharedPrefHelper.saveAuthToken('local-login');

      // Simpan token FCM
      // await SupabaseService.saveFcmToken(userId);

      return {'user_id': userId, 'role': role.toString()};
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// Logout user dan clear semua session lokal
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Simpan token FCM user ke kolom token di tabel users
  static Future<void> saveFcmToken(String userId) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      // Update token user
      await client.from('users').update({'token': fcmToken}).eq('id', userId);

      // Listen token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await client.from('users').update({'token': newToken}).eq('id', userId);
      });

      print('FCM token saved for user $userId: $fcmToken');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }
}
