// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/siswa/jadwal_mengajar_model.dart';

class JadwalMengajarService {
  final SupabaseClient supabase;

  JadwalMengajarService(this.supabase);

  Future<List<JadwalMataPelajaran>> getJadwalGuru() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      final response = await supabase.rpc(
        'get_jadwal_siswa',
        params: {'p_user_id': userId},
      );

      print("Data Jadwal Siswa dari Supabase: $response");

      if (response == null) return [];

      if (response is List) {
        return response
            .map((e) => JadwalMataPelajaran.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print("Error getJadwalSiswa: $e");
      return [];
    }
  }
}
