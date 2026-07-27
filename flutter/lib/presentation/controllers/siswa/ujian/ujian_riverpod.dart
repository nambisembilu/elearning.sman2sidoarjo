// ignore_for_file: avoid_print
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/siswa/detail_ujian_model.dart';
import '../../../../models/siswa/filtering_model.dart';
import '../../../../models/siswa/jawaban_ujian_model.dart';
import '../../../../models/siswa/soal_ujian_siswa.dart';
import '../../../../models/siswa/ujian_model.dart';
import '../../../../services/siswa/filter_data_service.dart';
import '../../../../services/siswa/ujian_service.dart';

part 'ujian_riverpod.g.dart';

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
    String? tipeUjian,
  }) async {
    // Validasi semesterId
    if (semesterId <= 0) {
      print("Warning: semesterId is invalid: $semesterId");
      return;
    }

    // if (tipeUjian.isEmpty) {
    //   print("Warning: tipeUjian is invalid: $tipeUjian");
    //   return;
    // }

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
    String? tipeUjian,
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
        tipeUjian: tipeUjian,
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

  Future<List<DetailUjian>> fetchInfoUjian() async {
    final service = UjianService(Supabase.instance.client);
    final res = await service.getInfoUjian();
    return res;
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

  // Tambahkan di ujian_riverpod.dart
  Future<bool> addJawabanUjian({
    required List<JawabanUjianModel> jawabanUjian,
  }) async {
    final service = UjianService(Supabase.instance.client);
    return await service.addJawabanUjian(jawabanUjian: jawabanUjian);
  }

  // Di ujian_riverpod.dart - tambahkan fungsi ini
  Future<List<JawabanUjianModel>> fetchJawabanUjianSiswa() async {
    final service = UjianService(Supabase.instance.client);
    final res = await service.getJawabanUjianSiswa();
    return res;
  }
}
