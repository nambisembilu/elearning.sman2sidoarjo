// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/kelompok_belajar_model.dart';
import '../../models/guru/siswa_kelas_mapel_model.dart';

class KelompokBelajarService {
  final SupabaseClient supabase;

  KelompokBelajarService(this.supabase);
  Future<KelompokBelajarResponse> getKelompokBelajar({
    int page = 1,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_kelompok_belajar',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_search': search,
        },
      );

      // print("Data tugas kelas dari Supabase: $response");

      if (response == null) {
        return KelompokBelajarResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return KelompokBelajarResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return KelompokBelajarResponse.fromJson(response);
      }

      return KelompokBelajarResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getKelompokBelajar: $e");
      return KelompokBelajarResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }

  Future<List<SiswaKelas>> getSiswaNonKelompok({String search = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');
    try {
      final response = await supabase.rpc(
        'get_siswa_non_kelompok',
        params: {"p_kmp_id": kelasMapelId, "p_search": search},
      );

      print("Data getSiswaNonKelompok dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => SiswaKelas.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getSiswaNonKelompok: $e");
      return [];
    }
  }

  Future<bool> addKelompokBelajar({required List<int> siswaId}) async {
    final prefs = await SharedPreferences.getInstance();
    final kelasMapelId = prefs.getInt('kelasMapelId');

    try {
      final response = await supabase.rpc(
        'add_kelompok_belajar',
        params: {'p_kelas_mapel_id': kelasMapelId, 'p_siswa_id': siswaId},
      );

      print("✅ Response addKelompokBelajar : $response");
      return true;
    } catch (e) {
      print("❌ Error addKelompokBelajar: $e");
      return false;
    }
  }

  // Update fungsi updateKelompokBelajar untuk menyesuaikan dengan RPC
  Future<bool> updateKelompokBelajar({
    required int kelompokId,
    required List<int> siswaId,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_kelompok_belajar',
        params: {'p_kelompok_belajar_id': kelompokId, 'p_siswa_id': siswaId},
      );

      print("Response updateKelompokBelajar: $response");
      return true;
    } catch (e) {
      print("Error updateKelompokBelajar: $e");
      return false;
    }
  }

  Future<void> deleteKelompokBelajar({required int kelompokId}) async {
    try {
      final response = await supabase.rpc(
        'delete_kelompok_belajar',
        params: {'p_kelompok_belajar_id': kelompokId},
      );

      if (response == null) {
        throw Exception('Failed to delete kelompok');
      }

      print("Response deleteKelompokBelajar: $response");
    } catch (e) {
      print("Error deleteKelompokBelajar: $e");
      rethrow;
    }
  }
}
