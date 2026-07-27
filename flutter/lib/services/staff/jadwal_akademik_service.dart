// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/staff/jadwal_akademik_model.dart';

class JadwalAkademikService {
  final SupabaseClient supabase;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  JadwalAkademikService(this.supabase);

  Future<JadwalAkademikResponse> getJadwalAkademik({
    int? tahun_ajaran_id,
    String bulan = '',
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_jadwal_akademik',
        params: {
          'p_thn_ajaran_id': tahun_ajaran_id,
          'p_bulan': bulan,
          'p_page': page,
          'p_search': search,
        },
      );

      print("yang dikirim : $tahun_ajaran_id,$bulan,$page,$search");
      print("Data siswa dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return JadwalAkademikResponse(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      if (response is String) {
        return JadwalAkademikResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return JadwalAkademikResponse.fromJson(response);
      }

      return JadwalAkademikResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    } catch (e) {
      print("Error getJadwalAkadmeik: $e");
      return JadwalAkademikResponse(
        page: page,
        total: 0,
        totalPage: 0,
        data: [],
      );
    }
  }

  Future<void> addJadwalAkademik({
    required String namaKegiatan,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_jadwal_akademik',
        params: {
          'p_nama_kegiatan': namaKegiatan,
          'p_tgl_mulai': _formatter.format(tanggalMulai),
          'p_tgl_selesai': _formatter.format(tanggalSelesai),
        },
      );

      if (response == null) {
        throw Exception('Failed to add jadwal akademik');
      }

      print("Response addJadwalAkademik : $response");
    } catch (e) {
      print("Error addJadwalAkademik: $e");
      rethrow;
    }
  }

  Future<void> updateJadwalAkademik({
    required int JadwalAkademikId,
    required String namaKegiatan,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_jadwal_akademik',
        params: {
          'p_jadwal_akademik_id': JadwalAkademikId,
          'p_nama_kegiatan': namaKegiatan,
          'p_tanggal_mulai': _formatter.format(tanggalMulai),
          'p_tanggal_selesai': _formatter.format(tanggalSelesai),
        },
      );

      if (response == null) {
        throw Exception('Failed to update jadwal akademik');
      }

      print("Response updateJadwalAkademik : $response");
    } catch (e) {
      print("Error updateJadwalAkademik: $e");
      rethrow;
    }
  }

  Future<void> deleteJadwalAkademik({required int JadwalAkademikId}) async {
    try {
      final response = await supabase.rpc(
        'delete_jadwal_akademik',
        params: {'p_jadwal_akademik_id': JadwalAkademikId},
      );

      if (response == null) {
        throw Exception('Failed to delete jadwal akademik');
      }

      print("Response deleteJadwalAkademik: $response");
    } catch (e) {
      print("Error deleteJadwalAkademik: $e");
      rethrow;
    }
  }
}
