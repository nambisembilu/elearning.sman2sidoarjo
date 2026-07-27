import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../services/staff/filter_data_service.dart';

part 'waktu_tersedia_riverpod.g.dart';

@riverpod
class WaktuTersediaNotifier extends _$WaktuTersediaNotifier {
  @override
  FutureOr<List<WaktuTersedia>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchWaktuTersedia({
    required int kelasId,
    required String hari,
  }) async {
    state = const AsyncLoading<List<WaktuTersedia>>().copyWithPrevious(state);

    try {
      final service = FilteringDataService(Supabase.instance.client);
      final res = await service.getWaktuTersedia(kelasId: kelasId, hari: hari);
      state = AsyncData<List<WaktuTersedia>>(res);
    } catch (e, st) {
      state = AsyncError<List<WaktuTersedia>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<WaktuTersedia>>([]);
  }
}
