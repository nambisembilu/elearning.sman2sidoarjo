// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/mata_pelajaran_model.dart';

class MataPelajaranService {
  final SupabaseClient supabase;

  MataPelajaranService(this.supabase);

  Future<MataPelajaranResponse> getAllMataPelajaran({
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_all_mapel_2',
        params: {
          'p_jenjang': jenjang,
          'p_jurusan': jurusan,
          'p_page': page,
          'p_search': search,
        },
      );

      print("yang dikirim : $jenjang,$jurusan,$page,$search");
      print("Data mapel dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return MataPelajaranResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return MataPelajaranResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return MataPelajaranResponse.fromJson(response);
      }

      // fallback
      return MataPelajaranResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getAllMapel: $e");
      return MataPelajaranResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }

  Future<void> addMataPelajaran({
    required String judul,
    required String jenjang,
    required String jurusan,
    required int? userId,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_mata_pelajaran',
        params: {
          'p_judul': judul,
          'p_jenjang': jenjang,
          'p_jurusan': jurusan,
          'p_user_id': userId,
        },
      );

      if (response == null) {
        throw Exception('Failed to add mapel');
      }

      print("Response addMataPelajaran : $response");
    } catch (e) {
      print("Error addMataPelajaran: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> updateMataPelajaran({
    required int mapelId,
    required String judul,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_mata_pelajaran',
        params: {'p_mapel_id': mapelId, 'p_judul': judul},
      );

      if (response == null) {
        throw Exception('Failed to update mapel');
      }

      print("Response updateMataPelajaran : $response");
    } catch (e) {
      print("Error updateMataPelajaran: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteMataPelajaran({required int mapelId}) async {
    try {
      final response = await supabase.rpc(
        'delete_mata_pelajaran',
        params: {'p_mapel_id': mapelId},
      );

      if (response == null) {
        throw Exception('Failed to delete mapel');
      }

      print("Response deleteMataPelajaran: $response");
    } catch (e) {
      print("Error deleteMataPelajaran: $e");
      rethrow; // Rethrow to handle in UI
    }
  }
}
