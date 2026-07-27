class SoalUjianSiswa {
  final String soal;
  final String tipeSoal;
  final int soalUjianId;
  final String? opsiJawabanA;
  final String? opsiJawabanB;
  final String? opsiJawabanC;
  final String? opsiJawabanD;
  final String? opsiJawabanE;
  final String? kunciJawabanPilgan;

  SoalUjianSiswa({
    required this.soal,
    required this.tipeSoal,
    required this.soalUjianId,
    required this.opsiJawabanA,
    required this.opsiJawabanB,
    required this.opsiJawabanC,
    required this.opsiJawabanD,
    required this.opsiJawabanE,
    required this.kunciJawabanPilgan,
  });

  factory SoalUjianSiswa.fromJson(Map<String, dynamic> json) {
    return SoalUjianSiswa(
      soal: json['soal'],
      tipeSoal: json['tipe_soal'],
      soalUjianId: json['soal_ujian_id'],
      opsiJawabanA: json['opsi_jawaban_a'] ?? '',
      opsiJawabanB: json['opsi_jawaban_b'] ?? '',
      opsiJawabanC: json['opsi_jawaban_c'] ?? '',
      opsiJawabanD: json['opsi_jawaban_d'] ?? '',
      opsiJawabanE: json['opsi_jawaban_e'] ?? '',
      kunciJawabanPilgan: json['kunci_jawaban_pilgan'] ?? '',
    );
  }
}
