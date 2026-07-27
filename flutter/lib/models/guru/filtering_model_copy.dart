// class TahunAjaran {
//   final int id;
//   final String tahunAjaran;
//   final String isActive;

//   TahunAjaran({
//     required this.id,
//     required this.tahunAjaran,
//     required this.isActive,
//   });

//   factory TahunAjaran.fromJson(Map<String, dynamic> json) {
//     return TahunAjaran(
//       id: json['id'] as int,
//       tahunAjaran: json['tahun_ajaran'] as String,
//       isActive: json['is_active'] as String,
//     );
//   }
// }

// class KelasByTahunAjaran {
//   final int id;
//   final String namaKelas;
//   final String jurusan;

//   KelasByTahunAjaran({
//     required this.id,
//     required this.namaKelas,
//     required this.jurusan,
//   });

//   factory KelasByTahunAjaran.fromJson(Map<String, dynamic> json) {
//     return KelasByTahunAjaran(
//       id: json['id'] as int,
//       namaKelas: json['nama_kelas'] as String,
//       jurusan: json['jurusan'] as String,
//     );
//   }
// }

// // untuk fitur add jadwal pelajaran
// class HariTersedia {
//   final String hari;

//   HariTersedia({required this.hari});

//   factory HariTersedia.fromJson(Map<String, dynamic> json) {
//     return HariTersedia(hari: json['Hari'] as String);
//   }
// }

// class WaktuTersedia {
//   final String jamPelajaran;

//   WaktuTersedia({required this.jamPelajaran});

//   factory WaktuTersedia.fromJson(Map<String, dynamic> json) {
//     return WaktuTersedia(jamPelajaran: json['jam_pelajaran'] as String);
//   }
// }

// class MapelByKelasHari {
//   final int idMapel;
//   final String namaMapel;

//   MapelByKelasHari({required this.idMapel, required this.namaMapel});

//   factory MapelByKelasHari.fromJson(Map<String, dynamic> json) {
//     return MapelByKelasHari(
//       idMapel: json['mapel_id'] as int,
//       namaMapel: json['nama_mapel'],
//     );
//   }
// }

// class GuruTersedia {
//   final int idGuru;
//   final String namaGuru;

//   GuruTersedia({required this.idGuru, required this.namaGuru});

//   factory GuruTersedia.fromJson(Map<String, dynamic> json) {
//     return GuruTersedia(
//       idGuru: json['guru_id'] as int,
//       namaGuru: json['nama_guru'],
//     );
//   }
// }

// class WalasTersedia {
//   final int userId;
//   final String namaGuru;

//   WalasTersedia({required this.userId, required this.namaGuru});

//   factory WalasTersedia.fromJson(Map<String, dynamic> json) {
//     return WalasTersedia(
//       userId: json['user_id'] as int,
//       namaGuru: json['nama_guru'] as String,
//     );
//   }
// }

// class Semester {
//   final int semesterId;
//   final int tahunAjaranId;
//   final String judulSemester;
//   final String isActive;

//   Semester({
//     required this.semesterId,
//     required this.tahunAjaranId,
//     required this.judulSemester,
//     required this.isActive,
//   });

//   factory Semester.fromJson(Map<String, dynamic> json) {
//     return Semester(
//       semesterId: json['semester_id'] as int,
//       tahunAjaranId: json['tahun_ajaran_id'] as int,
//       judulSemester: json['judul'] as String,
//       isActive: json['is_active'] as String,
//     );
//   }
// }

// class MapelByKelas {
//   final int mapelId;
//   final String judulMapel;

//   MapelByKelas({required this.mapelId, required this.judulMapel});

//   factory MapelByKelas.fromJson(Map<String, dynamic> json) {
//     return MapelByKelas(
//       mapelId: json['mapel_id'] as int,
//       judulMapel: json['judul_mapel'] as String,
//     );
//   }
// }
