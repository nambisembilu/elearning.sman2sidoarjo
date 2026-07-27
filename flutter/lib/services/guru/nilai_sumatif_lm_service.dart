// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/nilai_sumatif_lingkup_materi_model.dart';

class NilaiSumatifLmService {
  final SupabaseClient supabase;

  NilaiSumatifLmService(this.supabase);

  Future<NilaiSumatifLMResponse> getAllNilaiSumatifLM({
    required int? semesterId,
    required int? kmpId,
    int page = 1,
    String search = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      final response = await supabase.rpc(
        'get_nilai_sumatif_lm',
        params: {
          'p_user_id': userId,
          'p_page': page,
          'p_search': search,
          'p_kmp_id': kmpId,
          'p_semester_id': semesterId,
        },
      );

      if (response == null) {
        return NilaiSumatifLMResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return NilaiSumatifLMResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return NilaiSumatifLMResponse.fromJson(response);
      }

      // fallback
      return NilaiSumatifLMResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getAllNilaiSumatifLM: $e");
      return NilaiSumatifLMResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }
}
