import 'dart:convert';

class KelasGuruResponse {
  final int total;
  final List<KelasGuru> data;

  KelasGuruResponse({
    required this.total,
    required this.data,
  });

  factory KelasGuruResponse.fromJson(Map<String, dynamic> json) {
    return KelasGuruResponse(
      total: json['total'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => KelasGuru.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory KelasGuruResponse.fromRawJson(String str) =>
      KelasGuruResponse.fromJson(json.decode(str));
}

class KelasGuru {
  final int kelasMapelId;
  final String namaKelas;
  final String judulMapel;
  final String namaWaliKelas;
  final String jadwal;
  final int jumlahSiswa;
  final int jumlahMateri;
  final int jumlahTugas;
  final int jumlahUjian;
  final int jumlahLatihanSoal;

  KelasGuru({
    required this.kelasMapelId,
    required this.namaKelas,
    required this.judulMapel,
    required this.namaWaliKelas,
    required this.jadwal,
    required this.jumlahSiswa,
    required this.jumlahMateri,
    required this.jumlahTugas,
    required this.jumlahUjian,
    required this.jumlahLatihanSoal});

  factory KelasGuru.fromJson(Map<String, dynamic> json) {
    return KelasGuru(
      kelasMapelId: json['kelas_mapel_id'] as int? ?? 0,
      namaKelas: json['nama_kelas']?.toString() ?? '',
      judulMapel: json['judul_mapel']?.toString() ?? '',
      namaWaliKelas: json['nama_wali_kelas']?.toString() ?? '',
      jadwal: json['jadwal']?.toString() ?? '',
      jumlahSiswa: json['jumlah_siswa'] as int? ?? 0,
      jumlahMateri: json['jumlah_materi'] as int? ?? 0,
      jumlahTugas: json['jumlah_tugas'] as int? ?? 0,
      jumlahUjian: json['jumlah_ujian'] as int? ?? 0,
      jumlahLatihanSoal: json['jumlah_latihan_soal'] as int? ?? 0
    );
  }
}
