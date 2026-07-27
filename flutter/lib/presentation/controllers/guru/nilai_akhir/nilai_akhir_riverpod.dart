import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_akhir_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/nilai_akhir_service.dart';

part 'nilai_akhir_riverpod.g.dart';

@riverpod
class NilaiAkhirNotifier extends _$NilaiAkhirNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;
  int? _kelasId;
  int? _mapelId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<NilaiAkhir> lastListNilaiAkhir = [];
  List<NilaiAkhir> allData = [];

  @override
  FutureOr<List<NilaiAkhir>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = NilaiAkhirService(Supabase.instance.client);
    final res = await service.getAllNilaiAkhir(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kelasId: _kelasId,
      mapelId: _mapelId,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastListNilaiAkhir = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? semesterId,
    int? kelasId,
    int? mapelId,
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _semesterId = semesterId;
    _kelasId = kelasId;
    _mapelId = mapelId;

    state = const AsyncLoading<List<NilaiAkhir>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kelasId: _kelasId,
      mapelId: _mapelId,
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
        mapelId: _mapelId,
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
      mapelId: _mapelId,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? semesterId,
    required int? kelasId,
    required int? mapelId,
  }) async {
    final service = NilaiAkhirService(Supabase.instance.client);

    try {
      final res = await service.getAllNilaiAkhir(
        page: page,
        search: search,
        semesterId: semesterId,
        kelasId: kelasId,
        mapelId: mapelId,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastListNilaiAkhir = res.data;

      state = AsyncData<List<NilaiAkhir>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<NilaiAkhir>>(e, st);
    }
  }

  Future<void> filterNilaiAkhir({
    required int semesterId,
    required int kelasId,
    required int mapelId,
  }) async {
    _semesterId = semesterId;
    _kelasId = kelasId;
    _mapelId = mapelId;

    try {
      await resetAndFetch(
        page: _currentPage,
        search: _lastSearch,
        semesterId: _semesterId,
        kelasId: _kelasId,
        mapelId: _mapelId,
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

  Future<List<NilaiAkhir>> fetchAllPagesWithoutAffectingUI() async {
    final service = NilaiAkhirService(Supabase.instance.client);

    // Loop berdasarkan total page
    for (int page = 1; page <= _totalPage; page++) {
      final res = await service.getAllNilaiAkhir(
        page: page,
        search: '',
        semesterId: _semesterId,
        kelasId: _kelasId,
        mapelId: _mapelId,
      );

      allData.addAll(res.data);
    }

    // Tidak update state
    return allData;
  }
}
