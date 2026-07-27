// import 'dart:convert';

// class InfoUjian {
//   int idTemp;
//   String tipeUjian;
//   String deskripsi;
//   String tanggalUjian;
//   String jamMulai;
//   String jamSelesai;
//   String statusNilai;
//   String statusUjian;
//   List<SoalUjian> soalUjian;

//   InfoUjian({
//     required this.idTemp,
//     required this.tipeUjian,
//     required this.deskripsi,
//     required this.tanggalUjian,
//     required this.jamMulai,
//     required this.jamSelesai,
//     required this.statusNilai,
//     required this.statusUjian,
//     required this.soalUjian,
//   });

//   Map<String, dynamic> toJson() => {
//     "idTemp": idTemp,
//     "p_tipe_ujian": tipeUjian,
//     "p_deskripsi": deskripsi,
//     "p_tanggal_ujian": tanggalUjian,
//     "p_jam_mulai": jamMulai,
//     "p_jam_selesai": jamSelesai,
//     "p_status_nilai": statusNilai,
//     "p_status_konten": statusUjian,
//     "p_soal_ujian": soalUjian.map((e) => e.toJson()).toList(),
//   };

//   factory InfoUjian.fromJson(Map<String, dynamic> json) {
//     return InfoUjian(
//       idTemp: json["idTemp"],
//       tipeUjian: json['p_tipe_ujian'],
//       deskripsi: json['p_deskripsi'],
//       tanggalUjian: json['p_tanggal_ujian'],
//       jamMulai: json['p_jam_mulai'],
//       jamSelesai: json['p_jam_selesai'],
//       statusNilai: json['p_status_nilai'],
//       statusUjian: json['p_status_konten'],
//       soalUjian:
//           (json['p_soal_ujian'] as List)
//               .map((e) => SoalUjian.fromJson(e))
//               .toList(),
//     );
//   }

//   InfoUjian copyWith({
//     int? idTemp,
//     String? tipeUjian,
//     String? deskripsi,
//     String? tanggalUjian,
//     String? jamMulai,
//     String? jamSelesai,
//     String? statusNilai,
//     String? statusUjian,
//     List<SoalUjian>? soalUjian,
//   }) {
//     return InfoUjian(
//       idTemp: idTemp ?? this.idTemp,
//       tipeUjian: tipeUjian ?? this.tipeUjian,
//       deskripsi: deskripsi ?? this.deskripsi,
//       tanggalUjian: tanggalUjian ?? this.tanggalUjian,
//       jamMulai: jamMulai ?? this.jamMulai,
//       jamSelesai: jamSelesai ?? this.jamSelesai,
//       statusNilai: statusNilai ?? this.statusNilai,
//       statusUjian: statusUjian ?? this.statusUjian,
//       soalUjian: soalUjian ?? this.soalUjian,
//     );
//   }

//   @override
//   String toString() => jsonEncode(toJson());
// }

// class SoalUjian {
//   String soal;
//   String tipeSoal;
//   String? opsiJawabanA;
//   String? opsiJawabanB;
//   String? opsiJawabanC;
//   String? opsiJawabanD;
//   String? opsiJawabanE;
//   String? kunciJawabanPilgan;
//   int? bobotNilai;

//   SoalUjian({
//     required this.soal,
//     required this.tipeSoal,
//     this.opsiJawabanA,
//     this.opsiJawabanB,
//     this.opsiJawabanC,
//     this.opsiJawabanD,
//     this.opsiJawabanE,
//     this.kunciJawabanPilgan,
//     this.bobotNilai,
//   });

//   Map<String, dynamic> toJson() => {
//     "p_soal": soal,
//     "p_tipe_soal": tipeSoal,
//     "p_opsi_jawaban_a": opsiJawabanA,
//     "p_opsi_jawaban_b": opsiJawabanB,
//     "p_opsi_jawaban_c": opsiJawabanC,
//     "p_opsi_jawaban_d": opsiJawabanD,
//     "p_opsi_jawaban_e": opsiJawabanE,
//     "p_kunci_jawaban_pilgan": kunciJawabanPilgan,
//     "p_bobot_nilai": bobotNilai,
//   };

//   factory SoalUjian.fromJson(Map<String, dynamic> json) {
//     return SoalUjian(
//       soal: json['p_soal'],
//       tipeSoal: json['p_tipe_soal'],
//       opsiJawabanA: json['p_opsi_jawaban_a'],
//       opsiJawabanB: json['p_opsi_jawaban_b'],
//       opsiJawabanC: json['p_opsi_jawaban_c'],
//       opsiJawabanD: json['p_opsi_jawaban_d'],
//       opsiJawabanE: json['p_opsi_jawaban_e'],
//       kunciJawabanPilgan: json['p_kunci_jawaban_pilgan'],
//       bobotNilai: json['p_bobot_nilai'],
//     );
//   }

//   SoalUjian copyWith({
//     int? idTpTemp,
//     String? soal,
//     String? tipeSoal,
//     String? opsiJawabanA,
//     String? opsiJawabanB,
//     String? opsiJawabanC,
//     String? opsiJawabanD,
//     String? opsiJawabanE,
//     String? kunciJawabanPilgan,
//     int? bobotNilai,
//   }) {
//     return SoalUjian(
//       soal: soal ?? this.soal,
//       tipeSoal: tipeSoal ?? this.tipeSoal,
//       opsiJawabanA: opsiJawabanA ?? this.opsiJawabanA,
//       opsiJawabanB: opsiJawabanB ?? this.opsiJawabanB,
//       opsiJawabanC: opsiJawabanC ?? this.opsiJawabanC,
//       opsiJawabanD: opsiJawabanD ?? this.opsiJawabanD,
//       opsiJawabanE: opsiJawabanE ?? this.opsiJawabanE,
//       kunciJawabanPilgan: kunciJawabanPilgan ?? this.kunciJawabanPilgan,
//       bobotNilai: bobotNilai ?? this.bobotNilai,
//     );
//   }

//   @override
//   String toString() => jsonEncode(toJson());
// }
