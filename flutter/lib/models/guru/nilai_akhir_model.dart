import 'dart:convert';

class NilaiAkhirResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<NilaiAkhir> data;

  NilaiAkhirResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory NilaiAkhirResponse.fromJson(Map<String, dynamic> json) {
    return NilaiAkhirResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NilaiAkhir.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory NilaiAkhirResponse.fromRawJson(String str) =>
      NilaiAkhirResponse.fromJson(json.decode(str));
}

class NilaiAkhir {
  final int kelasId;
  final String namaKelas;
  final int mapelId;
  final String judulMapel;
  final int tahunAjaranId;
  final int semesterId;
  final int siswaId;
  final int nis;
  final int nisn;
  final String namaSiswa;
  final double nilaiAkhir;
  final String? cpTertinggi;
  final String? cpTerendah;

  NilaiAkhir({
    required this.kelasId,
    required this.namaKelas,
    required this.mapelId,
    required this.judulMapel,
    required this.tahunAjaranId,
    required this.semesterId,
    required this.siswaId,
    required this.nis,
    required this.nisn,
    required this.namaSiswa,
    required this.nilaiAkhir,
    required this.cpTertinggi,
    required this.cpTerendah,
  });

  factory NilaiAkhir.fromJson(Map<String, dynamic> json) {
    double parseNilai(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return NilaiAkhir(
      kelasId: json['kelas_id'] ?? 0,
      namaKelas: json['nama_kelas'] ?? '',
      mapelId: json['mapel_id'] ?? 0,
      judulMapel: json['judul_mapel'] ?? '',
      tahunAjaranId: json['tahun_ajaran_id'] ?? 0,
      semesterId: json['semester_id'] ?? 0,
      siswaId: json['siswa_id'] ?? 0,
      nis: json['nis'] ?? 0,
      nisn: json['nisn'] ?? 0,
      namaSiswa: json['nama_siswa'] ?? '',
      nilaiAkhir: parseNilai(json['nilai_akhir']),
      cpTertinggi: json['capaian_tertinggi'] as String?,
      cpTerendah: json['capaian_terendah'] as String?,
    );
  }
}
