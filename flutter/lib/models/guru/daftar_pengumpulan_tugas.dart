import 'dart:convert';

class DaftarPengumpulanTugasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<DaftarPengumpulanTugas> data;

  DaftarPengumpulanTugasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory DaftarPengumpulanTugasResponse.fromJson(Map<String, dynamic> json) {
    return DaftarPengumpulanTugasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DaftarPengumpulanTugas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DaftarPengumpulanTugasResponse.fromRawJson(String str) =>
      DaftarPengumpulanTugasResponse.fromJson(json.decode(str));
}

class DaftarPengumpulanTugas {
  final int userIdSiswa;
  final String namaSiswa;
  final int nis;
  final int? pengumpulanTugasId;
  final String? statusPengumpulan;
  final double? nilai;
  final String? feedback;
  final String? tanggalPengumpulan;
  final List<Map<String, dynamic>> filePengumpulanTugas;

  DaftarPengumpulanTugas({
    required this.userIdSiswa,
    required this.namaSiswa,
    required this.nis,
    required this.pengumpulanTugasId,
    required this.statusPengumpulan,
    required this.nilai,
    required this.feedback,
    required this.tanggalPengumpulan,
    required this.filePengumpulanTugas,
  });

  factory DaftarPengumpulanTugas.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> filePengumpulanTugasList = [];

    if (json['file_pengumpulan_tugas'] != null &&
        json['file_pengumpulan_tugas'] is List) {
      filePengumpulanTugasList =
          (json['file_pengumpulan_tugas'] as List).map((file) {
            if (file is Map<String, dynamic>) {
              return file.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              );
            }
            return <String, String>{};
          }).toList();
    }
    return DaftarPengumpulanTugas(
      userIdSiswa: json['user_id_siswa'],
      namaSiswa: json['nama_siswa'],
      nis: json['nis'],
      pengumpulanTugasId: json['pengumpulan_tugas_id'],
      statusPengumpulan: json['status_pengumpulan'] ?? 'Belum Mengumpulkan',
      nilai: json['nilai'] ?? 0,
      feedback: json['feedback'] ?? '',
      tanggalPengumpulan: json['tanggal_pengumpulan'],
      filePengumpulanTugas: filePengumpulanTugasList,
    );
  }
}
