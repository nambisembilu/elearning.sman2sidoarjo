// ignore_for_file: avoid_print

import 'package:elearning_sman2sidoarjo/services/guru/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/komentar_model.dart';

class KomentarService {
  final SupabaseClient supabase;

  KomentarService(this.supabase);

  Future<bool> addKomentarMateri({required String komentar}) async {
    final prefs = await SharedPreferences.getInstance();
    final materiId = prefs.getInt('materiId');
    final userId = prefs.getString('user_id');
    final kelasMapelId = prefs.getInt('kelasMapelId');

    try {
      // 1. insert komentar materi
      final response = await supabase.rpc(
        'add_komentar_materi',
        params: {
          'p_materi_id': materiId,
          'p_user_id': int.parse(userId!),
          'p_komentar': komentar,
        },
      );

      print("Response addKomentarMateri : $response");

      // 2. Ambil daftar penerima notif
      final penerima =
          await supabase.rpc(
                'get_penerima_komentar_materi',
                params: {
                  'p_materi_id': materiId,
                  'p_pengirim_id': int.parse(userId),
                },
              )
              as List<dynamic>;

      // 3. Ambil nama pengirim
      final pengirimData = await supabase
          .from('users')
          .select('nama')
          .eq('id', int.parse(userId))
          .single();

      final pengirimNama = pengirimData['nama'] ?? "Pengguna";

      // 4. Ambil nama materi
      final materiData = await supabase
          .from('materi')
          .select('judul')
          .eq('id', materiId!)
          .single();

      final judulMateri = materiData['judul'] ?? '';

      for (var row in penerima) {
        if (row['token'] != null && row['token'].toString().isNotEmpty) {
          await NotificationService(supabase).sendKomentarNotification(
            token: row['token'],
            title: 'Komentar baru pada materi "$judulMateri"',
            body: '$pengirimNama : $komentar',
            route: '/dashboard/siswa/kelas/$kelasMapelId/detail-materi',
            routeGuru: '/dashboard/guru/kelas/$kelasMapelId/detail-materi',
            materiId: materiId.toString(),
            tugasId: '',
            ujianId: '',
            kelasMapelId: kelasMapelId.toString(),
          );
        }
      }
      return true;
    } catch (e) {
      print("Error addKomentarMateri: $e");
      return false;
    }
  }

  Future<KomentarResponse> getKomentarMateri({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final materiId = prefs.getInt('materiId');
    try {
      final response = await supabase.rpc(
        'get_komentar_materi',
        params: {'p_materi_id': materiId, 'p_page': page},
      );

      print('🔍 DEBUG: Response: $response');

      if (response == null) {
        return KomentarResponse(total: 0, data: [], page: page, totalPage: 0);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return KomentarResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return KomentarResponse.fromJson(response);
      }

      // fallback
      return KomentarResponse(total: 0, data: [], page: page, totalPage: 0);
    } catch (e) {
      print("Error getKomentarMateri: $e");
      return KomentarResponse(total: 0, data: [], page: page, totalPage: 0);
    }
  }

  Future<void> deleteKomentarMateri({required int komentarId}) async {
    try {
      final response = await supabase.rpc(
        'delete_komentar_materi',
        params: {'p_komentar_materi_id': komentarId},
      );

      if (response == null) {
        throw Exception('Failed to delete komentar materi');
      }

      print("Response deleteKomentarMateri: $response");
    } catch (e) {
      print("Error deleteKomentarMateri: $e");
      rethrow;
    }
  }
}
