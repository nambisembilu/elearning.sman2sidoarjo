// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/kelas_model.dart';

class KelasService {
  final SupabaseClient supabase;

  KelasService(this.supabase);

  Future<KelasResponse> getAllKelas({
    int? tahun_ajaran_id,
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_all_kelas',
        params: {
          'p_tahun_ajaran_id': tahun_ajaran_id,
          'p_jenjang': jenjang,
          'p_jurusan': jurusan,
          'p_page': page,
          'p_search': search,
        },
      );

      print("yang dikirim : $tahun_ajaran_id,$jenjang,$jurusan,$page,$search");
      print("Data kelas dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return KelasResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return KelasResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return KelasResponse.fromJson(response);
      }

      // fallback
      return KelasResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllKelas: $e");
      return KelasResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<void> addKelas({
    required String jenjang,
    required String jurusan,
    required String gedung,
    required int user_id, //untuk wali kelas
  }) async {
    try {
      final response = await supabase.rpc(
        'add_kelas',
        params: {
          'p_jenjang': jenjang,
          'p_jurusan': jurusan,
          'p_gedung': gedung,
          'p_user_id': user_id,
        },
      );

      if (response == null) {
        throw Exception('Failed to add kelas');
      }

      print("Response addKelas : $response");
    } catch (e) {
      print("Error addKelas: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> updateKelas({
    required int kelas_id,
    required String gedung,
    required int user_id, //untuk wali kelas
  }) async {
    try {
      final response = await supabase.rpc(
        'update_kelas',
        params: {
          'p_kelas_id': kelas_id,
          'p_gedung': gedung,
          'p_user_id': user_id,
        },
      );

      if (response == null) {
        throw Exception('Failed to update kelas');
      }

      print("Response updateKelas : $response");
    } catch (e) {
      print("Error updateKelas: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteKelas({required int kelas_id}) async {
    try {
      final response = await supabase.rpc(
        'delete_kelas',
        params: {'p_kelas_id': kelas_id},
      );

      if (response == null) {
        throw Exception('Failed to delete kelas');
      }

      print("Response deleteKelas: $response");
    } catch (e) {
      print("Error deleteKelas: $e");
      rethrow; // Rethrow to handle in UI
    }
  }
}
