import 'dart:convert';

class TugasKelasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<TugasKelas> data;

  TugasKelasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory TugasKelasResponse.fromJson(Map<String, dynamic> json) {
    return TugasKelasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TugasKelas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory TugasKelasResponse.fromRawJson(String str) =>
      TugasKelasResponse.fromJson(json.decode(str));
}

class TugasKelas {
  final int tugasId;
  final String judulTugas;
  final String lingkupMateri;
  final int lingkupMateriId;
  final String deskripsiTugas;
  final String statusTugas;
  final String tanggalDibuat;
  final String tanggalDeadline;
  final int jumlahPengumpulan;
  final int maxFilePengumpulan;
  final int tpTugasId;
  final String tpTugas;
  final List<Map<String, String>> fileTugas;
  final bool? sudahMengumpulkan;
  final int? penumpulanTugasId;
  final double? nilaiTugas;
  final String? statusPengumpulanTugas;
  final List<Map<String, String>> filePengumpulanTugas;

  TugasKelas({
    required this.tugasId,
    required this.judulTugas,
    required this.lingkupMateri,
    required this.lingkupMateriId,
    required this.deskripsiTugas,
    required this.statusTugas,
    required this.tanggalDibuat,
    required this.tanggalDeadline,
    required this.jumlahPengumpulan,
    required this.maxFilePengumpulan,
    required this.tpTugasId,
    required this.tpTugas,
    required this.fileTugas,
    required this.sudahMengumpulkan,
    required this.penumpulanTugasId,
    required this.nilaiTugas,
    required this.statusPengumpulanTugas,
    required this.filePengumpulanTugas,
  });

  factory TugasKelas.fromJson(Map<String, dynamic> json) {
    // Parse file materi - asumsikan struktur JSON yang benar
    List<Map<String, String>> fileTugasList = [];
    List<Map<String, String>> filePengumpulanTugasList = [];

    if (json['file_tugas'] != null && json['file_tugas'] is List) {
      fileTugasList =
          (json['file_tugas'] as List).map((file) {
            if (file is Map<String, dynamic>) {
              return file.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              );
            }
            return <String, String>{};
          }).toList();
    }

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

    return TugasKelas(
      tugasId: json['tugas_id'] as int,
      judulTugas: json['judul'] as String,
      deskripsiTugas: json['deskripsi'] as String,
      lingkupMateri: json['lingkup_materi'] as String,
      lingkupMateriId: json['lingkup_materi_id'] as int,
      tanggalDeadline: json['deadline'] as String,
      statusTugas: json['status_tugas'] as String,
      tanggalDibuat: json['tanggal_dibuat'] as String,
      jumlahPengumpulan: json['jumlah_pengumpulan'] as int,
      maxFilePengumpulan: json['max_file_pengumpulan'] as int,
      tpTugasId: json['tujuan_pembelajaran_id'] as int,
      tpTugas: json['tujuan_pembelajaran'] as String,
      fileTugas: fileTugasList,
      sudahMengumpulkan: json['sudah_mengumpulkan'] ?? false,
      penumpulanTugasId:
          json['pengumpulan_tugas_id'] == null
              ? null
              : json['pengumpulan_tugas_id'] as int,

      nilaiTugas:
          json['nilai_tugas'] == null
              ? null
              : (json['nilai_tugas'] as num).toDouble(),

      statusPengumpulanTugas: json['status_pengumpulan_tugas'] as String?,
      filePengumpulanTugas: filePengumpulanTugasList,
    );
  }
}
