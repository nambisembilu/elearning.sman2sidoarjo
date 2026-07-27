// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/siswa/materi_kelas_model.dart';

class MateriKelasService {
  final SupabaseClient supabase;

  MateriKelasService(this.supabase);

  Future<MateriKelasResponse> getMateriKelas({
    int page = 1,
    int? semesterId,
    String search = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_materi_kelas',
        params: {
          'p_kelas_mapel_id': kelasMapelId,
          'p_page': page,
          'p_semester_id': semesterId,
          'p_search': search,
        },
      );

      // print("Data materi kelas dari Supabase: $response");

      if (response == null) {
        return MateriKelasResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return MateriKelasResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return MateriKelasResponse.fromJson(response);
      }

      return MateriKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getMateriKelas: $e");
      return MateriKelasResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<List<MateriKelas>> getDetailMateri({required int materiId}) async {
    try {
      final response = await supabase.rpc(
        'get_detail_materi',
        params: {'p_materi_id': materiId},
      );

      if (response == null) {
        throw Exception('Failed to getDetailMateri');
      }

      print("Response getDetailMateri: $response");

      final List<dynamic> data = response as List<dynamic>;
      final List<MateriKelas> materiList = data
          .map((e) => MateriKelas.fromJson(e as Map<String, dynamic>))
          .toList();

      return materiList;
    } catch (e) {
      print("Error getDetailMateri: $e");
      rethrow;
    }
  }
}
