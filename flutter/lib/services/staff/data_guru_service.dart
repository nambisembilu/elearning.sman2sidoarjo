// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/data_guru_model.dart';
import '../../models/staff/mapel_by_jenjang.dart';

class GuruService {
  final SupabaseClient supabase;

  GuruService(this.supabase);

  Future<GuruResponse> getAllGuru({int page = 1, String search = ''}) async {
    try {
      final response = await supabase.rpc(
        'get_all_guru',
        params: {'p_page': page, 'p_search': search},
      );

      // print("Data Guru dari Supabase: $response");
      // print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return GuruResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return GuruResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return GuruResponse.fromJson(response);
      }

      // fallback
      return GuruResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllGuru: $e");
      return GuruResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<List<MapelByJenjang>> getMapelByJenjangJurusan({
    required String jenjang,
    required String jurusan,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_mapel_by_jenjang_jurusan',
        params: {'p_jenjang': jenjang, 'p_jurusan': jurusan},
      );

      print("Data Mapel dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MapelByJenjang.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error : $e");
      return [];
    }
  }

  Future<void> addGuru({
    required String nama,
    required int nipNuptk,
    required String alamat,
    required int nomorTelepon,
    required String email,
    required List<int> idMapel,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_guru',
        params: {
          'p_nip_nuptk': nipNuptk,
          'p_nama': nama,
          'p_email': email,
          'p_no_telp': nomorTelepon,
          'p_alamat': alamat,
          'p_mapel_id': idMapel,
        },
      );

      if (response == null) {
        throw Exception('Failed to add teacher');
      }

      print("Response addGuru: $response");
    } catch (e) {
      print("Error : $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> updateGuru({
    required int userId,
    required String nama,
    required int nipNuptk,
    required String alamat,
    required int nomorTelepon,
    required String email,
    required List<int> idMapel,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_guru',
        params: {
          'p_user_id': userId,
          'p_nip_nuptk': nipNuptk,
          'p_nama': nama,
          'p_email': email,
          'p_no_telp': nomorTelepon,
          'p_alamat': alamat,
          'p_mapel_id': idMapel,
        },
      );

      if (response == null) {
        throw Exception('Failed to update teacher');
      }

      print("Response updateGuru: $response");
    } catch (e) {
      print("Error : $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteGuru({required int userId}) async {
    try {
      final response = await supabase.rpc(
        'delete_guru',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        throw Exception('Failed to delete teacher');
      }

      print("Response deleteGuru: $response");
    } catch (e) {
      print("Error : $e");
      rethrow; // Rethrow to handle in UI
    }
  }
}
