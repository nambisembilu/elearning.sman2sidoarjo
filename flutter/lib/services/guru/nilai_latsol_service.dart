// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/nilai_latsol_model.dart';

class NilaiLatsolService {
  final SupabaseClient supabase;

  NilaiLatsolService(this.supabase);

  Future<NilaiLatsolResponse> getAllNilaiLatsol({
    required int? semesterId,
    required int? kmpId,
    int page = 1,
    String search = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      final response = await supabase.rpc(
        'get_nilai_latihan_soal_kmp',
        params: {
          'p_user_id': userId,
          'p_page': page,
          'p_search': search,
          'p_kmp_id': kmpId,
          'p_semester_id': semesterId,
        },
      );

      if (response == null) {
        return NilaiLatsolResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return NilaiLatsolResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return NilaiLatsolResponse.fromJson(response);
      }

      // fallback
      return NilaiLatsolResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllNilaiLatsol: $e");
      return NilaiLatsolResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }
}
