// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/guru/filtering_model.dart';
import '../../../models/guru/kelas_guru_model.dart';
import '../../../services/guru/filter_data_service.dart';
import '../../../services/guru/kelas_guru_service.dart';

part 'kelas_guru_riverpod.g.dart';

@riverpod
class KelasGuruNotifier extends _$KelasGuruNotifier {
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;

  int? _tahunAjaranId;

  bool get isLoadingMore => _isLoadingMore;
  int get total => _total;

  List<KelasGuru> lastKelasGuru = [];

  // ✅ Tambahan state baru
  KelasGuru? _selectedKmp;
  KelasGuru? get selectedKmp => _selectedKmp;

  @override
  FutureOr<List<KelasGuru>> build() async {
    _isLoadingMore = false;
    _lastSearch = '';

    final service = KelasGuruService(Supabase.instance.client);
    final res = await service.getDaftarKelasGuru(
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
    );

    _total = res.total;
    lastKelasGuru = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({String search = '', int? tahunAjaranId}) async {
    _isLoadingMore = false;
    _lastSearch = search;
    _tahunAjaranId = tahunAjaranId;

    state = const AsyncLoading<List<KelasGuru>>().copyWithPrevious(state);

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
    final service = KelasGuruService(Supabase.instance.client);

    try {
      final res = await service.getDaftarKelasGuru(
        search: search,
        tahunAjaranId: tahunAjaranId,
      );
      _total = res.total;
      lastKelasGuru = res.data;

      state = AsyncData<List<KelasGuru>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<KelasGuru>>(e, st);
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

  Future<List<KelasMapelGuru>> fetchKelasMapelGuru({
    required int tahunAjaranId,
  }) async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getKelasMapelGuru(tahunAjaranId: tahunAjaranId);
    return res;
  }

  Future<void> setSelectedKmp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final kelasMapelId = prefs.getInt('kelasMapelId');

      if (kelasMapelId == null) {
        throw Exception('kelasMapelId belum tersimpan di SharedPreferences');
      }

      // Pastikan data sudah ada di lastKelasGuru
      if (lastKelasGuru.isEmpty) {
        // kalau belum, fetch dulu
        await _fetch(
          search: _lastSearch,
          reset: true,
          tahunAjaranId: _tahunAjaranId,
        );
      }

      final selected = lastKelasGuru.firstWhere(
        (item) => item.kelasMapelId == kelasMapelId,
        orElse: () => throw Exception('Data kelasMapelId tidak ditemukan'),
      );

      _selectedKmp = selected;

      // 🔹 ini penting supaya Riverpod rebuild widget yang watch provider ini
      state = AsyncData([...lastKelasGuru]);
      print("✅ Selected kelas: $selected");
    } catch (e) {
      _selectedKmp = null;
      state = AsyncError(e, StackTrace.current);
      print("❌ Error setSelectedKmp: $e");
    }
  }
}
