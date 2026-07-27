// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/siswa/filtering_model.dart';
import '../../../../models/siswa/materi_kelas_model.dart';
import '../../../../services/siswa/filter_data_service.dart';
import '../../../../services/siswa/materi_kelas_service.dart';
part 'materi_kelas_riverpod.g.dart';

@riverpod
class MateriKelasRiverpod extends _$MateriKelasRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;
  int? get semesterId => _semesterId;

  List<MateriKelas> materiList = [];

  @override
  FutureOr<List<MateriKelas>> build() async {
    return [];
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    required int semesterId,
  }) async {
    // Validasi semesterId
    if (semesterId <= 0) {
      print("Warning: semesterId is invalid: $semesterId");
      return;
    }

    _semesterId = semesterId;
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<MateriKelas>>().copyWithPrevious(state);
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      reset: true,
      semesterId: _semesterId,
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
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<MateriKelas>> _fetch({
    required int? semesterId,
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = MateriKelasService(Supabase.instance.client);

    try {
      final res = await service.getMateriKelas(
        page: page,
        search: search,
        semesterId: semesterId!,
      );

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;

      if (reset) {
        // Reset data
        materiList = res.data;
      } else {
        // Tambah data ke list yang sudah ada
        materiList.addAll(res.data);
      }

      state = AsyncData<List<MateriKelas>>(materiList);
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<MateriKelas>>(e, st);
      return [];
    }
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<Semester>> fetchSemester() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getSemester();
    return res;
  }

  Future<List<MateriKelas>> getDetailMateri({required int materiId}) async {
    final service = MateriKelasService(Supabase.instance.client);
    try {
      final result = await service.getDetailMateri(materiId: materiId);
      return result;
    } catch (e, st) {
      state = AsyncError<List<MateriKelas>>(e, st);
      rethrow;
    }
  }
}
