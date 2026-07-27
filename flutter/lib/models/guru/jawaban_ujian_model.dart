import 'dart:convert';

class JawabanUjianModel {
  int soalUjianId;
  int jawabanUjianId;
  String? jawabanPilgan;
  String? jawabanEsai;
  String? statusJawaban;
  int? nilaiJawaban;
  int? bobotNilai;

  JawabanUjianModel({
    required this.soalUjianId,
    required this.jawabanUjianId,
    this.jawabanPilgan,
    this.jawabanEsai,
    this.statusJawaban,
    required this.nilaiJawaban,
    required this.bobotNilai
  });

  factory JawabanUjianModel.fromJson(Map<String, dynamic> json) {
    return JawabanUjianModel(
      soalUjianId: json["soal_ujian_id"],
      jawabanPilgan: json["jawaban_pilgan"],
      jawabanUjianId: json['jawaban_ujian_id'],
      jawabanEsai: json["jawaban_esai"],
      statusJawaban: json["status_jawaban"],
      nilaiJawaban: json["nilai_jawaban"],
      bobotNilai: json['bobot_nilai']
    );
  }

  Map<String, dynamic> toJson() => {
    "soal_ujian_id": soalUjianId,
    "jawaban_ujian_id" : jawabanUjianId,
    "jawaban_pilgan": jawabanPilgan,
    "jawaban_esai": jawabanEsai,
    "status_jawaban": statusJawaban,
    "nilai_jawaban": nilaiJawaban,
    "bobot_nilai" : bobotNilai
  };

  JawabanUjianModel copyWith({
    int? soalUjianId,
    int? jawabanUjianId,
    String? jawabanPilgan,
    String? jawabanEsai,
    String? statusJawaban,
    int? nilaiJawaban,
    int? bobotNilai
  }) {
    return JawabanUjianModel(
      soalUjianId: soalUjianId ?? this.soalUjianId,
      jawabanUjianId: jawabanUjianId ?? this.jawabanUjianId,
      jawabanPilgan: jawabanPilgan ?? this.jawabanPilgan,
      jawabanEsai: jawabanEsai ?? this.jawabanEsai,
      statusJawaban: statusJawaban ?? this.statusJawaban,
      nilaiJawaban: nilaiJawaban ?? this.nilaiJawaban,
      bobotNilai: bobotNilai ?? this.bobotNilai
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
