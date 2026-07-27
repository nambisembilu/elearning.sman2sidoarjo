import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/staff/kelas_aktif_model.dart';
import '../../../services/staff/filter_data_service.dart';

part 'kelas_aktif_riverpod.g.dart';

@riverpod
class KelasAktifNotifier extends _$KelasAktifNotifier {
  @override
  FutureOr<List<KelasAktif>> build() async {
    // initial state kosong
    return [];
  }

  Future<void> fetchKelasAktif() async {
    state = const AsyncLoading<List<KelasAktif>>().copyWithPrevious(state);

    try {
      final service = FilteringDataService(Supabase.instance.client);

      final res = await service.getKelasAktif();

      state = AsyncData<List<KelasAktif>>(res);
    } catch (e, st) {
      state = AsyncError<List<KelasAktif>>(e, st);
    }
  }

  // Opsional: reset mapel
  void reset() {
    state = const AsyncData<List<KelasAktif>>([]);
  }
}
