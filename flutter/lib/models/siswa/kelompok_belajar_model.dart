import 'dart:convert';

class KelompokBelajarResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<KelompokBelajar> data;

  KelompokBelajarResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory KelompokBelajarResponse.fromJson(Map<String, dynamic> json) {
    return KelompokBelajarResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => KelompokBelajar.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory KelompokBelajarResponse.fromRawJson(String str) =>
      KelompokBelajarResponse.fromJson(json.decode(str));
}

class KelompokBelajar {
  final int kelompokBelajarId;
  final String namaKelompok;
  final int jumlahAnggota;
  final List<Map<String, dynamic>> anggotaKelompok;

  KelompokBelajar({
    required this.kelompokBelajarId,
    required this.namaKelompok,
    required this.jumlahAnggota,
    required this.anggotaKelompok
  });

  factory KelompokBelajar.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> anggotaKelompokList = [];

    if (json['anggota_kelompok'] != null && json['anggota_kelompok'] is List) {
      anggotaKelompokList =
          (json['anggota_kelompok'] as List).map((file) {
            if (file is Map<String, dynamic>) {
              return file.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              );
            }
            return <String, String>{};
          }).toList();
    }
    return KelompokBelajar(
      kelompokBelajarId: json['kelompok_belajar_id'] as int,
      namaKelompok: json['nama_kelompok'] as String,
      jumlahAnggota: json['jumlah_anggota'] as int,
      anggotaKelompok: anggotaKelompokList,
    );
  }
}
