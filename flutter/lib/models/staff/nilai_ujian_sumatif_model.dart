import 'dart:convert';

class NilaiUjianSumatifResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<NilaiUjianSumatif> data;

  NilaiUjianSumatifResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory NilaiUjianSumatifResponse.fromJson(Map<String, dynamic> json) {
    return NilaiUjianSumatifResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NilaiUjianSumatif.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory NilaiUjianSumatifResponse.fromRawJson(String str) =>
      NilaiUjianSumatifResponse.fromJson(json.decode(str));
}

class NilaiUjianSumatif {
  final int kelasId;
  final int semesterId;
  final int siswaId;
  final int nis;
  final String namaSiswa;
  // final double rataRataNilai;
  final List<Map<String, dynamic>> nilaiUjianSiswa; // 🔹 Ubah ke dynamic

  NilaiUjianSumatif({
    required this.kelasId,
    required this.semesterId,
    required this.siswaId,
    required this.nis,
    required this.namaSiswa,
    // required this.rataRataNilai,
    required this.nilaiUjianSiswa,
  });

  factory NilaiUjianSumatif.fromJson(Map<String, dynamic> json) {
    // Parse NilaiUjianSumatif
    List<Map<String, dynamic>> listNilaiUjianSumatif = [];
    final NilaiUjianSumatifJson = json['nilai_ujian_siswa'];

    if (NilaiUjianSumatifJson != null && NilaiUjianSumatifJson is List) {
      listNilaiUjianSumatif = List<Map<String, dynamic>>.from(
        NilaiUjianSumatifJson.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return NilaiUjianSumatif(
      kelasId: json['kelas_id'] as int,
      semesterId: json['semester_id'] as int,
      siswaId: json['siswa_id'] as int,
      nis: json['nis'] as int,
      namaSiswa: json['nama_siswa'] as String,
      // rataRataNilai: json['rata_rata_nilai'] as double,
      nilaiUjianSiswa: listNilaiUjianSumatif,
    );
  }
}
