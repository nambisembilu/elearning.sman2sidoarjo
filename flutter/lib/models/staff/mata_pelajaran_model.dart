import 'dart:convert';

class MataPelajaranResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<MataPelajaran> data;

  MataPelajaranResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory MataPelajaranResponse.fromJson(Map<String, dynamic> json) {
    return MataPelajaranResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => MataPelajaran.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory MataPelajaranResponse.fromRawJson(String str) =>
      MataPelajaranResponse.fromJson(json.decode(str));
}

class MataPelajaran {
  final int id;
  final String kode;
  final String namaMapel;
  final String jenjang;
  final String jurusan;
  final String? koorMapel;

  MataPelajaran({
    required this.id,
    required this.kode,
    required this.namaMapel,
    required this.jenjang,
    required this.jurusan,
    required this.koorMapel
  });

  factory MataPelajaran.fromJson(Map<String, dynamic> json) {
    return MataPelajaran(
      id: json['Id'] as int? ?? 0,
      kode: json['Kode'],
      namaMapel: json['Nama Mata Pelajaran'],
      jenjang: json['Jenjang'],
      jurusan: json['Jurusan'],
      koorMapel: json['Koor Mapel']
    );
  }
}
