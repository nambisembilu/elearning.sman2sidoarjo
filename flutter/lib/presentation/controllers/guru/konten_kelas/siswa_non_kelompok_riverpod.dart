import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/guru/siswa_kelas_mapel_model.dart';
import '../../../../services/guru/kelompok_belajar_service.dart';

part 'siswa_non_kelompok_riverpod.g.dart';

@riverpod
class SiswaNonKelompokRiverpod extends _$SiswaNonKelompokRiverpod {
  String _lastSearch = '';

  List<SiswaKelas> _items = [];
  List<SiswaKelas> get items => _items;

  @override
  FutureOr<List<SiswaKelas>> build() async {
    return _fetch(reset: true);
  }

  /// 🔄 Refresh + Reset Pagination
  Future<void> resetAndFetch({String search = ''}) async {
    _lastSearch = search;

    state = const AsyncLoading();

    await _fetch(reset: true);
  }

  /// 🧠 Function utama ambil data
  Future<List<SiswaKelas>> _fetch({required bool reset}) async {
    final service = KelompokBelajarService(Supabase.instance.client);

    try {
      final response = await service.getSiswaNonKelompok(search: _lastSearch);

      // List<SiswaKelas> newList =
      //     reset ? response.data : [..._items, ...response.data];

      _items = response;

      state = AsyncData(response);

      return response;
    } catch (e, st) {
      state = AsyncError(e, st);
      return [];
    }
  }
}
