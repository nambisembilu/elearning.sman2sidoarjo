import 'dart:convert';

class KelasSiswaResponse {
  final String namaKelas;
  final int total;
  final List<KelasSiswa> data;

  KelasSiswaResponse({
    required this.namaKelas,
    required this.total,
    required this.data,
  });

  factory KelasSiswaResponse.fromJson(Map<String, dynamic> json) {
    return KelasSiswaResponse(
      namaKelas: json['nama_kelas'] ?? '',
      total: json['total'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => KelasSiswa.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory KelasSiswaResponse.fromRawJson(String str) =>
      KelasSiswaResponse.fromJson(json.decode(str));
}

class KelasSiswa {
  final int kelasMapelId;
  final String judulMapel;
  final String guruPengampu;
  final int jumlahMateri;
  final int jumlahTugas;
  final int jumlahUjian;
  final int jumlahLatihanSoal;

  KelasSiswa({
    required this.kelasMapelId,
    required this.judulMapel,
    required this.guruPengampu,
    required this.jumlahMateri,
    required this.jumlahTugas,
    required this.jumlahUjian,
    required this.jumlahLatihanSoal});

  factory KelasSiswa.fromJson(Map<String, dynamic> json) {
    return KelasSiswa(
      kelasMapelId: json['kelas_mapel_id'] as int? ?? 0,
      judulMapel: json['judul_mapel']?.toString() ?? '',
      guruPengampu: json['guru_pengampu']?.toString() ?? '',
      jumlahMateri: json['jumlah_materi'] as int? ?? 0,
      jumlahTugas: json['jumlah_tugas'] as int? ?? 0,
      jumlahUjian: json['jumlah_ujian'] as int? ?? 0,
      jumlahLatihanSoal: json['jumlah_latihan_soal'] as int? ?? 0
    );
  }
}
