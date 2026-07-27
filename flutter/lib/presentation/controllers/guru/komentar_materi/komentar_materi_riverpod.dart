// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/komentar_model.dart';
import '../../../../services/guru/komentar_service.dart';

part 'komentar_materi_riverpod.g.dart';

@riverpod
class KomentarMateriRiverpod extends _$KomentarMateriRiverpod {
  int _currentPage = 1;
  int _totalPages = 0;
  bool _hasMore = true;
  bool _hasOlder = false;
  bool _isLoadingMore = false;
  bool _isLoadingOlder = false;

  bool get hasMore => _hasMore;
  bool get hasOlder => _hasOlder;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingOlder => _isLoadingOlder;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  List<Komentar> _items = [];
  List<Komentar> get items => _items;

  @override
  FutureOr<List<Komentar>> build() async {
    // Mulai dari halaman 1 (komentar TERBARU)
    _currentPage = 1;
    return _fetch(reset: true);
  }

  /// 🔄 Refresh + Reset Pagination
  Future<void> resetAndFetch() async {
    _currentPage = 1;
    _hasMore = true;
    _hasOlder = false;
    _isLoadingMore = false;
    _isLoadingOlder = false;

    state = const AsyncLoading();
    await _fetch(reset: true);
  }

  /// 🔼 Load OLDER comments (scroll UP) - halaman berikutnya
  Future<void> loadOlder() async {
    if (!_hasMore || _isLoadingOlder) return;

    _isLoadingOlder = true;
    _currentPage++;

    try {
      await _fetchOlder();
    } finally {
      _isLoadingOlder = false;
    }
  }

  /// 📥 Load NEWER comments (scroll DOWN dari bawah) - halaman sebelumnya
  /// Ini jarang digunakan karena kita mulai dari yang terbaru
  Future<void> loadNewer() async {
    if (_currentPage <= 1 || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage--;

    try {
      await _fetchNewer();
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 🧠 Fetch data untuk halaman tertentu (halaman N, data terbaru di halaman 1)
  Future<List<Komentar>> _fetch({required bool reset}) async {
    final service = KomentarService(Supabase.instance.client);

    try {
      final response = await service.getKomentarMateri(page: _currentPage);

      _totalPages = response.totalPage;
      _hasMore = _currentPage < _totalPages;
      _hasOlder = _currentPage > 1;

      List<Komentar> newList = [];

      if (reset) {
        // Halaman 1: data terbaru, kita ingin ini di BAWAH
        // Karena SQL DESC, kita perlu REVERSE untuk menampilkan terlama di atas
        newList = _reverseForDisplay(response.data);
      } else {
        // Untuk load older, tambahkan di AWAL (karena data lebih lama)
        newList = [..._reverseForDisplay(response.data), ..._items];
      }

      _items = newList;
      state = AsyncData(newList);

      return newList;
    } catch (e, st) {
      // Rollback halaman jika error
      if (!reset) _currentPage--;
      state = AsyncError(e, st);
      return [];
    }
  }

  /// 🧠 Fetch OLDER data (halaman berikutnya, data lebih lama)
  Future<List<Komentar>> _fetchOlder() async {
    final service = KomentarService(Supabase.instance.client);

    try {
      final response = await service.getKomentarMateri(page: _currentPage);

      _hasMore = _currentPage < _totalPages;

      // Data lebih lama ditambahkan di AWAL list
      List<Komentar> newList = [
        ..._reverseForDisplay(response.data),
        ..._items,
      ];

      _items = newList;
      state = AsyncData(newList);

      return newList;
    } catch (e, st) {
      // Rollback halaman jika error
      _currentPage--;
      state = AsyncError(e, st);
      return [];
    }
  }

  /// 🧠 Fetch NEWER data (halaman sebelumnya, data lebih baru)
  Future<List<Komentar>> _fetchNewer() async {
    final service = KomentarService(Supabase.instance.client);

    try {
      final response = await service.getKomentarMateri(page: _currentPage);

      _hasOlder = _currentPage > 1;

      // Data lebih baru ditambahkan di AKHIR list
      List<Komentar> newList = [
        ..._items,
        ..._reverseForDisplay(response.data),
      ];

      _items = newList;
      state = AsyncData(newList);

      return newList;
    } catch (e, st) {
      // Rollback halaman jika error
      _currentPage++;
      state = AsyncError(e, st);
      return [];
    }
  }

  /// 🔁 Helper: Reverse data untuk display
  /// Karena SQL ORDER BY DESC (terbaru → terlama)
  /// Tapi kita ingin tampilkan: terlama (atas) → terbaru (bawah)
  List<Komentar> _reverseForDisplay(List<Komentar> data) {
    return List.from(data.reversed);
  }

  Future<bool> addKomentar({required String komentar}) async {
    final service = KomentarService(Supabase.instance.client);
    try {
      final success = await service.addKomentarMateri(komentar: komentar);

      if (success) {
        // Setelah berhasil, kembali ke halaman 1 (komentar terbaru)
        _currentPage = 1;
        await _fetch(reset: true);
      }

      return success;
    } catch (e, st) {
      state = AsyncError<List<Komentar>>(e, st);
      return false;
    }
  }

  Future<bool> deleteKomentar({required int komentarId}) async {
    final service = KomentarService(Supabase.instance.client);
    try {
      await service.deleteKomentarMateri(komentarId: komentarId);

      // Fetch ulang data saat ini
      await _fetch(reset: true);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Komentar>>(e, st);
      return false;
    }
  }
}
