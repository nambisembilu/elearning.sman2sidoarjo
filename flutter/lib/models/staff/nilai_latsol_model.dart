import 'dart:convert';

class NilaiLatsolResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<NilaiLatsol> data;

  NilaiLatsolResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory NilaiLatsolResponse.fromJson(Map<String, dynamic> json) {
    return NilaiLatsolResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NilaiLatsol.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory NilaiLatsolResponse.fromRawJson(String str) =>
      NilaiLatsolResponse.fromJson(json.decode(str));
}

class NilaiLatsol {
  final int kelasId;
  final String nama_kelas;
  final int mapelId;
  final String judul_mapel;
  final int semesterId;
  final int siswaId;
  final int nis;
  final String namaSiswa;
  final List<Map<String, dynamic>> nilaiLatsol; // 🔹 Ubah ke dynamic

  NilaiLatsol({
    required this.kelasId,
    required this.nama_kelas,
    required this.mapelId,
    required this.judul_mapel,
    required this.semesterId,
    required this.siswaId,
    required this.nis,
    required this.namaSiswa,
    required this.nilaiLatsol,
  });

  factory NilaiLatsol.fromJson(Map<String, dynamic> json) {
    // Parse NilaiLatsol
    List<Map<String, dynamic>> listNilaiLatsol = [];
    final nilaiLatsolJson = json['nilai_latsol'];

    if (nilaiLatsolJson != null && nilaiLatsolJson is List) {
      listNilaiLatsol = List<Map<String, dynamic>>.from(
        nilaiLatsolJson.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return NilaiLatsol(
      kelasId: json['kelas_id'] as int,
      nama_kelas: json['nama_kelas'] as String,
      mapelId: json['mapel_id'] as int,
      judul_mapel: json['judul_mapel'] as String,
      semesterId: json['semester_id'] as int,
      siswaId: json['siswa_id'] as int,
      nis: json['nis'] as int,
      namaSiswa: json['nama_siswa'] as String,
      nilaiLatsol: listNilaiLatsol,
    );
  }
}
