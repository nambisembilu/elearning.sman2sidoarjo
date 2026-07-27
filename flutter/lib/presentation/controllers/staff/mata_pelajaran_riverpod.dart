import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/filtering_model.dart';
import '../../../models/staff/mata_pelajaran_model.dart';
import '../../../services/staff/filter_data_service.dart';
import '../../../services/staff/mata_pelajaran_service.dart';

part 'mata_pelajaran_riverpod.g.dart';

@riverpod
class MataPelajaranNotifier extends _$MataPelajaranNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  String _jenjang = 'Semua Jenjang';
  String _jurusan = 'Semua Jurusan';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<MataPelajaran> lastMapel = [];

  @override
  FutureOr<List<MataPelajaran>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = MataPelajaranService(Supabase.instance.client);
    final res = await service.getAllMataPelajaran(
      page: _currentPage,
      search: _lastSearch,
      jenjang: _jenjang,
      jurusan: _jurusan,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastMapel = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _jenjang = jenjang;
    _jurusan = jurusan;

    state = const AsyncLoading<List<MataPelajaran>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      jenjang: _jenjang,
      jurusan: _jurusan,
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
        jenjang: _jenjang,
        jurusan: _jurusan,
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
      jenjang: _jenjang,
      jurusan: _jurusan,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required String? jenjang,
    required String? jurusan,
  }) async {
    final service = MataPelajaranService(Supabase.instance.client);

    try {
      final res = await service.getAllMataPelajaran(
        page: page,
        search: search,
        jenjang: jenjang ?? _jenjang,
        jurusan: jurusan ?? _jurusan,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastMapel = res.data;

      state = AsyncData<List<MataPelajaran>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<MataPelajaran>>(e, st);
    }
  }

  Future<void> filterMataPelajaran({
    required String? pJenjang,
    required String? pJurusan,
  }) async {
    try {
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        jenjang: pJenjang ?? _jenjang,
        jurusan: pJurusan ?? _jurusan,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<bool> addMataPelajaran({
    required String judul,
    required String jenjang,
    required String jurusan,
    required int? userId,
  }) async {
    final service = MataPelajaranService(Supabase.instance.client);

    try {
      await service.addMataPelajaran(
        judul: judul,
        jenjang: jenjang,
        jurusan: jurusan,
        userId: userId,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<MataPelajaran>>(e, st);
      return false;
    }
  }

  Future<bool> updateMataPelajaran({
    required int mapelId,
    required String judul,
  }) async {
    final service = MataPelajaranService(Supabase.instance.client);

    try {
      await service.updateMataPelajaran(mapelId: mapelId, judul: judul);

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<MataPelajaran>>(e, st);
      return false;
    }
  }

  Future<bool> deleteMataPelajaran({required int mapelId}) async {
    final service = MataPelajaranService(Supabase.instance.client);

    try {
      await service.deleteMataPelajaran(mapelId: mapelId);

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<MataPelajaran>>(e, st);
      return false;
    }
  }

  Future<List<FilterGuru>> fetchGuruNonKoorMapel() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getGuruNonKoorMapel();
    return res;
  }
}
