import 'dart:convert';

import 'package:intl/intl.dart';

class JadwalAkademikResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<JadwalAkademik> data;

  JadwalAkademikResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory JadwalAkademikResponse.fromJson(Map<String, dynamic> json) {
    return JadwalAkademikResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => JadwalAkademik.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory JadwalAkademikResponse.fromRawJson(String str) =>
      JadwalAkademikResponse.fromJson(json.decode(str));
}

class JadwalAkademik {
  final int id;
  final String namaKegiatan;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int tahunAjaranId;
  final String statusKegiatan;

  JadwalAkademik({
    required this.id,
    required this.namaKegiatan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.tahunAjaranId,
    required this.statusKegiatan,
  });

  factory JadwalAkademik.fromJson(Map<String, dynamic> json) {
    final formatter = DateFormat(
      "dd-MM-yyyy",
    ); // karena response pakai dd-MM-yyyy

    return JadwalAkademik(
      id: json['Id'] as int? ?? 0,
      namaKegiatan: json['Nama Kegiatan'],
      tanggalMulai: formatter.parse(json['Tanggal Mulai']),
      tanggalSelesai: formatter.parse(json['Tanggal Selesai']),
      tahunAjaranId: json['Tahun Ajaran ID'],
      statusKegiatan: json['Status Kegiatan'],
    );
  }

  String get tanggalMulaiFormatted =>
      DateFormat("dd-MM-yyyy").format(tanggalMulai);

  String get tanggalSelesaiFormatted =>
      DateFormat("dd-MM-yyyy").format(tanggalSelesai);
}
