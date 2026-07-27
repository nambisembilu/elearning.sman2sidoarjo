import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/nilai_sumatif_lingkup_materi_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/nilai_sumatif_lm_service.dart';

part 'nilai_sumatif_lm_riverpod.g.dart';

@riverpod
class NilaiSumatifLMNotifier extends _$NilaiSumatifLMNotifier {
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

  List<NilaiSumatifLM> lastListNilaiSumatifLM = [];

  @override
  FutureOr<List<NilaiSumatifLM>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = NilaiSumatifLmService(Supabase.instance.client);
    final res = await service.getAllNilaiSumatifLM(
      page: _currentPage,
      search: _lastSearch,
      semesterId: _semesterId,
      kmpId: _kmpId,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastListNilaiSumatifLM = res.data;

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

    state = const AsyncLoading<List<NilaiSumatifLM>>().copyWithPrevious(state);

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
    final service = NilaiSumatifLmService(Supabase.instance.client);

    try {
      final res = await service.getAllNilaiSumatifLM(
        page: page,
        search: search,
        semesterId: semesterId,
        kmpId: kmpId,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastListNilaiSumatifLM = res.data;

      state = AsyncData<List<NilaiSumatifLM>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<NilaiSumatifLM>>(e, st);
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
}
