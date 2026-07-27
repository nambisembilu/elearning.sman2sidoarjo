import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../services/staff/filter_data_service.dart';

part 'mapel_by_kelas_hari_riverpod.g.dart';

@riverpod
class MapelByKelasHariNotifier extends _$MapelByKelasHariNotifier {
  @override
  FutureOr<List<MapelByKelasHari>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchMapelByKelasHari({
    required int kelasId,
    required String hari,
  }) async {
    state = const AsyncLoading<List<MapelByKelasHari>>().copyWithPrevious(
      state,
    );

    try {
      final service = FilteringDataService(Supabase.instance.client);
      final res = await service.getMapelByKelasHari(
        kelasId: kelasId,
        hari: hari,
      );
      state = AsyncData<List<MapelByKelasHari>>(res);
    } catch (e, st) {
      state = AsyncError<List<MapelByKelasHari>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<MapelByKelasHari>>([]);
  }
}
