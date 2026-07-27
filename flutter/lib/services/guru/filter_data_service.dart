// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/guru/filtering_model.dart';
import '../../models/guru/kelas_aktif_model.dart';

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

  Future<List<MataPelajaran>> getMapelByKelas({required int kelasId}) async {
    try {
      final response = await supabase.rpc(
        'get_mapel_by_kelas',
        params: {"p_kelas_id": kelasId},
      );

      print("Data getMapelByKelas dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MataPelajaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getMapelByKelas: $e");
      return [];
    }
  }

  Future<List<KelasMapelGuru>> getKelasMapelGuru({
    required int tahunAjaranId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      final response = await supabase.rpc(
        'get_filter_kmp_guru',
        params: {"p_user_id": userId, "p_tahun_ajaran_id": tahunAjaranId},
      );

      print("Data getKelasMapelGuru dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => KelasMapelGuru.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getKelasMapelGuru: $e");
      return [];
    }
  }

  Future<List<LingkupMateri>> getLingkupMateri() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_lingkup_materi',
        params: {"p_kmp_id": kelasMapelId},
      );

      print("Data getLingkupMateri dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => LingkupMateri.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getLingkupMateri: $e");
      return [];
    }
  }

  Future<List<LingkupMateri>> getLingkupMateriUjianSumatifLM() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      final response = await supabase.rpc(
        'get_lingkup_materi_ujian_sumatif_lm',
        params: {"p_kmp_id": kelasMapelId},
      );

      print("Data getLingkupMateriUjianSumatifLM dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => LingkupMateri.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getLingkupMateriUjianSumatifLM: $e");
      return [];
    }
  }

  Future<List<MataPelajaran>> getMapelDiampu() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');

      final response = await supabase.rpc(
        'get_mapel_diampu',
        params: {"p_user_id": userId},
      );

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => MataPelajaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getMapelDiampu: $e");
      return [];
    }
  }
}
