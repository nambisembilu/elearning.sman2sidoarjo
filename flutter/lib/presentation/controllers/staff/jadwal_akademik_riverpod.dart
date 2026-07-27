import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/staff/filtering_model.dart';
import '../../../models/staff/jadwal_akademik_model.dart';
import '../../../services/staff/filter_data_service.dart';
import '../../../services/staff/jadwal_akademik_service.dart';

part 'jadwal_akademik_riverpod.g.dart';

@riverpod
class JadwalAkademikRiverpod extends _$JadwalAkademikRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _tahunAjaranId;
  String _bulan = '';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<JadwalAkademik> lastJadwalAkademik = [];

  @override
  FutureOr<List<JadwalAkademik>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';
    _bulan = '';

    final service = JadwalAkademikService(Supabase.instance.client);
    final res = await service.getJadwalAkademik(
      page: _currentPage,
      search: _lastSearch,
      tahun_ajaran_id: _tahunAjaranId,
      bulan: _bulan,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastJadwalAkademik = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? tahunAjaranId,
    String bulan = '',
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _tahunAjaranId = tahunAjaranId;
    _bulan = bulan;

    state = const AsyncLoading<List<JadwalAkademik>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
      bulan: _bulan,
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
        bulan: _bulan,
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
      bulan: _bulan,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? tahunAjaranId,
    required String bulan,
  }) async {
    final service = JadwalAkademikService(Supabase.instance.client);

    try {
      final res = await service.getJadwalAkademik(
        page: page,
        search: search,
        tahun_ajaran_id: tahunAjaranId,
        bulan: bulan,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastJadwalAkademik = res.data;

      state = AsyncData<List<JadwalAkademik>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<JadwalAkademik>>(e, st);
    }
  }

  Future<void> filterJadwalAkademik({
    required int? pTahunAjaranId,
    required String pBulan,
  }) async {
    _tahunAjaranId = pTahunAjaranId;
    _bulan = pBulan;

    try {
      await resetAndFetch(
        page: _currentPage,
        search: _lastSearch,
        tahunAjaranId: _tahunAjaranId,
        bulan: _bulan,
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

  Future<bool> addJadwalAkademik({
    required String namaKegiatan,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    final service = JadwalAkademikService(Supabase.instance.client);

    try {
      await service.addJadwalAkademik(
        namaKegiatan: namaKegiatan,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalAkademik>>(e, st);
      return false;
    }
  }

  Future<bool> updateJadwalAkademik({
    required int JadwalAkademikId,
    required String namaKegiatan,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    final service = JadwalAkademikService(Supabase.instance.client);

    try {
      await service.updateJadwalAkademik(
        JadwalAkademikId: JadwalAkademikId,
        namaKegiatan: namaKegiatan,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalAkademik>>(e, st);
      return false;
    }
  }

  Future<bool> deleteJadwalAkademik({required int JadwalAkademikId}) async {
    final service = JadwalAkademikService(Supabase.instance.client);

    try {
      await service.deleteJadwalAkademik(JadwalAkademikId: JadwalAkademikId);

      // Refresh list siswa setelah tambah
      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<JadwalAkademik>>(e, st);
      return false;
    }
  }
}
