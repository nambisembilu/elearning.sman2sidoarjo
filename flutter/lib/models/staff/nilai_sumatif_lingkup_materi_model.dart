import 'dart:convert';

class NilaiSumatifLMResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<NilaiSumatifLM> data;

  NilaiSumatifLMResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory NilaiSumatifLMResponse.fromJson(Map<String, dynamic> json) {
    return NilaiSumatifLMResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NilaiSumatifLM.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory NilaiSumatifLMResponse.fromRawJson(String str) =>
      NilaiSumatifLMResponse.fromJson(json.decode(str));
}

class NilaiSumatifLM {
  final int kelasId;
  final String namaKelas;
  final int mapelId;
  final String judulMapel;
  final int semesterId;
  final int siswaId;
  final int nis;
  final String namaSiswa;
  final List<Map<String, dynamic>> nilai_sumatif_lm; // 🔹 Ubah ke dynamic

  NilaiSumatifLM({
    required this.kelasId,
    required this.namaKelas,
    required this.mapelId,
    required this.judulMapel,
    required this.semesterId,
    required this.siswaId,
    required this.nis,
    required this.namaSiswa,
    required this.nilai_sumatif_lm,
  });

  factory NilaiSumatifLM.fromJson(Map<String, dynamic> json) {
    // Parse NilaiTugas
    List<Map<String, dynamic>> listNilaiSumatifLM = [];
    final nilaiSumatifLMJson = json['nilai_sumatif_lingkup_materi'];

    if (nilaiSumatifLMJson != null && nilaiSumatifLMJson is List) {
      listNilaiSumatifLM = List<Map<String, dynamic>>.from(
        nilaiSumatifLMJson.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return NilaiSumatifLM(
      kelasId: json['kelas_id'] as int,
      namaKelas: json['nama_kelas'] as String,
      mapelId: json['mapel_id'] as int,
      judulMapel: json['judul_mapel'] as String,
      semesterId: json['semester_id'] as int,
      siswaId: json['siswa_id'] as int,
      nis: json['nis'] as int,
      namaSiswa: json['nama_siswa'] as String,
      nilai_sumatif_lm: listNilaiSumatifLM,
    );
  }
}
