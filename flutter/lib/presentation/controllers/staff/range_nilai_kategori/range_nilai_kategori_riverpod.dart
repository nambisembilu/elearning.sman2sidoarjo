import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/range_nilai_kategori_model.dart';
import '../../../../services/staff/range_nilai_kategori_service.dart';

part 'range_nilai_kategori_riverpod.g.dart';

@riverpod
class RangeNilaiKategoriNotifier extends _$RangeNilaiKategoriNotifier {
  List<RangeNilaiKategori> lastRange = [];

  @override
  FutureOr<List<RangeNilaiKategori>> build() async {
    return fetchRangeNilaiKategori();
  }

  Future<List<RangeNilaiKategori>> fetchRangeNilaiKategori() async {
    final service = RangeNilaiKategoriService(Supabase.instance.client);

    state = const AsyncLoading<List<RangeNilaiKategori>>().copyWithPrevious(
      state,
    );

    try {
      final result = await service.getRangeNilaiKategori();
      lastRange = result;

      state = AsyncData(result);
      return result;
    } catch (e, st) {
      // kalau error, jangan hilangkan data lama
      state = AsyncError<List<RangeNilaiKategori>>(
        e,
        st,
      ).copyWithPrevious(state);
      return lastRange;
    }
  }

  Future<bool> addRangeNilaiKategori({
    required String kategori,
    required int nilaiMin,
    required int nilaiMaks,
    required String deskripsi,
  }) async {
    final service = RangeNilaiKategoriService(Supabase.instance.client);

    try {
      await service.addRangeNilaiKategori(
        kategori: kategori,
        nilaiMin: nilaiMin,
        nilaiMaks: nilaiMaks,
        deskripsi: deskripsi,
      );

      // refresh
      await fetchRangeNilaiKategori();
      return true;
    } catch (e, st) {
      state = AsyncError<List<RangeNilaiKategori>>(
        e,
        st,
      ).copyWithPrevious(state);
      return false;
    }
  }

  Future<bool> deleteRangeNilaiKategori({required int kategoriNilaiId}) async {
    final service = RangeNilaiKategoriService(Supabase.instance.client);

    try {
      await service.deleteRangeNilaiKategori(kategoriNilaiId: kategoriNilaiId);

      // refresh
      await fetchRangeNilaiKategori();
      return true;
    } catch (e, st) {
      state = AsyncError<List<RangeNilaiKategori>>(
        e,
        st,
      ).copyWithPrevious(state);
      return false;
    }
  }
}
