import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../services/staff/filter_data_service.dart';

part 'guru_tersedia_riverpod.g.dart';

@riverpod
class GuruTersediaNotifier extends _$GuruTersediaNotifier {
  @override
  FutureOr<List<FilterGuru>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchGuruTersedia({
    required int mapelId,
    required String hari,
    required String waktu,
  }) async {
    state = const AsyncLoading<List<FilterGuru>>().copyWithPrevious(state);

    try {
      final service = FilteringDataService(Supabase.instance.client);
      final res = await service.getGuruTersedia(
        mapelId: mapelId,
        hari: hari,
        waktu: waktu,
      );
      state = AsyncData<List<FilterGuru>>(res);
    } catch (e, st) {
      state = AsyncError<List<FilterGuru>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<FilterGuru>>([]);
  }
}
