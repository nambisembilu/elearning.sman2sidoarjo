// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/jadwal_pelajaran_model.dart';

class JadwalMapelService {
  final SupabaseClient supabase;

  JadwalMapelService(this.supabase);

  Future<List<JadwalMataPelajaran>> getJadwalMapel({
    required int? tahun_ajaran_id,
    required int? kelas_id,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_jadwal_mapel',
        params: {'p_tahun_ajaran_id': tahun_ajaran_id, 'p_kelas_id': kelas_id},
      );

      print("Data Jadwal Mapel dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => JadwalMataPelajaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getJadwalMapel: $e");
      return [];
    }
  }

  Future<void> deleteJadwalMapel({required int jadwalMapelId}) async {
    try {
      final response = await supabase.rpc(
        'delete_jadwal_pelajaran',
        params: {'p_jadwal_pelajaran_id': jadwalMapelId},
      );

      if (response == null) {
        throw Exception('Failed to delete jadwal mapel');
      }

      print("Response deleteJadwalMapel: $response");
    } catch (e) {
      print("Error deleteJadwalMapel: $e");
      rethrow;
    }
  }

  Future<void> addJadwalMapel({
    required int kelasId,
    required String hari,
    required int guruId,
    required String waktu,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_jadwal_pelajaran',
        params: {
          'p_kelas_id': kelasId,
          'p_hari': hari,
          'p_guru_id': guruId,
          'p_waktu': waktu,
        },
      );

      if (response == null) {
        throw Exception('Failed to add jadwal mapel');
      }

      print("Response addJadwalMapel: $response");
    } catch (e) {
      print("Error addJadwalMapel: $e");
      rethrow;
    }
  }

  Future<void> updateJadwalMapel({
    required int jadwalMapelId,
    required int kelasId,
    required String hari,
    required int guruId,
    required String waktu,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_jadwal_pelajaran',
        params: {
          'p_jadwal_pelajaran_id': jadwalMapelId,
          'p_kelas_id': kelasId,
          'p_hari': hari,
          'p_guru_id': guruId,
          'p_waktu': waktu,
        },
      );

      if (response == null) {
        throw Exception('Failed to update jadwal mapel');
      }

      print("Response updateJadwalMapel: $response");
    } catch (e) {
      print("Error updateJadwalMapel: $e");
      rethrow;
    }
  }
}
