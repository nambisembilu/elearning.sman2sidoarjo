// ignore_for_file: avoid_print
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/guru/daftar_pengumpulan_tugas.dart';
import '../../../../services/guru/tugas_kelas_service.dart';

part 'daftar_pengumpulan_tugas_riverpod.g.dart';

@riverpod
class DaftarPengumpulanTugasRiverpod extends _$DaftarPengumpulanTugasRiverpod {
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

  List<DaftarPengumpulanTugas> daftarPengumpulanTugasList = [];

  @override
  FutureOr<List<DaftarPengumpulanTugas>> build() async {
    return [];
  }

  Future<void> resetAndFetch({String search = '', int page = 1}) async {
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<DaftarPengumpulanTugas>>().copyWithPrevious(
      state,
    );
    await _fetch(page: _currentPage, search: _lastSearch, reset: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      await _fetch(page: _currentPage, search: _lastSearch, reset: false);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<DaftarPengumpulanTugas>> _fetch({
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);

    try {
      final res = await service.getDaftarPengumpulanTugas(
        page: page,
        search: search,
      );

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;

      if (reset) {
        // Reset data
        daftarPengumpulanTugasList = res.data;
      } else {
        // Tambah data ke list yang sudah ada
        daftarPengumpulanTugasList.addAll(res.data);
      }

      state = AsyncData<List<DaftarPengumpulanTugas>>(
        daftarPengumpulanTugasList,
      );
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<DaftarPengumpulanTugas>>(e, st);
      return [];
    }
  }
}
