// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/siswa/kelas_siswa_model.dart';

class KelasSiswaService {
  final SupabaseClient supabase;

  KelasSiswaService(this.supabase);

  Future<KelasSiswaResponse> getDaftarKelasSiswa({
    int? tahunAjaranId,
    String search = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    try {
      final response = await supabase.rpc(
        'get_daftar_kelas_siswa',
        params: {
          'p_user_id': userId,
          'p_tahun_ajaran_id': tahunAjaranId,
          'p_search': search,
        },
      );

      print(
        "yang dikirim : user_id ($userId), tahun_ajaran_id ($tahunAjaranId), search : ($search)",
      );
      print("Data kelas dari Supabase: $response");
      print("Tipe data response: ${response.runtimeType}");

      if (response == null) {
        return KelasSiswaResponse(namaKelas: '', total: 0, data: []);
      }

      // kalau return JSON string → decode dulu
      if (response is String) {
        return KelasSiswaResponse.fromRawJson(response);
      }

      // kalau supabase SDK sudah auto-decode jadi Map
      if (response is Map<String, dynamic>) {
        return KelasSiswaResponse.fromJson(response);
      }

      // fallback
      return KelasSiswaResponse(namaKelas: '', total: 0, data: []);
    } catch (e) {
      print("Error getDaftarKelasSiswa: $e");
      return KelasSiswaResponse(namaKelas: '', total: 0, data: []);
    }
  }
}
