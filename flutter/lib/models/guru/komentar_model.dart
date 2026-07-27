import 'dart:convert';

class KomentarResponse {
  final int page;
  final int total;
  final int totalPage;
  final List<Komentar> data;

  KomentarResponse({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory KomentarResponse.fromJson(Map<String, dynamic> json) {
    return KomentarResponse(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Komentar.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory KomentarResponse.fromRawJson(String str) =>
      KomentarResponse.fromJson(json.decode(str));
}

class Komentar {
  final int komentarId;
  final int userId;
  final String roleUser;
  final String username;
  final String komentar;
  final String waktuKomentar;

  Komentar({
    required this.komentarId,
    required this.userId,
    required this.roleUser,
    required this.username,
    required this.komentar,
    required this.waktuKomentar,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      komentarId: json['komentar_id'],
      userId: json['user_id'],
      roleUser: json['role_user'],
      username: json['username'],
      komentar: json['komentar'],
      waktuKomentar: json['waktu_komentar'],
    );
  }
}
