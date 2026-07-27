import 'dart:async';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:io';
import '../../../models/staff/data_siswa_model.dart';
import '../../../models/staff/filtering_model.dart';
import '../../../services/staff/data_siswa_service.dart';
import '../../../services/staff/filter_data_service.dart';

part 'data_siswa_riverpod.g.dart';

@riverpod
class DataSiswaNotifier extends _$DataSiswaNotifier {
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String _lastSearch = '';
  int _total = 0;
  int _totalPage = 1;

  int? _tahunAjaranId;
  String _jenjang = 'Semua Jenjang';
  String _jurusan = 'Semua Jurusan';

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get total => _total;
  int get totalPage => _totalPage;

  List<Siswa> lastSiswaList = [];

  @override
  FutureOr<List<Siswa>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = '';

    final service = SiswaService(Supabase.instance.client);
    final res = await service.getAllSiswa(
      page: _currentPage,
      search: _lastSearch,
      tahun_ajaran_id: _tahunAjaranId,
      jenjang: _jenjang,
      jurusan: _jurusan,
    );

    _hasMore = _currentPage < res.totalPage;
    _total = res.total;
    _totalPage = res.totalPage;
    lastSiswaList = res.data;

    return res.data;
  }

  Future<void> resetAndFetch({
    String search = '',
    int page = 1,
    int? tahunAjaranId,
    String jenjang = 'Semua Jenjang',
    String jurusan = 'Semua Jurusan',
  }) async {
    _currentPage = page;
    _hasMore = true;
    _isLoadingMore = false;
    _lastSearch = search;
    _tahunAjaranId = tahunAjaranId;
    _jenjang = jenjang;
    _jurusan = jurusan;

    state = const AsyncLoading<List<Siswa>>().copyWithPrevious(state);

    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
      jenjang: _jenjang,
      jurusan: _jurusan,
      reset: true,
    );
  }

  Future<void> filterDataSiswa({
    required int? pTahunAjaranId,
    required String? pJenjang,
    required String? pJurusan,
  }) async {
    try {
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        reset: true,
        tahunAjaranId: pTahunAjaranId,
        jenjang: pJenjang ?? _jenjang,
        jurusan: pJurusan ?? _jurusan,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      await _fetch(
        page: _currentPage,
        search: _lastSearch,
        tahunAjaranId: _tahunAjaranId,
        jenjang: _jenjang,
        jurusan: _jurusan,
        reset: true,
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchPreviousPage() async {
    if (_currentPage <= 1) return;
    _currentPage--;
    await _fetch(
      page: _currentPage,
      search: _lastSearch,
      tahunAjaranId: _tahunAjaranId,
      jenjang: _jenjang,
      jurusan: _jurusan,
      reset: true,
    );
  }

  Future<void> _fetch({
    required int page,
    required String search,
    required bool reset,
    required int? tahunAjaranId,
    required String jenjang,
    required String jurusan,
  }) async {
    final service = SiswaService(Supabase.instance.client);

    try {
      final res = await service.getAllSiswa(
        page: page,
        search: search,
        tahun_ajaran_id: tahunAjaranId,
        jenjang: jenjang,
        jurusan: jurusan,
      );
      _hasMore = page < res.totalPage;
      _total = res.total;
      _totalPage = res.totalPage;
      lastSiswaList = res.data;

      state = AsyncData<List<Siswa>>(res.data);
    } catch (e, st) {
      state = AsyncError<List<Siswa>>(e, st);
    }
  }

  // ✅ Fetch Tahun Ajaran
  Future<List<TahunAjaran>> fetchTahunAjaran() async {
    final service = FilteringDataService(Supabase.instance.client);
    final res = await service.getTahunAjaran();
    return res;
  }

  Future<bool> addSiswa({
    required int nis,
    required int nisn,
    required String nama,
    required String? jenisKelamin,
    required String? agama,
    required String email,
    required int nomorTelepon,
    required String alamat,
    required int? kelasId,
    String? statusWaliMurid,
    String? namaWaliMurid,
    String? alamatWaliMurid,
    int? noTelpWaliMurid,
  }) async {
    final service = SiswaService(Supabase.instance.client);

    try {
      await service.addSiswa(
        nis: nis,
        nisn: nisn,
        nama: nama,
        jenisKelamin: jenisKelamin,
        agama: agama,
        email: email,
        nomorTelepon: nomorTelepon,
        alamat: alamat,
        kelasId: kelasId,
        statusWaliMurid: statusWaliMurid,
        namaWaliMurid: namaWaliMurid,
        alamatWaliMurid: alamatWaliMurid,
        noTelpWaliMurid: noTelpWaliMurid,
      );

      await resetAndFetch(search: _lastSearch, page: 1);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Siswa>>(e, st);
      return false;
    }
  }

  Future<bool> updateSiswa({
    required int userId,
    required int nis,
    required int nisn,
    required String nama,
    required String? jenisKelamin,
    required String? agama,
    required String email,
    required int nomorTelepon,
    required String alamat,
    required int? kelasId,
    String? statusWaliMurid,
    String? namaWaliMurid,
    String? alamatWaliMurid,
    int? noTelpWaliMurid,
  }) async {
    final service = SiswaService(Supabase.instance.client);

    try {
      await service.updateSiswa(
        userId: userId,
        nis: nis,
        nisn: nisn,
        nama: nama,
        jenisKelamin: jenisKelamin,
        agama: agama,
        email: email,
        nomorTelepon: nomorTelepon,
        alamat: alamat,
        kelasId: kelasId,
        statusWaliMurid: statusWaliMurid,
        namaWaliMurid: namaWaliMurid,
        alamatWaliMurid: alamatWaliMurid,
        noTelpWaliMurid: noTelpWaliMurid,
      );

      await resetAndFetch(search: _lastSearch, page: _currentPage);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Siswa>>(e, st);
      return false;
    }
  }

  Future<bool> deleteSiswa({required int userId}) async {
    final service = SiswaService(Supabase.instance.client);

    try {
      await service.deleteSiswa(userId: userId);

      // Refresh list siswa setelah tambah
      await resetAndFetch(search: _lastSearch, page: _currentPage);
      return true;
    } catch (e, st) {
      state = AsyncError<List<Siswa>>(e, st);
      return false;
    }
  }

  Future<String> importSiswa({
    required List<int> nis,
    required List<int> nisn,
    required List<String> namaSiswa,
    required List<String> jenisKelamin,
    required List<String> namaKelas,
    required List<String> jenjangPendidikan,
    required List<String> jurusan,
    required List<String> alamat,
    required List<String> agama,
    required List<int> noTelp,
    required List<String> email,
  }) async {
    final service = SiswaService(Supabase.instance.client);

    try {
      final result = await service.importSiswa(
        nis: nis,
        nisn: nisn,
        namaSiswa: namaSiswa,
        jenisKelamin: jenisKelamin,
        namaKelas: namaKelas,
        jenjangPendidikan: jenjangPendidikan,
        jurusan: jurusan,
        alamat: alamat,
        agama: agama,
        noTelp: noTelp,
        email: email,
      );

      // Refresh data setelah impor
      await resetAndFetch(search: _lastSearch, page: 1);

      return result;
    } catch (e, st) {
      state = AsyncError<List<Siswa>>(e, st);
      return 'Error: $e';
    }
  }

  Future<String?> pickAndImportExcel() async {
    try {
      // Pilih file Excel
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) {
        print('❌ Tidak ada file dipilih');
        return null;
      }

      // Ambil bytes file
      final Uint8List bytes =
          result.files.single.bytes ??
          await File(result.files.single.path!).readAsBytes();

      // Decode file Excel
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      // Ambil hanya baris mulai dari baris ke-7 yang tidak semuanya kosong
      final dataRows = rows.skip(6).where((row) {
        return row.any(
          (cell) =>
              cell?.value != null && cell!.value.toString().trim().isNotEmpty,
        );
      }).toList();

      if (dataRows.isEmpty) {
        return 'Tidak ada data valid di file Excel';
      }

      // Siapkan list untuk tiap kolom
      final List<int> nisList = [];
      final List<int> nisnList = [];
      final List<String> namaList = [];
      final List<String> jenisKelaminList = [];
      final List<String> namaKelasList = [];
      final List<String> jenjangPendidikanList = [];
      final List<String> jurusanList = [];
      final List<String> alamatList = [];
      final List<String> agamaList = [];
      final List<int> noTelpList = [];
      final List<String> emailList = [];

      // Loop untuk baca setiap baris
      for (final row in dataRows) {
        final nis = int.tryParse(row[2]?.value.toString() ?? '') ?? 0;
        final nisn = int.tryParse(row[4]?.value.toString() ?? '') ?? 0;
        final namaSiswa = row[1]?.value.toString().trim() ?? '';
        final rowJenisKelamin = row[3]?.value.toString().trim() ?? '';
        final alamat = row[9]?.value.toString().trim() ?? '';
        final agama = row[8]?.value.toString().trim() ?? '';
        final email = row[20]?.value.toString().trim() ?? '';
        final noTelp = int.tryParse(row[19]?.value.toString() ?? '') ?? 0;
        final namaKelas = row[42]?.value.toString().trim() ?? '';

        if (nis == 0 || nisn == 0 || namaSiswa.isEmpty) continue;

        final jenisKelamin = (rowJenisKelamin.toUpperCase() == 'P')
            ? 'Perempuan'
            : 'Laki-Laki';

        String jenjangPendidikan;
        if (namaKelas.startsWith('XII')) {
          jenjangPendidikan = '12';
        } else if (namaKelas.startsWith('XI')) {
          jenjangPendidikan = '11';
        } else {
          jenjangPendidikan = '10';
        }

        String jurusan;
        if (namaKelas.toUpperCase().contains('MIPA')) {
          jurusan = 'MIPA';
        } else if (namaKelas.toUpperCase().contains('IPS')) {
          jurusan = 'IPS';
        } else if (namaKelas.toUpperCase().contains('BAHASA')) {
          jurusan = 'BAHASA';
        } else {
          jurusan = 'Fase E';
        }

        nisList.add(nis);
        nisnList.add(nisn);
        namaList.add(namaSiswa);
        jenisKelaminList.add(jenisKelamin);
        namaKelasList.add(namaKelas);
        jenjangPendidikanList.add(jenjangPendidikan);
        jurusanList.add(jurusan);
        alamatList.add(alamat);
        agamaList.add(agama);
        noTelpList.add(noTelp);
        emailList.add(email);
      }

      if (nisList.isEmpty) {
        return 'Tidak ada data siswa valid untuk diimpor';
      }

      final service = SiswaService(Supabase.instance.client);
      final resultMessage = await service.importSiswa(
        nis: nisList,
        nisn: nisnList,
        namaSiswa: namaList,
        jenisKelamin: jenisKelaminList,
        namaKelas: namaKelasList,
        jenjangPendidikan: jenjangPendidikanList,
        jurusan: jurusanList,
        alamat: alamatList,
        agama: agamaList,
        noTelp: noTelpList,
        email: emailList,
      );

      await resetAndFetch(search: _lastSearch, page: 1);

      print('✅ Import selesai: $resultMessage');
      return resultMessage;
    } catch (e, st) {
      print('❌ Gagal impor data: $e');
      print(st);
      return 'Terjadi kesalahan: $e';
    }
  }
}
