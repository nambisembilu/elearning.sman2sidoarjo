import 'dart:convert';

class NilaiTugasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<NilaiTugas> data;

  NilaiTugasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory NilaiTugasResponse.fromJson(Map<String, dynamic> json) {
    return NilaiTugasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NilaiTugas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory NilaiTugasResponse.fromRawJson(String str) =>
      NilaiTugasResponse.fromJson(json.decode(str));
}

class NilaiTugas {
  final int kelasMapelId;
  final int semesterId;
  final String namaKelas;
  final String judulMapel;
  final int siswaId;
  final int nis;
  final String namaSiswa;
  final List<Map<String, dynamic>> nilaiTugas; // 🔹 Ubah ke dynamic

  NilaiTugas({
    required this.kelasMapelId,
    required this.semesterId,
    required this.namaKelas,
    required this.judulMapel,
    required this.siswaId,
    required this.nis,
    required this.namaSiswa,
    required this.nilaiTugas,
  });

  factory NilaiTugas.fromJson(Map<String, dynamic> json) {
    // Parse NilaiTugas
    List<Map<String, dynamic>> listNilaiTugas = [];
    final nilaiTugasJson = json['nilai_tugas'];

    if (nilaiTugasJson != null && nilaiTugasJson is List) {
      listNilaiTugas = List<Map<String, dynamic>>.from(
        nilaiTugasJson.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return NilaiTugas(
      kelasMapelId: json['kmp_id'] as int,
      semesterId: json['semester_id'] as int,
      namaKelas: json['nama_kelas'] as String,
      judulMapel: json['judul_mapel'] as String,
      siswaId: json['siswa_id'] as int,
      nis: json['nis'] as int,
      namaSiswa: json['nama_siswa'] as String,
      nilaiTugas: listNilaiTugas,
    );
  }
}
