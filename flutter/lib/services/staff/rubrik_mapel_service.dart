// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/staff/rubrik_mapel_model.dart';
import '../../models/staff/rubrik_mapel_sementara_model.dart';

class RubrikMapelService {
  final SupabaseClient supabase;

  RubrikMapelService(this.supabase);
  Future<RubrikMapelResponse> getRubrikPembelajaran({
    required int? mapelId,
    int page = 1,
    String search = '',
    required int? tahunAjaranId,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_rubrik_mapel',
        params: {
          'p_mapel_id': mapelId,
          'p_page': page,
          'p_search': search,
          'p_tahun_ajaran_id': tahunAjaranId,
        },
      );

      if (response == null) {
        return RubrikMapelResponse(
          page: page,
          total: 0,
          totalPage: 0,
          userIdKoorMapel: 0,
          koorMapel: '',
          data: [],
        );
      }

      if (response is String) {
        return RubrikMapelResponse.fromRawJson(response);
      }

      if (response is Map<String, dynamic>) {
        return RubrikMapelResponse.fromJson(response);
      }

      return RubrikMapelResponse(
        page: page,
        total: 0,
        totalPage: 0,
        userIdKoorMapel: 0,
        koorMapel: '',
        data: [],
      );
    } catch (e) {
      print("Error getRubrikPembelajaran: $e");
      return RubrikMapelResponse(
        page: page,
        total: 0,
        totalPage: 0,
        userIdKoorMapel: 0,
        koorMapel: '',
        data: [],
      );
    }
  }

  Future<bool> addNewRubrikMapel({required List<RubrikItem> rubrikJson}) async {
    final prefs = await SharedPreferences.getInstance();
    final mapelId = prefs.getInt('mapel_id');

    try {
      final response = await supabase.rpc(
        'add_rubrik_mapel',
        params: {'p_mapel_id': mapelId, 'p_rubrik': rubrikJson},
      );

      print("✅ Response addKelompokBelajar : $response");
      return true;
    } catch (e) {
      print("❌ Error addKelompokBelajar: $e");
      return false;
    }
  }
}
