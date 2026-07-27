import 'dart:convert';

class SiswaKelasResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<SiswaKelas> data;

  SiswaKelasResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory SiswaKelasResponse.fromJson(Map<String, dynamic> json) {
    return SiswaKelasResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => SiswaKelas.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory SiswaKelasResponse.fromRawJson(String str) =>
      SiswaKelasResponse.fromJson(json.decode(str));
}

class SiswaKelas {
  final int userIdSiswa;
  final int siswaId;
  final int nis;
  final int nisn;
  final String namaSiswa;
  final int noTelpSiswa;
  final String emailSiswa;

  SiswaKelas({
    required this.userIdSiswa,
    required this.siswaId,
    required this.nis,
    required this.nisn,
    required this.namaSiswa,
    required this.noTelpSiswa,
    required this.emailSiswa
  });

  factory SiswaKelas.fromJson(Map<String, dynamic> json) {
    return SiswaKelas(
      userIdSiswa: json['user_id'] as int,
      siswaId: json['siswa_id'] as int,
      nis: json['nis'] as int,
      nisn: json['nisn'] as int,
      namaSiswa: json['nama'] as String,
      noTelpSiswa: json['no_telp'],
      emailSiswa: json['email'] as String
    );
  }
}
