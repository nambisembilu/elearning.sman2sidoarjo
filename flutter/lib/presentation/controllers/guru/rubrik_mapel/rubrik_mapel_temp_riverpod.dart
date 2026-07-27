// ignore_for_file: avoid_print

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../models/guru/rubrik_mapel_sementara_model.dart';

part 'rubrik_mapel_temp_riverpod.g.dart';

// Tambahkan di bagian providers
@riverpod
class RubrikSementaraRiverpod extends _$RubrikSementaraRiverpod {
  final List<RubrikItem> _rubrikSementara = [];
  int _currentIndex = 0;

  List<RubrikItem> get rubrikSementara => _rubrikSementara;
  int get currentIndex => _currentIndex;
  int get totalRubrik => _rubrikSementara.length;
  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _rubrikSementara.length - 1;
  bool get isLast => _currentIndex == _rubrikSementara.length - 1;

  @override
  List<RubrikItem> build() {
    return _rubrikSementara;
  }

  void addRubrikItem(RubrikItem item) {
    _rubrikSementara.add(item);
    _currentIndex = _rubrikSementara.length - 1; // Set ke yang terakhir
    state = [..._rubrikSementara]; // Notify listeners
    print('✅ Rubrik ditambahkan. Total sekarang: ${_rubrikSementara.length}');
  }

  void updateCurrentRubrik(RubrikItem updatedItem) {
    if (_currentIndex >= 0 && _currentIndex < _rubrikSementara.length) {
      _rubrikSementara[_currentIndex] = updatedItem;
      state = [..._rubrikSementara];
      print('✅ Rubrik index $_currentIndex diupdate');
    } else {
      print('⚠️ Tidak bisa update: currentIndex $_currentIndex diluar range');
    }
  }

  void goToPrevious() {
    if (hasPrevious) {
      _currentIndex--;
      state = [..._rubrikSementara];
      print('⬅️ Pindah ke rubrik $_currentIndex');
    }
  }

  void goToNext() {
    if (hasNext) {
      _currentIndex++;
      state = [..._rubrikSementara];
      print('➡️ Pindah ke rubrik $_currentIndex');
    }
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _rubrikSementara.length) {
      _currentIndex = index;
      state = [..._rubrikSementara];
    }
  }

  void clearAll() {
    _rubrikSementara.clear();
    _currentIndex = -1;
    state = [];
    print('🗑️ Semua rubrik dihapus');
  }

  RubrikItem? get currentRubrik {
    if (_currentIndex < 0 || _currentIndex >= _rubrikSementara.length) {
      return null;
    }
    return _rubrikSementara[_currentIndex];
  }

  void resetToNewRubrik() {
    _currentIndex =
        _rubrikSementara.length; // Set ke index setelah yang terakhir
    state = [..._rubrikSementara]; // Notify listeners
    print(
      '🆕 Reset ke rubrik baru. Total: ${_rubrikSementara.length}, CurrentIndex: $_currentIndex',
    );
  }
}
