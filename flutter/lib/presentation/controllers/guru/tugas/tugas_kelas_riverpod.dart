// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/filtering_model.dart';
import '../../../../models/guru/pengumpulan_tugas_model.dart';
import '../../../../models/guru/tugas_kelas_model.dart';
import '../../../../services/guru/filter_data_service.dart';
import '../../../../services/guru/tugas_kelas_service.dart';

part 'tugas_kelas_riverpod.g.dart';

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

  Future<List<LingkupMateri>> fetchLingkupMateri() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getLingkupMateri();
    return res;
  }

  Future<bool> addTugas({
    required String judul,
    required int tujuanPembelajaranId,
    required String deskripsi,
    required String deadline,
    required String statusTugas,
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      await service.addTugasKelas(
        judul: judul,
        tujuanPembelajaranId: tujuanPembelajaranId,
        deskripsi: deskripsi,
        deadline: deadline,
        statusTugas: statusTugas,
        fileBytes: fileBytes,
        fileNames: fileNames,
      );

      _currentPage = 1;
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        semesterId: _semesterId,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return false;
    }
  }

  // Update fungsi updateTugas untuk menyesuaikan dengan RPC
  Future<bool> updateTugas({
    required int tugasId,
    required String judul,
    required String deskripsi,
    required String deadline,
    required String statusTugas,
    required List<Uint8List> fileBytes,
    required List<String> fileNames,
    required List<String> filesToDelete, // URL file yang dihapus
    required List<Map<String, dynamic>> filesToKeep, // file lama yang tetap
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      await service.updateTugasKelas(
        tugasId: tugasId,
        judul: judul,
        deskripsi: deskripsi,
        deadline: deadline,
        statusTugas: statusTugas,
        fileBytes: fileBytes,
        fileNames: fileNames,
        filesToDelete: filesToDelete,
        filesToKeep: filesToKeep,
      );

      // _currentPage = 1;
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        semesterId: _semesterId,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return false;
    }
  }

  Future<bool> deleteTugas({
    required int tugasId,
    required List<String> filesToDelete,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      await service.deleteTugasKelas(
        tugasId: tugasId,
        filesToDelete: filesToDelete,
      );
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        semesterId: _semesterId,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return false;
    }
  }

  Future<bool> addNilaiTugas({
    required int pengumpulanTugasId,
    required double nilai,
    required String feedback,
  }) async {
    final service = TugasKelasService(Supabase.instance.client);
    try {
      await service.addNilaiTugas(
        pengumpulanTugasId: pengumpulanTugasId,
        nilai: nilai,
        feedback: feedback,
      );
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        semesterId: _semesterId,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<TugasKelas>>(e, st);
      return false;
    }
  }

  Future<PengumpulanTugasDetailModel> getDetailPengumpulanTugasSiswa() async {
    final service = TugasKelasService(Supabase.instance.client);
    final res = await service.getDetailPengumpulanTugasSiswa();
    return res; // Kembalikan objek tunggal, bukan List
  }
}
