import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/filtering_model.dart';
import '../../../models/staff/kelas_model.dart';
import '../../../services/staff/filter_data_service.dart';
import '../../../services/staff/kelas_service.dart';

part 'kelas_riverpod.g.dart';

@riverpod
class KelasNotifier extends _$KelasNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _tahunAjaranId;
  String _jenjang = 'Semua Jenjang';
  String _jurusan = 'Semua Jurusan';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<Kelas> lastKelas = [];

  @override
  FutureOr<List<Kelas>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = KelasService(Supabase.instance.client);
    final res = await service.getAllKelas(
      page: _currentPage,
      search: _lastSearch,
      tahun_ajaran_id: _tahunAjaranId,
      jenjang: _jenjang,
      jurusan: _jurusan,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastKelas = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? tahunAjaranId,
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _tahunAjaranId = tahunAjaranId;
    _jenjang = jenjang;
    _jurusan = jurusan;

    state = const AsyncLoading<List<Kelas>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
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
        tahunAjaranId: _tahunAjaranId,
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
      tahunAjaranId: _tahunAjaranId,
      jenjang: _jenjang,
      jurusan: _jenjang,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? tahunAjaranId,
    required String? jenjang,
    required String? jurusan,
  }) async {
    final service = KelasService(Supabase.instance.client);

    try {
      final res = await service.getAllKelas(
        page: page,
        search: search,
        tahun_ajaran_id: tahunAjaranId,
        jenjang: jenjang ?? _jenjang,
        jurusan: jurusan ?? _jurusan,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastKelas = res.data;

      state = AsyncData<List<Kelas>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<Kelas>>(e, st);
    }
  }

  Future<void> filterKelas({
    required int? pTahunAjaranId,
    required String? pJenjang,
    required String? pJurusan,
  }) async {
    try {
      await resetAndFetch(
        search: _lastSearch,
        page: _currentPage,
        tahunAjaranId: pTahunAjaranId,
        jenjang: pJenjang ?? _jenjang,
        jurusan: pJurusan ?? _jurusan,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<TahunAjaran>> fetchTahunAjaran() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getTahunAjaran();
    return res;
  }

  Future<bool> addKelas({
    required String jenjang,
    required String jurusan,
    required String gedung,
    required int user_id, //untuk wali kelas
  }) async {
    final service = KelasService(Supabase.instance.client);

    try {
      await service.addKelas(
        jenjang: jenjang,
        jurusan: jurusan,
        gedung: gedung,
        user_id: user_id,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Kelas>>(e, st);
      return false;
    }
  }

  Future<bool> updateKelas({
    required int kelas_id,
    required String gedung,
    required int user_id, //untuk wali kelas
  }) async {
    final service = KelasService(Supabase.instance.client);

    try {
      await service.updateKelas(
        kelas_id: kelas_id,
        gedung: gedung,
        user_id: user_id,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Kelas>>(e, st);
      return false;
    }
  }

  Future<bool> deleteKelas({required int kelas_id}) async {
    final service = KelasService(Supabase.instance.client);

    try {
      await service.deleteKelas(kelas_id: kelas_id);

      // Refresh list kelas setelah delete
      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Kelas>>(e, st);
      return false;
    }
  }
}
