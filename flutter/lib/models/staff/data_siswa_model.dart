import 'dart:convert';

class SiswaResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<Siswa> data;

  SiswaResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory SiswaResponse.fromJson(Map<String, dynamic> json) {
    return SiswaResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Siswa.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory SiswaResponse.fromRawJson(String str) =>
      SiswaResponse.fromJson(json.decode(str));
}

class Siswa {
  final int userId;
  final int nis;
  final int nisn;
  final String nama;
  final List<Map<String, String>> kelas;
  final String agama;
  final String jenisKelamin;
  final int nomorTelepon;
  final String email;
  final String alamat;
  final List<Map<String, String>> waliMurid;

  Siswa({
    required this.userId,
    required this.nis,
    required this.nisn,
    required this.nama,
    required this.kelas,
    required this.agama,
    required this.jenisKelamin,
    required this.nomorTelepon,
    required this.email,
    required this.alamat,
    List<Map<String, String>>? waliMurid,
  }) : waliMurid = waliMurid ?? [];

  factory Siswa.fromJson(Map<String, dynamic> json) {
    // Parse Kelas (object tunggal → bungkus ke list)
    List<Map<String, String>> kelasList = [];
    final kelasJson = json['Kelas'];
    if (kelasJson != null && kelasJson is Map) {
      kelasList = [
        Map<String, String>.from(
          kelasJson.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        ),
      ];
    }

    // Parse Wali Murid (boleh null atau object tunggal → bungkus ke list)
    List<Map<String, String>> waliMuridList = [];
    final waliJson = json['Wali Murid'];
    if (waliJson != null && waliJson is Map) {
      waliMuridList = [
        Map<String, String>.from(
          waliJson.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        ),
      ];
    }

    return Siswa(
      userId: json['User ID'] as int? ?? 0,
      nis: json['NIS'] as int? ?? 0,
      nisn: json['NISN'] as int? ?? 0,
      nama: json['Nama'],
      kelas: kelasList,
      agama: json['Agama'],
      jenisKelamin: json['Jenis Kelamin'],
      nomorTelepon: json['Nomor Telepon'] as int? ?? 0,
      email: json['Email'],
      alamat: json['Alamat'],
      waliMurid: waliMuridList,
    );
  }
}
