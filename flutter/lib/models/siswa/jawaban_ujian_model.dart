import 'dart:convert';

class JawabanUjianModel {
  int soalUjianId;
  String? jawabanPilgan;
  String? jawabanEsai;
  String? statusJawaban;
  int? nilaiJawaban;

  JawabanUjianModel({
    required this.soalUjianId,
    this.jawabanPilgan,
    this.jawabanEsai,
    this.statusJawaban,
    required this.nilaiJawaban,
  });

  factory JawabanUjianModel.fromJson(Map<String, dynamic> json) {
    return JawabanUjianModel(
      soalUjianId: json["soal_ujian_id"],
      jawabanPilgan: json["jawaban_pilgan"],
      jawabanEsai: json["jawaban_esai"],
      statusJawaban: json["status_jawaban"],
      nilaiJawaban: json["nilai_jawaban"],
    );
  }

  Map<String, dynamic> toJson() => {
    "soal_ujian_id": soalUjianId,
    "jawaban_pilgan": jawabanPilgan,
    "jawaban_esai": jawabanEsai,
    "status_jawaban": statusJawaban,
    "nilai_jawaban": nilaiJawaban,
  };

  JawabanUjianModel copyWith({
    int? soalUjianId,
    String? jawabanPilgan,
    String? jawabanEsai,
    String? statusJawaban,
    int? nilaiJawaban,
  }) {
    return JawabanUjianModel(
      soalUjianId: soalUjianId ?? this.soalUjianId,
      jawabanPilgan: jawabanPilgan ?? this.jawabanPilgan,
      jawabanEsai: jawabanEsai ?? this.jawabanEsai,
      statusJawaban: statusJawaban ?? this.statusJawaban,
      nilaiJawaban: nilaiJawaban ?? this.nilaiJawaban,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
