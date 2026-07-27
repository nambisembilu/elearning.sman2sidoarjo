import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/filtering_model.dart';
import '../../../services/staff/filter_data_service.dart';

part 'walas_tersedia_riverpod.g.dart';

@riverpod
class WalasTersediaNotifier extends _$WalasTersediaNotifier {
  @override
  FutureOr<List<WalasTersedia>> build() async {
    // initial state kosong
    return [];
  }

  // Fungsi untuk fetch mapel berdasarkan jenjang & jurusan
  Future<void> fetchWalasTersedia() async {
    state = const AsyncLoading<List<WalasTersedia>>().copyWithPrevious(state);

    try {
      final service = FilteringDataService(Supabase.instance.client);
      final res = await service.getWalasTersedia();
      state = AsyncData<List<WalasTersedia>>(res);
    } catch (e, st) {
      state = AsyncError<List<WalasTersedia>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<WalasTersedia>>([]);
  }
}
