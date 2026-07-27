// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/siswa/detail_ujian_model.dart';
import '../../models/siswa/jawaban_ujian_model.dart';
import '../../models/siswa/soal_ujian_siswa.dart';
import '../../models/siswa/ujian_model.dart';

class UjianService {
  final SupabaseClient supabase;

  UjianService(this.supabase);

  Future<UjianResponse> getUjianKelas({
    required int semesterId,
    String? tipeUjian,
    int page = 1,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_ujian_siswa',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_search': search,
          'p_semester_id': semesterId,
          'p_tipe_ujian': tipeUjian,
          'p_status_ujian': "Visible",
        },
      );

      // print("Data tugas kelas dari Supabase: $response");

      if (response == null) {
        return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      if (response is String) {
        return UjianResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return UjianResponse.fromJson(response);
      }

      return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getUjianKelas: $e");
      return UjianResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<List<DetailUjian>> getInfoUjian() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ujianId = prefs.getInt('ujianId');
      final userId = prefs.getString('user_id');

      final response = await supabase.rpc(
        'get_info_ujian4',
        params: {'p_ujian_id': ujianId, 'p_user_id': int.parse(userId!)},
      );

      print("Data getInfoUjian dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => DetailUjian.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getInfoUjian: $e");
      return [];
    }
  }

  Future<List<SoalUjianSiswa>> getSoalUjianSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ujianId = prefs.getInt('ujianId');

      final response = await supabase.rpc(
        'get_soal_ujian',
        params: {'p_ujian_id': ujianId},
      );

      print("Data getSoalUjianSiswa dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => SoalUjianSiswa.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getSoalUjianSiswa: $e");
      return [];
    }
  }

  Future<bool> addJawabanUjian({
    required List<JawabanUjianModel> jawabanUjian,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final ujianId = prefs.getInt('ujianId');

    try {
      final response = await supabase.rpc(
        'add_jawaban_ujian_new_1',
        params: {
          'p_ujian_id': ujianId,
          'p_user_id': int.parse(userId!),
          'p_jawaban_soal_ujian': jawabanUjian,
        },
      );

      print("✅ Response addJawabanUjian : $response");
      return true;
    } catch (e) {
      print("❌ Error addJawabanUjian: $e");
      return false;
    }
  }

  // Di ujian_service.dart - tambahkan fungsi ini
  Future<List<JawabanUjianModel>> getJawabanUjianSiswa() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ujianId = prefs.getInt('ujianId');
      final userId = prefs.getString('user_id');

      final response = await supabase.rpc(
        'get_jawaban_ujian_siswa', // Anda perlu buat function ini di Supabase
        params: {'p_ujian_id': ujianId, 'p_user_id': int.parse(userId!)},
      );

      print("Data getJawabanUjianSiswa dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => JawabanUjianModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getJawabanUjianSiswa: $e");
      return [];
    }
  }
}
