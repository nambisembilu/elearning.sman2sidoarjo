import 'dart:convert';

class GuruResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<Guru> data;

  GuruResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory GuruResponse.fromJson(Map<String, dynamic> json) {
    return GuruResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Guru.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory GuruResponse.fromRawJson(String str) =>
      GuruResponse.fromJson(json.decode(str));
}

class Guru {
  final int userId;
  final int nipNuptk;
  final String nama;
  final List<Map<String, String>> mataPelajaran;
  final int nomorTelepon;
  final String? email;
  final String alamat;
  final List<Map<String, String>> jadwalMengajar;

  Guru({
    required this.userId,
    required this.nipNuptk,
    required this.nama,
    List<Map<String, String>>? mataPelajaran,
    required this.nomorTelepon,
    this.email,
    required this.alamat,
    List<Map<String, String>>? jadwalMengajar,
  }) : mataPelajaran = mataPelajaran ?? [],
       jadwalMengajar = jadwalMengajar ?? [];

  factory Guru.fromJson(Map<String, dynamic> json) {
    // Parse Mata Pelajaran (boleh null)
    List<Map<String, String>> mapelList = [];
    final mapelJson = json['Mata Pelajaran'];
    if (mapelJson != null && mapelJson is List) {
      mapelList =
          mapelJson.map<Map<String, String>>((item) {
            if (item is Map) {
              return Map<String, String>.from(
                item.map(
                  (key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''),
                ),
              );
            }
            return {};
          }).toList();
    }

    // Parse Jadwal Mengajar (boleh null)
    List<Map<String, String>> jadwalList = [];
    final jadwalJson = json['Jadwal Mengajar'];
    if (jadwalJson != null && jadwalJson is List) {
      jadwalList =
          jadwalJson.map<Map<String, String>>((item) {
            if (item is Map) {
              return Map<String, String>.from(
                item.map(
                  (key, value) =>
                      MapEntry(key.toString(), value?.toString() ?? ''),
                ),
              );
            }
            return {};
          }).toList();
    }

    return Guru(
      userId: json['User Id'] as int? ?? 0,
      nipNuptk: json['NIP_NUPTK'] as int? ?? 0,
      nama: json['Nama']?.toString() ?? '',
      mataPelajaran: mapelList,
      nomorTelepon: json['Nomor Telepon'] as int? ?? 0,
      email: json['Email']?.toString(),
      alamat: json['Alamat']?.toString() ?? '',
      jadwalMengajar: jadwalList,
    );
  }
}
