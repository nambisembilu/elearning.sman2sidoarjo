// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/filtering_model.dart';
import '../../models/staff/kelas_aktif_model.dart';

class FilteringDataService {
  final SupabaseClient supabase;

  FilteringDataService(this.supabase);

  Future<List<KelasAktif>> getKelasAktif() async {
    try {
      final response = await supabase.rpc('get_kelas_aktif');

      print("Data kelas aktif : $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => KelasAktif.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getKelasAktif : $e");
      return [];
    }
  }

  Future<List<MataPelajaran2>> getMapel() async {
    try {
      final response = await supabase.rpc('get_mapel');

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MataPelajaran2.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getMapel: $e");
      return [];
    }
  }

  Future<List<TahunAjaran>> getTahunAjaran() async {
    try {
      final response = await supabase.rpc('get_tahun_ajaran');

      print("Data Tahun Ajaran dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => TahunAjaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getTahunAjaran: $e");
      return [];
    }
  }

  Future<List<KelasByTahunAjaran>> getDaftarKelasByTahunAjaran({
    required int tahunAjaranId,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_daftar_kelas_by_tahun_ajaran',
        params: {'p_tahun_ajaran_id': tahunAjaranId},
      );

      print("Data Daftar Kelas By Tahun Ajaran dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => KelasByTahunAjaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getDaftarKelasByTahunAjaran: $e");
      return [];
    }
  }

  // untuk fitur jadwal mapel
  Future<List<HariTersedia>> getHariTersedia({required int kelasId}) async {
    try {
      final response = await supabase.rpc(
        'get_hari_tersedia_by_kelas',
        params: {'p_kelas_id': kelasId},
      );

      print("Data Hari Tersedia dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => HariTersedia.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getHariTersedia: $e");
      return [];
    }
  }

  Future<List<WaktuTersedia>> getWaktuTersedia({
    required int kelasId,
    required String hari,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_waktu_tersedia',
        params: {'p_kelas_id': kelasId, 'p_hari': hari},
      );

      print("Data Waktu Tersedia dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => WaktuTersedia.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getWaktuTersedia: $e");
      return [];
    }
  }

  Future<List<MapelByKelasHari>> getMapelByKelasHari({
    required int kelasId,
    required String hari,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_mapel_by_kelas_hari',
        params: {'p_kelas_id': kelasId, 'p_hari': hari},
      );

      print("Data mapel by kelas hari dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MapelByKelasHari.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getMapelByKelasHari: $e");
      return [];
    }
  }

  Future<List<FilterGuru>> getGuruTersedia({
    required int mapelId,
    required String hari,
    required String waktu,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_guru_pengampu_tersedia',
        params: {'p_mapel_id': mapelId, 'p_hari': hari, 'p_waktu': waktu},
      );

      print("Data Guru Tersedia dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => FilterGuru.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getGuruTersedia: $e");
      return [];
    }
  }

  Future<List<WalasTersedia>> getWalasTersedia() async {
    try {
      final response = await supabase.rpc('get_daftar_walas_tersedia');

      print("Data getWalasTersedia dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => WalasTersedia.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getWalasTersedia: $e");
      return [];
    }
  }

  Future<List<Semester>> getSemester() async {
    try {
      final response = await supabase.rpc('get_semester');

      print("Data getSemester dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => Semester.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getSemester: $e");
      return [];
    }
  }

  Future<List<MapelByKelas>> getMapelByKelas({required int kelasId}) async {
    try {
      final response = await supabase.rpc(
        'get_mapel_by_kelas',
        params: {"p_kelas_id": kelasId},
      );

      print("Data getMapelByKelas dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MapelByKelas.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getMapelByKelas: $e");
      return [];
    }
  }

  Future<List<FilterGuru>> getGuruNonKoorMapel() async {
    try {
      final response = await supabase.rpc('get_guru_non_koor_mapel');
      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => FilterGuru.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getGuruNonKoorMapel: $e");
      return [];
    }
  }
}
