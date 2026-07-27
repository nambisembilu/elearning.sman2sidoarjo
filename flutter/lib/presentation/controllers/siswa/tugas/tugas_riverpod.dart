// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/siswa/filtering_model.dart';
import '../../../../models/siswa/pengumpulan_tugas_model.dart';
import '../../../../models/siswa/tugas_kelas_model.dart';
import '../../../../services/siswa/filter_data_service.dart';
import '../../../../services/siswa/tugas_kelas_service.dart';

part 'tugas_riverpod.g.dart';

@riverpod
class TugasKelasRiverpod extends _$TugasKelasRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _semesterId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;
  int? get semesterId => _semesterId;

  List<TugasKelas> tugasList = [];

  @override
  FutureOr<List<TugasKelas>> build() async {
    return [];
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    required int semesterId,
  }) async {
    // Validasi semesterId
    if (semesterId <= 0) {
      print("Warning: semesterId is invalid: $semesterId");
      return;
    }

    _semesterId = semesterId;
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<TugasKelas>>().copyWithPrevious(state);
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      reset: true,
      semesterId: _semesterId,
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;

    try {
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: false,
        semesterId: _semesterId,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<TugasKelas>> _fetch({
    required int? semesterId,
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);

    try {
      final res = await service.getTugasKelas(
        page: page,
        search: search,
        semesterId: semesterId!,
      );

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;

      if (reset) {
        // Reset data
        tugasList = res.data;
      } else {
        // Tambah data ke list yang sudah ada
        tugasList.addAll(res.data);
      }

      state = AsyncData<List<TugasKelas>>(tugasList);
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return [];
    }
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<Semester>> fetchSemester() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getSemester();
    return res;
  }

  Future<List<TugasKelas>> getDetailTugas({required int tugasId}) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      final result = await service.getDetailTugas(tugasId: tugasId);
      return result;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      rethrow;
    }
  }

  // Di ujian_riverpod.dart - tambahkan fungsi ini
  Future<List<PengumpulanTugasDetailModel>>
  getDetailPengumpulanTugasSiswa() async {
    final service = TugasKelasService(Supabase.instance.client);
    final res = await service.getDetailPengumpulanTugasSiswa();
    return res;
  }

  Future<bool> submitTugas({
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    return await service.addPengumpulanTugas(
      fileBytes: fileBytes,
      fileNames: fileNames,
    );
  }

  Future<bool> updatePengumpulanTugas({
    required int pengumpulanTugasId,
    required String statusPengumpulan,
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
    required List<String> filesToDelete, // URL file yang dihapus
    required List<Map<String, dynamic>> filesToKeep, // file lama yang tetap
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      await service.updatePengumpulanTugas(
        pengumpulanTugasId: pengumpulanTugasId,
        statusPengumpulan: statusPengumpulan,
        fileBytes: fileBytes,
        fileNames: fileNames,
        filesToDelete: filesToDelete,
        filesToKeep: filesToKeep,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return false;
    }
  }
}
