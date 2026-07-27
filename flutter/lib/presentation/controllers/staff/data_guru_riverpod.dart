import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/data_guru_model.dart';
import '../../../models/staff/mapel_by_jenjang.dart';
import '../../../services/staff/data_guru_service.dart';

part 'data_guru_riverpod.g.dart';

@riverpod
class DataGuruNotifier extends _$DataGuruNotifier {
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

  List<Guru> lastGuruList = [];

  @override
  FutureOr<List<Guru>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = GuruService(Supabase.instance.client);
    final res = await service.getAllGuru(
      page: _currentPage,
      search: _lastSearch,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastGuruList = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({String search = '', int page = 1}) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;

    state = const AsyncLoading<List<Guru>>().copyWithPrevious(state);

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

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = GuruService(Supabase.instance.client);

    try {
      final res = await service.getAllGuru(page: page, search: search);
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastGuruList = res.data;

      state = AsyncData<List<Guru>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<Guru>>(e, st);
    }
  }

  Future<List<MapelByJenjang>> mapelByJenjangJurusan({
    required String jenjang,
    required String jurusan,
  }) async {
    final service = GuruService(Supabase.instance.client);
    return service.getMapelByJenjangJurusan(jenjang: jenjang, jurusan: jurusan);
  }

  Future<bool> addGuru({
    required int nipNuptk,
    required String nama,
    required String email,
    required int noTelp,
    required String alamat,
    required List<int> mapelId,
  }) async {
    final service = GuruService(Supabase.instance.client);

    try {
      await service.addGuru(
        nipNuptk: nipNuptk,
        nama: nama,
        email: email,
        nomorTelepon: noTelp,
        alamat: alamat,
        idMapel: mapelId,
      );

      // Refresh list guru setelah tambah
      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Guru>>(e, st);
      return false;
    }
  }

  Future<bool> updateGuru({
    required int userId,
    required int nipNuptk,
    required String nama,
    required String email,
    required int noTelp,
    required String alamat,
    required List<int> mapelId,
  }) async {
    final service = GuruService(Supabase.instance.client);

    try {
      await service.updateGuru(
        userId: userId,
        nipNuptk: nipNuptk,
        nama: nama,
        email: email,
        nomorTelepon: noTelp,
        alamat: alamat,
        idMapel: mapelId,
      );

      // Refresh list guru setelah tambah
      await resetAndFetch(search: _lastSearch, page: _currentPage);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Guru>>(e, st);
      return false;
    }
  }

  Future<bool> deleteGuru({required int userId}) async {
    final service = GuruService(Supabase.instance.client);

    try {
      await service.deleteGuru(userId: userId);

      // Refresh list guru setelah tambah
      await resetAndFetch(search: _lastSearch, page: _currentPage);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Guru>>(e, st);
      return false;
    }
  }
}
