// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/nilai_ujian_sumatif_model.dart';

class NilaiUjianSumatifService {
  final SupabaseClient supabase;

  NilaiUjianSumatifService(this.supabase);

  Future<NilaiUjianSumatifResponse> getAllNilaiUjianSumatif({
    required int? semesterId,
    required int? kelasId,
    required String? tipeUjian,
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_nilai_sts_sas',
        params: {
          'p_page': page,
          'p_search': search,
          'p_kelas_id': kelasId,
          'p_tipe_ujian': tipeUjian,
          'p_semester_id': semesterId,
        },
      );

      if (response == null) {
        return NilaiUjianSumatifResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      print("tes get_nilai_ujian_sumatif : $response");

      // kalau return JSON string → decode dulu
      if (response is String) {
        return NilaiUjianSumatifResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return NilaiUjianSumatifResponse.fromJson(response);
      }

      // fallback
      return NilaiUjianSumatifResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getAllNilaiUjianSumatif: $e");
      return NilaiUjianSumatifResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }
}
