import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_ujian_sumatif_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/nilai_ujian_sumatif_service.dart';

part 'nilai_ujian_sumatif_riverpod.g.dart';

@riverpod
class NilaiUjianSumatifNotifier extends _$NilaiUjianSumatifNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;
  int? _kelasId;
  String? _tipeUjian;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<NilaiUjianSumatif> lastListNilaiUjian = [];

  @override
  FutureOr<List<NilaiUjianSumatif>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = NilaiUjianSumatifService(Supabase.instance.client);
    final res = await service.getAllNilaiUjianSumatif(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kelasId: _kelasId,
      tipeUjian: _tipeUjian,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastListNilaiUjian = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? semesterId,
    int? kelasId,
    String? tipeUjian,
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _semesterId = semesterId;
    _kelasId = kelasId;
    _tipeUjian = tipeUjian;

    state = const AsyncLoading<List<NilaiUjianSumatif>>().copyWithPrevious(
      state,
    );

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kelasId: _kelasId,
      tipeUjian: _tipeUjian,
      reset: true,
    );
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        semesterId: _semesterId,
        kelasId: _kelasId,
        tipeUjian: _tipeUjian,
        reset: true,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchPreviousPage() async {
    if (_currentPage <= 1) return;
    _currentPage--;
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kelasId: _kelasId,
      tipeUjian: _tipeUjian,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? semesterId,
    required int? kelasId,
    required String? tipeUjian,
  }) async {
    final service = NilaiUjianSumatifService(Supabase.instance.client);

    try {
      final res = await service.getAllNilaiUjianSumatif(
        page: page,
        search: search,
        semesterId: semesterId,
        kelasId: kelasId,
        tipeUjian: tipeUjian,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastListNilaiUjian = res.data;

      state = AsyncData<List<NilaiUjianSumatif>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<NilaiUjianSumatif>>(e, st);
    }
  }

  Future<void> filterNilaiLatsol({
    required int semesterId,
    required int kelasId,
    required String tipeUjian,
  }) async {
    _semesterId = semesterId;
    _kelasId = kelasId;
    _tipeUjian = tipeUjian;

    try {
      await resetAndFetch(
        page: _currentPage,
        search: _lastSearch,
        semesterId: _semesterId,
        kelasId: _kelasId,
        tipeUjian: _tipeUjian,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  // ✅ Fetch semester
  Future<List<Semester>> fetchSemester() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getSemester();
    return res;
  }

  // ✅ Fetch kelas by tahun ajaran
  Future<List<KelasByTahunAjaran>> fetchKelasByTahunAjaran({
    required int tahunAjaranId,
  }) async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getDaftarKelasByTahunAjaran(
      tahunAjaranId: tahunAjaranId,
    );
    return res;
  }

  // ✅ Fetch mapel by kelas
  Future<List<MataPelajaran>> fetchMapelByKelas({required int kelasId}) async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getMapelByKelas(kelasId: kelasId);
    return res;
  }
}
