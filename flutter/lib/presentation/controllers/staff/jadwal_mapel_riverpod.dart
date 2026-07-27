import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/filtering_model.dart';
import '../../../models/staff/jadwal_pelajaran_model.dart';
import '../../../services/staff/filter_data_service.dart';
import '../../../services/staff/jadwal_mapel_service.dart';

part 'jadwal_mapel_riverpod.g.dart';

@riverpod
class JadwalMapelRiverpod extends _$JadwalMapelRiverpod {
  // ✅ Filter terakhir dipakai
  int? lastFilterTahunAjaran;
  int? lastFilterKelas;

  List<JadwalMataPelajaran> lastJadwalMapel = [];

  @override
  FutureOr<List<JadwalMataPelajaran>> build() async {
    return lastJadwalMapel;
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<TahunAjaran>> fetchTahunAjaran() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getTahunAjaran();
    return res;
  }

  // ✅ Fetch daftar kelas by tahun ajaran
  Future<List<KelasByTahunAjaran>> fetchKelasByTahunAjaran(
    int tahunAjaranId,
  ) async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getDaftarKelasByTahunAjaran(
      tahunAjaranId: tahunAjaranId,
    );
    return res;
  }

  // ✅ Fetch jadwal mapel dengan filter
  Future<void> fetchJadwalMapel({
    required int? tahun_ajaran_id,
    required int? kelas_id,
  }) async {
    state = const AsyncLoading<List<JadwalMataPelajaran>>().copyWithPrevious(
      state,
    );

    try {
      final service = JadwalMapelService(Supabase.instance.client);
      final res = await service.getJadwalMapel(
        tahun_ajaran_id: tahun_ajaran_id,
        kelas_id: kelas_id,
      );

      // simpan filter terakhir
      lastFilterTahunAjaran = tahun_ajaran_id;
      lastFilterKelas = kelas_id;
      lastJadwalMapel = res;

      state = AsyncData(res);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> resetAndFetch({
    required int? tahun_ajaran_id,
    required int? kelas_id,
  }) async {
    reset();
    if (tahun_ajaran_id != null && kelas_id != null) {
      await fetchJadwalMapel(
        tahun_ajaran_id: tahun_ajaran_id,
        kelas_id: kelas_id,
      );
    }
  }

  Future<bool> addJadwalPelajaran({
    required int kelasId,
    required String hari,
    required int guruId,
    required String waktu,
  }) async {
    final service = JadwalMapelService(Supabase.instance.client);

    try {
      await service.addJadwalMapel(
        kelasId: kelasId,
        hari: hari,
        guruId: guruId,
        waktu: waktu,
      );

      lastFilterKelas = kelasId;

      // Refresh list siswa setelah tambah
      await resetAndFetch(
        tahun_ajaran_id: lastFilterTahunAjaran,
        kelas_id: lastFilterKelas,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalMataPelajaran>>(e, st);
      return false;
    }
  }

  Future<bool> updateJadwalPelajaran({
    required int jadwalMapelId,
    required int kelasId,
    required String hari,
    required int guruId,
    required String waktu,
  }) async {
    final service = JadwalMapelService(Supabase.instance.client);

    try {
      await service.updateJadwalMapel(
        jadwalMapelId: jadwalMapelId,
        kelasId: kelasId,
        hari: hari,
        guruId: guruId,
        waktu: waktu,
      );

      // Refresh list siswa setelah tambah
      await resetAndFetch(
        tahun_ajaran_id: lastFilterTahunAjaran,
        kelas_id: lastFilterKelas,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalMataPelajaran>>(e, st);
      return false;
    }
  }

  Future<bool> deleteJadwalAkademik({required int jadwalMapelId}) async {
    final service = JadwalMapelService(Supabase.instance.client);

    try {
      await service.deleteJadwalMapel(jadwalMapelId: jadwalMapelId);

      // Refresh list siswa setelah tambah
      await resetAndFetch(
        tahun_ajaran_id: lastFilterTahunAjaran,
        kelas_id: lastFilterKelas,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalMataPelajaran>>(e, st);
      return false;
    }
  }

  // ✅ Reset mapel
  void reset() {
    state = const AsyncData([]);
    lastFilterTahunAjaran = null;
    lastFilterKelas = null;
  }
}
