import 'dart:convert';

class DaftarPengerjaanUjianResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<DaftarPengerjaanUjian> data;

  DaftarPengerjaanUjianResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory DaftarPengerjaanUjianResponse.fromJson(Map<String, dynamic> json) {
    return DaftarPengerjaanUjianResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => DaftarPengerjaanUjian.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory DaftarPengerjaanUjianResponse.fromRawJson(String str) =>
      DaftarPengerjaanUjianResponse.fromJson(json.decode(str));
}

class DaftarPengerjaanUjian {
  final int userIdSiswa;
  final String namaSiswa;
  final int nis;
  final double? nilai;
  final bool sudahMengerjakan;

  DaftarPengerjaanUjian({
    required this.userIdSiswa,
    required this.namaSiswa,
    required this.nis,
    required this.nilai,
    required this.sudahMengerjakan,
  });

  factory DaftarPengerjaanUjian.fromJson(Map<String, dynamic> json) {
    return DaftarPengerjaanUjian(
      userIdSiswa: json['user_id_siswa'],
      namaSiswa: json['nama_siswa'],
      nis: json['nis'],
      nilai: json['nilai_akhir'] ?? 0,
      sudahMengerjakan: json['sudah_mengerjakan'] ?? false,
    );
  }
}
