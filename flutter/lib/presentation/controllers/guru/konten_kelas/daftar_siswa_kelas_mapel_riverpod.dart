import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/siswa_kelas_mapel_model.dart';
import '../../../../services/guru/daftar_siswa_service.dart';

part 'daftar_siswa_kelas_mapel_riverpod.g.dart';

@riverpod
class SiswaKelasRiverpod extends _$SiswaKelasRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;

  List<SiswaKelas> _items = [];
  List<SiswaKelas> get items => _items;

  @override
  FutureOr<List<SiswaKelas>> build() async {
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
  Future<List<SiswaKelas>> _fetch({required bool reset}) async {
    final service = SiswaKelasService(Supabase.instance.client);

    try {
      final response = await service.getSiswaKelas(
        page: _currentPage,
        search: _lastSearch,
      );

      _hasMore = _currentPage < response.totalPage;

      List<SiswaKelas> newList = reset
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
}
