import 'dart:convert';

class RubrikMapelResponse {
  final int page;
  final int total;
  final int totalPage;
  final int userIdKoorMapel;
  final String koorMapel;
  final List<RubrikMapel> data;

  RubrikMapelResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.userIdKoorMapel,
    required this.koorMapel,
    required this.data,
  });

  factory RubrikMapelResponse.fromJson(Map<String, dynamic> json) {
    return RubrikMapelResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      userIdKoorMapel: json['user_id_koor_mapel'] ?? 0,
      koorMapel: json['koor_mapel'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => RubrikMapel.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory RubrikMapelResponse.fromRawJson(String str) =>
      RubrikMapelResponse.fromJson(json.decode(str));
}

class RubrikMapel {
  final int lingkupMateriId;
  final String lingkupMateri;
  final bool statusKunci;
  final int jumlahTP;
  final List<Map<String, dynamic>> tujuanPembelajaran;

  RubrikMapel({
    required this.lingkupMateriId,
    required this.lingkupMateri,
    required this.statusKunci,
    required this.jumlahTP,
    required this.tujuanPembelajaran,
  });

  factory RubrikMapel.fromJson(Map<String, dynamic> json) {
    // Parse file materi - asumsikan struktur JSON yang benar
    List<Map<String, String>> tujuanPembelajaranList = [];

    if (json['tujuan_pembelajaran'] != null &&
        json['tujuan_pembelajaran'] is List) {
      tujuanPembelajaranList =
          (json['tujuan_pembelajaran'] as List).map((file) {
            if (file is Map<String, dynamic>) {
              return file.map(
                (key, value) => MapEntry(key, value?.toString() ?? ''),
              );
            }
            return <String, String>{};
          }).toList();
    }

    return RubrikMapel(
      lingkupMateriId: json['lingkup_materi_id'] as int,
      lingkupMateri: json['lingkup_materi'] as String,
      statusKunci: json['status_kunci'] as bool,
      jumlahTP: json['jumlah_tujuan_pembelajaran'] as int,
      tujuanPembelajaran: tujuanPembelajaranList,
    );
  }
}
