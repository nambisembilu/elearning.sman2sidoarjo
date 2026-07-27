import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../services/staff/filter_data_service.dart';

part 'hari_tersedia_riverpod.g.dart';

@riverpod
class HariTersediaNotifier extends _$HariTersediaNotifier {
  @override
  FutureOr<List<HariTersedia>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchHariTersedia({required int kelasId}) async {
    state = const AsyncLoading<List<HariTersedia>>().copyWithPrevious(state);

    try {
      final service = FilteringDataService(Supabase.instance.client);
      final res = await service.getHariTersedia(kelasId: kelasId);
      state = AsyncData<List<HariTersedia>>(res);
    } catch (e, st) {
      state = AsyncError<List<HariTersedia>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<HariTersedia>>([]);
  }
}
