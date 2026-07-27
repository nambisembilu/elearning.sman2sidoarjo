// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../models/staff/rubrik_mapel_model.dart';
import '../../../../models/staff/rubrik_mapel_sementara_model.dart';
import '../../../../services/staff/filter_data_service.dart';
import '../../../../services/staff/rubrik_mapel_service.dart';

part 'rubrik_mapel_riverpod.g.dart';

@riverpod
class RubrikMapelRiverpod extends _$RubrikMapelRiverpod {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _mapelId;
  int? _tahunAjaranId;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;
  int? get mapelId => _mapelId;
  int? get tahunAjaranId => _tahunAjaranId;

  List<RubrikMapel> rubrikMapelList = [];
  int userIdKoorMapel = 0;
  String koorMapel = '';
  bool isKoorMapel = false;

  @override
  FutureOr<List<RubrikMapel>> build() async {
    // return await _fetch(page: _currentPage, search: _lastSearch, reset: true, mapelId: _mapelId);
    return [];
  }

  // Future<void> resetAndFetch({
  //   String search = '',
  //   int page = 1,
  //   required int mapelId,
  // }) async {
  //   _mapelId = mapelId;
  //   _currentPage = page;
  //   _lastSearch = search;
  //   _hasMore = true;
  //   _isLoadingMore = false;

  //   state = const AsyncLoading<List<RubrikMapel>>().copyWithPrevious(state);
  //   await _fetch(page: _currentPage, search: _lastSearch, reset: true, mapelId: _mapelId);
  // }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    required int mapelId,
    required int tahunAjaranId,
  }) async {
    // Validasi mapelId
    if (mapelId <= 0) {
      print("Warning: mapelId is invalid: $mapelId");
      return;
    }

    if (tahunAjaranId <= 0) {
      print("Warning: mapelId is invalid: $tahunAjaranId");
      return;
    }

    _mapelId = mapelId;
    _tahunAjaranId = tahunAjaranId;
    _currentPage = page;
    _lastSearch = search;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading<List<RubrikMapel>>().copyWithPrevious(state);
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      reset: true,
      mapelId: _mapelId,
      tahunAjaranId: _tahunAjaranId,
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
        reset: true,
        mapelId: _mapelId,
        tahunAjaranId: _tahunAjaranId,
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
      reset: true,
      mapelId: _mapelId,
      tahunAjaranId: _tahunAjaranId,
    );
  }

  Future<List<RubrikMapel>> _fetch({
    required int? mapelId,
    required int? tahunAjaranId,
    required int page,
    required String search,
    required bool reset,
  }) async {
    final service = RubrikMapelService(Supabase.instance.client);

    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString('user_id')!);

    try {
      final res = await service.getRubrikPembelajaran(
        mapelId: mapelId,
        tahunAjaranId: tahunAjaranId,
        page: page,
        search: search,
      );

      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      rubrikMapelList = res.data;
      userIdKoorMapel = res.userIdKoorMapel;
      koorMapel = res.koorMapel;

      if (userId == userIdKoorMapel) {
        isKoorMapel = true;
      } else {
        isKoorMapel = false;
      }

      state = AsyncData<List<RubrikMapel>>(res.data);
      return res.data;
    } catch (e, st) {
      state = AsyncError<List<RubrikMapel>>(e, st);
      return [];
    }
  }

  // tambah function ya sin
  Future<List<MataPelajaran2>> fetchMapelDiampu() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getMapel();
    return res;
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<TahunAjaran>> fetchTahunAjaran() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getTahunAjaran();
    return res;
  }

  Future<bool> addNewRubrikMapel({required List<RubrikItem> rubrikJson}) async {
    final service = RubrikMapelService(Supabase.instance.client);
    try {
      await service.addNewRubrikMapel(rubrikJson: rubrikJson);

      final prefs = await SharedPreferences.getInstance();
      final mapelId = prefs.getInt('mapel_id');

      _currentPage = 1;
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        mapelId: mapelId,
        tahunAjaranId: _tahunAjaranId,
      );
      return true;
    } catch (e, st) {
      state = AsyncError<List<RubrikMapel>>(e, st);
      return false;
    }
  }

  // Future<List<RubrikMapel>> getDetailMateri({required int materiId}) async {
  //   final service = RubrikMapelService(Supabase.instance.client);
  //   try {
  //     final result = await service.getDetailMateri(materiId: materiId);
  //     return result;
  //   } catch (e, st) {
  //     state = AsyncError<List<RubrikMapel>>(e, st);
  //     rethrow;
  //   }
  // }
}
