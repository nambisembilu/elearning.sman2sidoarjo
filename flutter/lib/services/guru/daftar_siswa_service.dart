// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/siswa_kelas_mapel_model.dart';

class SiswaKelasService {
  final SupabaseClient supabase;

  SiswaKelasService(this.supabase);

  Future<SiswaKelasResponse> getSiswaKelas({
    int page = 1,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_siswa_kelas_mapel',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_search': search,
        },
      );

      // print("Data tugas kelas dari Supabase: $response");

      if (response == null) {
        return SiswaKelasResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      if (response is String) {
        return SiswaKelasResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return SiswaKelasResponse.fromJson(response);
      }

      return SiswaKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getSiswaKelas: $e");
      return SiswaKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }
}
