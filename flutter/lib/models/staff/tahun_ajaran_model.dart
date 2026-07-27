import 'dart:convert';

class TahunAjaran1Response {
  final int page;
  final int total;
  final int totalPage;
  final List<TahunAjaran1> data;

  TahunAjaran1Response({
    required this.page,
    required this.total,
    required this.totalPage,
    required this.data,
  });

  factory TahunAjaran1Response.fromJson(Map<String, dynamic> json) {
    return TahunAjaran1Response(
      page: json['page'] ?? 0,
      total: json['total'] ?? 0,
      totalPage: json['total_page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TahunAjaran1.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory TahunAjaran1Response.fromRawJson(String str) =>
      TahunAjaran1Response.fromJson(json.decode(str));
}

class TahunAjaran1 {
  final int tahunAjaranId;
  final String tahunAjaran;
  final bool isActive;
  final List<Map<String, dynamic>> semester;

  TahunAjaran1({
    required this.tahunAjaranId,
    required this.tahunAjaran,
    required this.isActive,
    required this.semester,
  });

  factory TahunAjaran1.fromJson(Map<String, dynamic> json) {
    // Parse isActive - bisa berupa bool atau string '1'/'0'
    bool isActive;
    if (json['is_active'] is bool) {
      isActive = json['is_active'];
    } else if (json['is_active'] is String) {
      isActive =
          json['is_active'] == '1' || json['is_active'].toLowerCase() == 'true';
    } else if (json['is_active'] is int) {
      isActive = json['is_active'] == 1;
    } else {
      isActive = false;
    }

    // Parse Semester
    List<Map<String, dynamic>> infoSemester = [];
    final semesterJson = json['semester'];
    if (semesterJson != null) {
      if (semesterJson is Map) {
        infoSemester = [
          Map<String, dynamic>.from(
            semesterJson.map((key, value) => MapEntry(key.toString(), value)),
          ),
        ];
      } else if (semesterJson is List) {
        infoSemester =
            semesterJson.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }

    return TahunAjaran1(
      tahunAjaranId: json['tahun_ajaran_id'] as int? ?? 0,
      tahunAjaran: json['tahun_ajaran']?.toString() ?? '',
      isActive: isActive,
      semester: infoSemester,
    );
  }
}
