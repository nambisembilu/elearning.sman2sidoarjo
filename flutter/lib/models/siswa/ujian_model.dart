import 'dart:convert';

class UjianResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<UjianKelas> data;

  UjianResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory UjianResponse.fromJson(Map<String, dynamic> json) {
    return UjianResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => UjianKelas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory UjianResponse.fromRawJson(String str) =>
      UjianResponse.fromJson(json.decode(str));
}

class UjianKelas {
  final int ujianId;
  final String judulDefault;
  final String deskripsi;
  final String statusUjian;
  final String statusNilai;
  final String tanggalDibuat;
  final String tanggalujian;
  final String jamMulai;
  final String jamSelesai;
  final int jumlahSoal;

  UjianKelas({
    required this.ujianId,
    required this.judulDefault,
    required this.deskripsi,
    required this.statusUjian,
    required this.statusNilai,
    required this.tanggalDibuat,
    required this.tanggalujian,
    required this.jamMulai,
    required this.jamSelesai,
    required this.jumlahSoal,
  });

  factory UjianKelas.fromJson(Map<String, dynamic> json) {
    return UjianKelas(
      ujianId: json['ujian_id'] as int,
      judulDefault: json['judul_default'] as String,
      deskripsi: json['deskripsi'] as String,
      statusUjian: json['status_ujian'] as String,
      statusNilai: json['status_nilai'] as String,
      tanggalDibuat: json['tanggal_dibuat'] as String,
      tanggalujian: json['tanggal_ujian'] as String,
      jamMulai: json['jam_mulai'] as String,
      jamSelesai: json['jam_selesai'] as String,
      jumlahSoal: json['jumlah_soal'] as int,
    );
  }
}
