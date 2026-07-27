// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/range_nilai_kategori_model.dart';

class RangeNilaiKategoriService {
  final SupabaseClient supabase;

  RangeNilaiKategoriService(this.supabase);

  Future<List<RangeNilaiKategori>> getRangeNilaiKategori() async {
    try {
      final response = await supabase.rpc('get_range_nilai_kategori');

      print("Data get_range_nilai_kategori : $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => RangeNilaiKategori.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getRangeNilaiKategori : $e");
      return [];
    }
  }

  Future<List<RangeNilaiKategori>> addRangeNilaiKategori({
    required String kategori,
    required int nilaiMin,
    required int nilaiMaks,
    required String deskripsi,
  }) async {
    try {
      final response = await supabase.rpc(
        'add_range_nilai_kategori',
        params: {
          'p_kategori': kategori,
          'p_nilai_minimum': nilaiMin,
          'p_nilai_maksimum': nilaiMaks,
          'p_deskripsi': deskripsi,
        },
      );

      print("Data add_range_nilai_kategori : $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => RangeNilaiKategori.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error addRangeNilaiKategori : $e");
      return [];
    }
  }

  Future<List<RangeNilaiKategori>> deleteRangeNilaiKategori({
    required int kategoriNilaiId,
  }) async {
    try {
      final response = await supabase.rpc(
        'delete_range_nilai_kategori',
        params: {'p_id_kategori_nilai': kategoriNilaiId},
      );

      print("Data delete_range_nilai_kategori : $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => RangeNilaiKategori.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error deleteRangeNilaiKategori : $e");
      return [];
    }
  }
}
