import 'dart:convert';

import 'package:intl/intl.dart';

class MateriKelasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<MateriKelas> data;

  MateriKelasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory MateriKelasResponse.fromJson(Map<String, dynamic> json) {
    return MateriKelasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => MateriKelas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory MateriKelasResponse.fromRawJson(String str) =>
      MateriKelasResponse.fromJson(json.decode(str));
}

class MateriKelas {
  final int materiId;
  final String judulMateri;
  final String lingkupMateri;
  final int lingkupMateriId;
  final String deskripsiMateri;
  final String statusMateri;
  final String tanggalDibuat;
  final List<Map<String, String>> fileMateri;

  MateriKelas({
    required this.materiId,
    required this.judulMateri,
    required this.lingkupMateri,
    required this.lingkupMateriId,
    required this.deskripsiMateri,
    required this.statusMateri,
    required this.tanggalDibuat,
    required this.fileMateri,
  });

  factory MateriKelas.fromJson(Map<String, dynamic> json) {
    // Parse file materi - asumsikan struktur JSON yang benar
    List<Map<String, String>> fileMateriList = [];

    if (json['file_materi'] != null && json['file_materi'] is List) {
      fileMateriList =
          (json['file_materi'] as List).map((file) {
            if (file is Map<String, dynamic>) {
              return file.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              );
            }
            return <String, String>{};
          }).toList();
    }

    // Format tanggal
    String formattedDate = '';
    if (json['tanggal_dibuat'] != null) {
      final parsedDate = DateTime.parse(json['tanggal_dibuat']);
      formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    }

    return MateriKelas(
      materiId: json['materi_id'] as int,
      judulMateri: json['judul_materi'] as String,
      lingkupMateri: json['lingkup_materi'] as String,
      lingkupMateriId: json['lingkup_materi_id'] as int,
      deskripsiMateri: json['deskripsi_materi'] as String,
      statusMateri: json['status_materi'] as String,
      tanggalDibuat: formattedDate,
      fileMateri: fileMateriList,
    );
  }
}
