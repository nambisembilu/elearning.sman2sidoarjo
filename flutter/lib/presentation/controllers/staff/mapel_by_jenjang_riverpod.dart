import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/mapel_by_jenjang.dart';
import '../../../services/staff/data_guru_service.dart';

part 'mapel_by_jenjang_riverpod.g.dart';

@riverpod
class MapelByJenjangNotifier extends _$MapelByJenjangNotifier {
  @override
  FutureOr<List<MapelByJenjang>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchMapel({
    required String jenjang,
    required String jurusan,
  }) async {
    state = const AsyncLoading<List<MapelByJenjang>>().copyWithPrevious(state);

    try {
      final service = GuruService(Supabase.instance.client);
      final res = await service.getMapelByJenjangJurusan(
        jenjang: jenjang,
        jurusan: jurusan,
      );
      state = AsyncData<List<MapelByJenjang>>(res);
    } catch (e, st) {
      state = AsyncError<List<MapelByJenjang>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<MapelByJenjang>>([]);
  }
}
