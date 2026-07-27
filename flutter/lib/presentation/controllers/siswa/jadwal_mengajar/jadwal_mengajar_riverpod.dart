import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../models/siswa/jadwal_mengajar_model.dart';
import '../../../../services/siswa/jadwal_mengajar_service.dart';

part 'jadwal_mengajar_riverpod.g.dart';

@riverpod
class JadwalMengajarRiverpod extends _$JadwalMengajarRiverpod {
  @override
  FutureOr<List<JadwalMataPelajaran>> build() async {
    // Supaya langsung fetch otomatis saat provider diinisialisasi
    final service = JadwalMengajarService(Supabase.instance.client);
    final res = await service.getJadwalGuru();
    return res;
  }

  // ✅ Fetch ulang jadwal mapel
  Future<void> fetchJadwalMapel() async {
    // Menandai sedang loading tapi tetap mempertahankan data lama
    state = const AsyncLoading<List<JadwalMataPelajaran>>().copyWithPrevious(
      state,
    );

    try {
      final service = JadwalMengajarService(Supabase.instance.client);
      final res = await service.getJadwalGuru();
      state = AsyncData(res);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
