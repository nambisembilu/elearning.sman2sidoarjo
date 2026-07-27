// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/data_siswa_model.dart';

class SiswaService {
  final SupabaseClient supabase;

  SiswaService(this.supabase);

  Future<SiswaResponse> getAllSiswa({
    int? tahun_ajaran_id,
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_all_siswa',
        params: {
          'p_tahun_ajaran_id': tahun_ajaran_id,
          'p_jenjang': jenjang,
          'p_jurusan': jurusan,
          'p_page': page,
          'p_search': search,
        },
      );

      print("yang dikirim : $tahun_ajaran_id,$jenjang,$jurusan,$page,$search");
      print("Data siswa dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return SiswaResponse(page: page, total: 0, totalPage: 0, data: []);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return SiswaResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return SiswaResponse.fromJson(response);
      }

      // fallback
      return SiswaResponse(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllSiswa: $e");
      return SiswaResponse(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<void> addSiswa({
    required int nis,
    required int nisn,
    required String nama,
    required String? jenisKelamin,
    required String? agama,
    required String email,
    required int nomorTelepon,
    required String alamat,
    required int? kelasId,
    String? statusWaliMurid,
    String? namaWaliMurid,
    String? alamatWaliMurid,
    int? noTelpWaliMurid,
  }) async {
    try {
      final params = {
        'p_nis': nis,
        'p_nisn': nisn,
        'p_nama': nama,
        'p_jenis_kelamin': jenisKelamin,
        'p_kelas_id': kelasId,
        'p_alamat': alamat,
        'p_agama': agama,
        'p_no_telp': nomorTelepon,
        'p_email': email,
        'p_nama_walimurid': namaWaliMurid,
        'p_alamat_walimurid': alamatWaliMurid,
        'p_no_telp_walimurid': noTelpWaliMurid,
        'p_status_walimurid': statusWaliMurid,
      };

      // if (namaWaliMurid != null && namaWaliMurid.isNotEmpty) {
      //   params['p_nama_walimurid'] = namaWaliMurid;
      // }
      // if (alamatWaliMurid != null && alamatWaliMurid.isNotEmpty) {
      //   params['p_alamat_walimurid'] = alamatWaliMurid;
      // }
      // if (noTelpWaliMurid != null) {
      //   params['p_no_telp_walimurid'] = noTelpWaliMurid;
      // }
      // if (statusWaliMurid != null && statusWaliMurid.isNotEmpty) {
      //   params['p_status_walimurid'] = statusWaliMurid;
      // }

      final response = await supabase.rpc('add_siswa', params: params);

      if (response == null) {
        throw Exception('Failed to add teacher');
      }

      print("Response addSiswa : $response");
    } catch (e) {
      print("Error addSiswa: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> updateSiswa({
    required int userId,
    required int nis,
    required int nisn,
    required String nama,
    required String? jenisKelamin,
    required String? agama,
    required String email,
    required int nomorTelepon,
    required String alamat,
    required int? kelasId,
    String? statusWaliMurid,
    String? namaWaliMurid,
    String? alamatWaliMurid,
    int? noTelpWaliMurid,
  }) async {
    try {
      final response = await supabase.rpc(
        'update_siswa',
        params: {
          'p_user_id': userId,
          'p_nis': nis,
          'p_nisn': nisn,
          'p_nama': nama,
          'p_jenis_kelamin': jenisKelamin,
          'p_kelas_id': kelasId,
          'p_alamat': alamat,
          'p_agama': agama,
          'p_no_telp': nomorTelepon,
          'p_email': email,
          'p_nama_walimurid': namaWaliMurid,
          'p_alamat_walimurid': alamatWaliMurid,
          'p_no_telp_walimurid': noTelpWaliMurid,
          'p_status_walimurid': statusWaliMurid,
        },
      );

      if (response == null) {
        throw Exception('Failed to update student');
      }

      print("Response updateSiswa : $response");
    } catch (e) {
      print("Error updateSiswa: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteSiswa({required int userId}) async {
    try {
      final response = await supabase.rpc(
        'delete_siswa',
        params: {'p_user_id': userId},
      );

      if (response == null) {
        throw Exception('Failed to delete student');
      }

      print("Response deleteSiswa: $response");
    } catch (e) {
      print("Error deleteSiswa: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<String> importSiswa({
    required List<int> nis,
    required List<int> nisn,
    required List<String> namaSiswa,
    required List<String> jenisKelamin,
    required List<String> namaKelas,
    required List<String> jenjangPendidikan,
    required List<String> jurusan,
    required List<String> alamat,
    required List<String> agama,
    required List<int> noTelp,
    required List<String> email,
  }) async {
    try {
      print('nis : $nis');
      // Kirim data sebagai JSON array yang proper
      final response = await supabase.rpc(
        'import_data_siswa_bulk',
        params: {
          'p_nis': nis,
          'p_nisn': nisn,
          'p_nama': namaSiswa,
          'p_jenis_kelamin': jenisKelamin,
          'p_nama_kelas': namaKelas,
          'p_jenjang_pendidikan': jenjangPendidikan,
          'p_jurusan': jurusan,
          'p_alamat': alamat,
          'p_agama': agama,
          'p_no_telp': noTelp,
          'p_email': email,
        },
      );

      return response.toString();
    } catch (e) {
      print("Error importSiswa: $e");
      rethrow;
    }
  }
}
