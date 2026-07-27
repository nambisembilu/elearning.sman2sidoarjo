// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/nilai_akhir_model.dart';

class NilaiAkhirService {
  final SupabaseClient supabase;

  NilaiAkhirService(this.supabase);

  Future<NilaiAkhirResponse> getAllNilaiAkhir({
    required int? semesterId,
    required int? kelasId,
    required int? mapelId,
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_nilai_akhir_new',
        params: {
          'p_page': page,
          'p_search': search,
          'p_kelas_id': kelasId,
          'p_mapel_id': mapelId,
          'p_semester_id': semesterId,
        },
      );

      if (response == null) {
        return NilaiAkhirResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return NilaiAkhirResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return NilaiAkhirResponse.fromJson(response);
      }

      // fallback
      return NilaiAkhirResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllNilaiAkhir: $e");
      return NilaiAkhirResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }
}
