// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/kelompok_belajar_model.dart';
import '../../../../models/guru/siswa_kelas_mapel_model.dart';
import '../../../../services/guru/kelompok_belajar_service.dart';

part 'kelompok_belajar_riverpod.g.dart';

@riverpod
class KelompokBelajarRiverpod extends _$KelompokBelajarRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;

  List<KelompokBelajar> _items = [];
  List<KelompokBelajar> get items => _items;

  @override
  FutureOr<List<KelompokBelajar>> build() async {
    return _fetch(reset: true);
  }

  /// 🔄 Refresh + Reset Pagination
  Future<void> resetAndFetch({String search = ''}) async {
    _currentPage = 1;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading();

    await _fetch(reset: true);
  }

  /// 📥 Load More (Append)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      await _fetch(reset: false);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 🧠 Function utama ambil data
  Future<List<KelompokBelajar>> _fetch({required bool reset}) async {
    final service = KelompokBelajarService(Supabase.instance.client);

    try {
      final response = await service.getKelompokBelajar(
        page: _currentPage,
        search: _lastSearch,
      );

      _hasMore = _currentPage < response.totalPage;

      List<KelompokBelajar> newList = reset
          ? response.data
          : [..._items, ...response.data];

      _items = newList;

      state = AsyncData(newList);

      return newList;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }

  Future<List<SiswaKelas>> fetchSiswaNonKelompok() async {
    final service = KelompokBelajarService(Supabase.instance.client);
    final res = await service.getSiswaNonKelompok();
    return res;
  }

  // Future<List<SiswaKelas>> searchSiswaNonKelompok({required String search}) async {
  //   final service = KelompokBelajarService(Supabase.instance.client);
  //   final res = await service.getSiswaNonKelompok(search: search);
  //   return res;
  // }

  Future<List<SiswaKelas>> searchSiswaNonKelompok({
    required String search,
  }) async {
    final service = KelompokBelajarService(Supabase.instance.client);
    try {
      final res = await service.getSiswaNonKelompok(search: search);
      return res;
    } catch (e) {
      print('Error searchSiswaNonKelompok: $e');
      return [];
    }
  }

  Future<bool> addKelompok({required List<int> siswaId}) async {
    final service = KelompokBelajarService(Supabase.instance.client);
    try {
      await service.addKelompokBelajar(siswaId: siswaId);

      _currentPage = 1;
      await _fetch(reset: true);
      return true;
    } catch (e, st) {
      state = AsyncError<List<KelompokBelajar>>(e, st);
      return false;
    }
  }

  Future<bool> updateKelompok({
    required int kelompokId,
    required List<int> siswaId,
  }) async {
    final service = KelompokBelajarService(Supabase.instance.client);
    try {
      await service.updateKelompokBelajar(
        kelompokId: kelompokId,
        siswaId: siswaId,
      );

      _currentPage = 1;
      await _fetch(reset: true);
      return true;
    } catch (e, st) {
      state = AsyncError<List<KelompokBelajar>>(e, st);
      return false;
    }
  }

  Future<bool> deleteKelompok({required int kelompokId}) async {
    final service = KelompokBelajarService(Supabase.instance.client);
    try {
      await service.deleteKelompokBelajar(kelompokId: kelompokId);

      _currentPage = 1;
      await _fetch(reset: true);
      return true;
    } catch (e, st) {
      state = AsyncError<List<KelompokBelajar>>(e, st);
      return false;
    }
  }
}
