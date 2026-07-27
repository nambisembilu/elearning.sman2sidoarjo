// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/siswa/filtering_model.dart';
import '../../../../models/siswa/kelas_siswa_model.dart';
import '../../../../services/siswa/filter_data_service.dart';
import '../../../../services/siswa/kelas_siswa_service.dart';

part 'kelas_siswa_riverpod.g.dart';

@riverpod
class KelasSiswaNotifier extends _$KelasSiswaNotifier {
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;

  int? _tahunAjaranId;

  bool get isLoadingMore => _isLoadingMore;
  int get total => _total;

  List<KelasSiswa> lastKelasSiswa = [];

  // ✅ Tambahan state baru
  KelasSiswa? _selectedKmp;
  KelasSiswa? get selectedKmp => _selectedKmp;

  @override
  FutureOr<List<KelasSiswa>> build() async {
    _isLoadingMore = false;
    _lastSearch = '';

    final service = KelasSiswaService(Supabase.instance.client);
    final res = await service.getDaftarKelasSiswa(
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
    );

    _total = res.total;
    lastKelasSiswa = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({String search = '', int? tahunAjaranId}) async {
    _isLoadingMore = false;
    _lastSearch = search;
    _tahunAjaranId = tahunAjaranId;

    state = const AsyncLoading<List<KelasSiswa>>().copyWithPrevious(state);

    await _fetch(
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
      reset: true,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    try {
      await _fetch(
        search: _lastSearch,
        tahunAjaranId: _tahunAjaranId,
        reset: true,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _fetch({
    required String search,
    required bool reset,
    required int? tahunAjaranId,
  }) async {
    final service = KelasSiswaService(Supabase.instance.client);

    try {
      final res = await service.getDaftarKelasSiswa(
        search: search,
        tahunAjaranId: tahunAjaranId,
      );
      _total = res.total;
      lastKelasSiswa = res.data;

      state = AsyncData<List<KelasSiswa>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<KelasSiswa>>(e, st);
    }
  }

  Future<void> filterKelas({required int? pTahunAjaranId}) async {
    try {
      await resetAndFetch(search: _lastSearch, tahunAjaranId: pTahunAjaranId);
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

  // Future<List<KelasMapelGuru>> fetchKelasMapelSiswa({
  //   required int tahunAjaranId,
  // }) async {
  //   final service = FilteringDataService(Supabase.instance.client);
  //   final res = await service.getKelasMapelGuru(tahunAjaranId: tahunAjaranId);
  //   return res;
  // }

  Future<void> setSelectedKmp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      if (kelasMapelId == null) {
        throw Exception('kelasMapelId belum tersimpan di SharedPreferences');
      }

      // Pastikan data sudah ada di lastKelasSiswa
      if (lastKelasSiswa.isEmpty) {
        // kalau belum, fetch dulu
        await _fetch(
          search: _lastSearch,
          reset: true,
          tahunAjaranId: _tahunAjaranId,
        );
      }

      final selected = lastKelasSiswa.firstWhere(
        (item) => item.kelasMapelId == kelasMapelId,
        orElse: () => throw Exception('Data kelasMapelId tidak ditemukan'),
      );

      _selectedKmp = selected;

      // 🔹 ini penting supaya Riverpod rebuild widget yang watch provider ini
      state = AsyncData([...lastKelasSiswa]);
      print("✅ Selected kelas: $selected");
    } catch (e) {
      _selectedKmp = null;
      state = AsyncError(e, StackTrace.current);
      print("❌ Error setSelectedKmp: $e");
    }
  }
}
