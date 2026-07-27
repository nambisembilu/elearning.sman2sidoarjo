import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/materi_kelas_model.dart';
import '../../../../services/guru/materi_kelas_service.dart';

part 'komentar_riverpod.g.dart';

@riverpod
class KomentarRiverpod extends _$KomentarRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<MateriKelas> lastMateriKelas = [];

  @override
  FutureOr<List<MateriKelas>> build() async {
    return await _fetch(page: _currentPage, search: _lastSearch, reset: true);
  }

  Future<void> resetAndFetch({String search = '', int page = 1}) async {
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<MateriKelas>>().copyWithPrevious(state);
    await _fetch(page: _currentPage, search: _lastSearch, reset: true);
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      await _fetch(page: _currentPage, search: _lastSearch, reset: true);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchPreviousPage() async {
    if (_currentPage <= 1) return;
    _currentPage--;
    await _fetch(page: _currentPage, search: _lastSearch, reset: true);
  }

  Future<List<MateriKelas>> _fetch({
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = MateriKelasService(Supabase.instance.client);

    try {
      final res = await service.getMateriKelas(page: page, search: search);

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastMateriKelas = res.data;

      state = AsyncData<List<MateriKelas>>(res.data);
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<MateriKelas>>(e, st);
      return [];
    }
  }

  Future<bool> updateStatusMateri({
    required int materiId,
    required String statusMateri,
  }) async {
    final service = MateriKelasService(Supabase.instance.client);
    try {
      await service.updateStatusMateriKelas(
        materiId: materiId,
        statusMateri: statusMateri,
      );
      await _fetch(page: _currentPage, search: _lastSearch, reset: true);
      return true;
    } catch (e, st) {
      state = AsyncError<List<MateriKelas>>(e, st);
      return false;
    }
  }
}
