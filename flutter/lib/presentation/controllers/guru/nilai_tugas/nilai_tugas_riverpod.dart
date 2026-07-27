import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_tugas_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/nilai_tugas_service.dart';

part 'nilai_tugas_riverpod.g.dart';

@riverpod
class NilaiTugasNotifier extends _$NilaiTugasNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;
  int? _kmpId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<NilaiTugas> lastListNilaiTugas = [];

  @override
  FutureOr<List<NilaiTugas>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = NilaiTugasService(Supabase.instance.client);
    final res = await service.getAllNilaiTugas(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kmpId: _kmpId,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastListNilaiTugas = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? semesterId,
    int? kmpId,
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _semesterId = semesterId;
    _kmpId = kmpId;

    state = const AsyncLoading<List<NilaiTugas>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kmpId: _kmpId,
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
        kmpId: _kmpId,
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
      kmpId: _kmpId,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? semesterId,
    required int? kmpId,
  }) async {
    final service = NilaiTugasService(Supabase.instance.client);

    try {
      final res = await service.getAllNilaiTugas(
        page: page,
        search: search,
        semesterId: semesterId,
        kmpId: kmpId,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastListNilaiTugas = res.data;

      state = AsyncData<List<NilaiTugas>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<NilaiTugas>>(e, st);
    }
  }

  Future<void> filterNilaiTugas({
    required int semesterId,
    required int kmpId,
  }) async {
    _semesterId = semesterId;
    _kmpId = kmpId;

    try {
      await resetAndFetch(
        page: _currentPage,
        search: _lastSearch,
        semesterId: _semesterId,
        kmpId: _kmpId,
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

  Future<List<KelasMapelGuru>> fetchKelasMapelGuru({
    required int tahunAjaranId,
  }) async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getKelasMapelGuru(tahunAjaranId: tahunAjaranId);
    return res;
  }

  // // ✅ Fetch kelas by tahun ajaran
  // Future<List<KelasByTahunAjaran>> fetchKelasByTahunAjaran({
  //   required int tahunAjaranId,
  // }) async {
  //   final service = FilteringDataService(Supabase.instance.client);
  //   final res = await service.getDaftarKelasByTahunAjaran(
  //     tahunAjaranId: tahunAjaranId,
  //   );
  //   return res;
  // }

  // // ✅ Fetch mapel by kelas
  // Future<List<MapelByKelas>> fetchMapelByKelas({required int kelasId}) async {
  //   final service = FilteringDataService(Supabase.instance.client);
  //   final res = await service.getMapelByKelas(kelasId: kelasId);
  //   return res;
  // }
}
