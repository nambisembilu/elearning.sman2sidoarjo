// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/tahun_ajaran_model.dart';

class TahunAjaran1Service {
  final SupabaseClient supabase;

  TahunAjaran1Service(this.supabase);

  Future<TahunAjaran1Response> getAllTahunAjaran({
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await supabase.rpc(
        'get_all_tahun_ajaran',
        params: {'p_page': page, 'p_search': search},
      );

      print("yang dikirim : $page,$search");
      print("Data kelas dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return TahunAjaran1Response(
          page: page,
          total: 0,
          totalPage: 0,
          data: [],
        );
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return TahunAjaran1Response.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return TahunAjaran1Response.fromJson(response);
      }

      // fallback
      return TahunAjaran1Response(page: page, total: 0, totalPage: 0, data: []);
    } catch (e) {
      print("Error getAllTahunAjaran: $e");
      return TahunAjaran1Response(page: page, total: 0, totalPage: 0, data: []);
    }
  }

  Future<void> addTahunAjaran({
    required String tahunMulai,
    required String tahunSelesai,
    required String tanggalMulaiSmtGanjil,
    required String tanggalMulaiSmtGenap,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_tahun_ajaran',
        params: {
          'p_tahun_ajaran': '$tahunMulai/$tahunSelesai',
          'p_tanggal_mulai_smt_ganjil': tanggalMulaiSmtGanjil,
          'p_tanggal_mulai_smt_genap': tanggalMulaiSmtGenap,
        },
      );

      if (response == null) {
        throw Exception('Failed to add tahun ajaran');
      }

      print("Response addTahunAjaran : $response");
    } catch (e) {
      print("Error addTahunAjaran: $e");
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> deleteTahunAjaran({required int tahun_ajaran_id}) async {
    try {
      final response = await supabase.rpc(
        'delete_tahun_ajaran',
        params: {'p_tahun_ajaran_id': tahun_ajaran_id},
      );

      if (response == null) {
        throw Exception('Failed to deleteTahunAjaran');
      }

      print("Response deleteTahunAjaran: $response");
    } catch (e) {
      print("Error deleteTahunAjaran: $e");
      rethrow; // Rethrow to handle in UI
    }
  }
}
