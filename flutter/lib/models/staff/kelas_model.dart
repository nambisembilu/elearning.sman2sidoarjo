import 'dart:convert';

class KelasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<Kelas> data;

  KelasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory KelasResponse.fromJson(Map<String, dynamic> json) {
    return KelasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Kelas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory KelasResponse.fromRawJson(String str) =>
      KelasResponse.fromJson(json.decode(str));
}

class Kelas {
  final int kelasId;
  final String jenjang;
  final String jurusan;
  final String namaKelas;
  final List<Map<String, String>> waliKelas;
  final String ruangKelas;
  final int jumlahSiswa;

  Kelas({
    required this.kelasId,
    required this.jenjang,
    required this.jurusan,
    required this.namaKelas,
    required this.waliKelas,
    required this.ruangKelas,
    required this.jumlahSiswa,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    // Parse Kelas (object tunggal → bungkus ke list)
    List<Map<String, String>> infoWaliKelas = [];
    final kelasJson = json['wali_kelas'];
    if (kelasJson != null && kelasJson is Map) {
      infoWaliKelas = [
        Map<String, String>.from(
          kelasJson.map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
        ),
      ];
    }

    return Kelas(
      kelasId: json['id'] as int? ?? 0,
      jenjang: json['jenjang_pendidikan'],
      jurusan: json['jurusan'],
      namaKelas: json['nama_kelas'],
      waliKelas: infoWaliKelas,
      ruangKelas: json['ruang_kelas'],
      jumlahSiswa: json['jumlah_siswa'] as int? ?? 0,
    );
  }
}
