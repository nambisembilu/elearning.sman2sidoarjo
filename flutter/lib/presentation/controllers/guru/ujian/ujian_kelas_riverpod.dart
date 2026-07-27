// ignore_for_file: avoid_print
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/jawaban_ujian_model.dart';
import '../../../../models/guru/soal_ujian_model.dart';
import '../../../../models/guru/soal_ujian_siswa.dart';
import '../../../../models/guru/ujian_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/ujian_service.dart';

part 'ujian_kelas_riverpod.g.dart';

@riverpod
class UjianKelasRiverpod extends _$UjianKelasRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;
  String? _tipeUjian;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;
  int? get semesterId => _semesterId;
  String? get tipeUjian => _tipeUjian;

  List<UjianKelas> ujianList = [];

  @override
  FutureOr<List<UjianKelas>> build() async {
    return [];
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    required int semesterId,
    required String tipeUjian,
  }) async {
    // Validasi semesterId
    if (semesterId <= 0) {
      print("Warning: semesterId is invalid: $semesterId");
      return;
    }

    if (tipeUjian.isEmpty) {
      print("Warning: tipeUjian is invalid: $tipeUjian");
      return;
    }

    _semesterId = semesterId;
    _tipeUjian = tipeUjian;
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<UjianKelas>>().copyWithPrevious(state);
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      reset: true,
      semesterId: _semesterId,
      tipeUjian: _tipeUjian,
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: false,
        semesterId: _semesterId,
        tipeUjian: _tipeUjian,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<UjianKelas>> _fetch({
    required int? semesterId,
    required String? tipeUjian,
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = UjianService(Supabase.instance.client);

    try {
      final res = await service.getUjianKelas(
        page: page,
        search: search,
        semesterId: semesterId!,
        tipeUjian: tipeUjian!,
      );

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;

      if (reset) {
        // Reset data
        ujianList = res.data;
      } else {
        // Tambah data ke list yang sudah ada
        ujianList.addAll(res.data);
      }

      state = AsyncData<List<UjianKelas>>(ujianList);
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<UjianKelas>>(e, st);
      return [];
    }
  }

  Future<bool> addUjian({
    required String tipeUjian,
    required String deskripsi,
    required String tanggalUjian,
    required String jamMulai,
    required String jamSelesai,
    required String statusNilai,
    required String statusKonten,
    required List<SoalUjian> soalUjian,
  }) async {
    final service = UjianService(Supabase.instance.client);
    try {
      await service.addUjianSTSorSAS(
        tipeUjian: tipeUjian,
        deskripsi: deskripsi,
        tanggalUjian: tanggalUjian,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
        statusNilai: statusNilai,
        statusKonten: statusKonten,
        soalUjian: soalUjian,
      );

      _currentPage = 1;
      await _fetch(
        reset: true,
        semesterId: _semesterId,
        tipeUjian: _tipeUjian,
        page: 1,
        search: '',
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<UjianKelas>>(e, st);
      return false;
    }
  }

  Future<bool> addUjianSumatifLm({
    required int tujuanPembelajaranId,
    required String tipeUjian,
    required String deskripsi,
    required String tanggalUjian,
    required String jamMulai,
    required String jamSelesai,
    required String statusNilai,
    required String statusKonten,
    required List<SoalUjian> soalUjian,
  }) async {
    final service = UjianService(Supabase.instance.client);
    try {
      await service.addUjianSumatifLM(
        tujuanPemebelajaranId: tujuanPembelajaranId,
        tipeUjian: tipeUjian,
        deskripsi: deskripsi,
        tanggalUjian: tanggalUjian,
        jamMulai: jamMulai,
        jamSelesai: jamSelesai,
        statusNilai: statusNilai,
        statusKonten: statusKonten,
        soalUjian: soalUjian,
      );

      _currentPage = 1;
      await _fetch(
        reset: true,
        semesterId: _semesterId,
        tipeUjian: _tipeUjian,
        page: 1,
        search: '',
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<UjianKelas>>(e, st);
      return false;
    }
  }

  Future<bool> updateNilaiJawaban({
    required int jawabanUjianId,
    required double nilaiJawaban,
  }) async {
    final service = UjianService(Supabase.instance.client);

    try {
      final success = await service.updateNilaiJawaban(
        jawabanUjianId: jawabanUjianId,
        nilaiJawaban: nilaiJawaban,
      );

      return success;
    } catch (e, st) {
      state = AsyncError<List<UjianKelas>>(e, st);
      print("❌ Error updateNilaiJawaban Riverpod: $e");
      return false;
    }
  }

  Future<bool> deleteUjian({required int ujianId}) async {
    final service = UjianService(Supabase.instance.client);
    try {
      await service.deleteUjianKelas(ujianId: ujianId);

      _currentPage = 1;
      await _fetch(
        reset: true,
        semesterId: _semesterId,
        tipeUjian: _tipeUjian,
        page: 1,
        search: '',
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<UjianKelas>>(e, st);
      return false;
    }
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<Semester>> fetchSemester() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getSemester();
    return res;
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<SoalUjianSiswa>> fetchSoalUjianSiswa() async {
    final service = UjianService(Supabase.instance.client);
    final res = await service.getSoalUjianSiswa();
    return res;
  }

  // Di ujian_riverpod.dart - tambahkan fungsi ini
  Future<List<JawabanUjianModel>> fetchJawabanUjianSiswa() async {
    final service = UjianService(Supabase.instance.client);
    final res = await service.getJawabanUjianSiswa();
    return res;
  }

  Future<List<LingkupMateri>> fetchLingkupMateri() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getLingkupMateriUjianSumatifLM();
    return res;
  }
}
