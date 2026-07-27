class JadwalMataPelajaran {
  final int id;
  final String hari;
  final String waktu;
  final String mataPelajaran;
  final String namaKelas;
  final String ruangKelas;

  JadwalMataPelajaran({
    required this.id,
    required this.hari,
    required this.waktu,
    required this.mataPelajaran,
    required this.namaKelas,
    required this.ruangKelas,
  });

  factory JadwalMataPelajaran.fromJson(Map<String, dynamic> json) {
    return JadwalMataPelajaran(
      id: json['jadwal_pelajaran_id'] as int,
      hari: json['hari'] as String,
      waktu: json['jam_pelajaran'] as String,
      mataPelajaran: json['mata_pelajaran'] as String,
      namaKelas: json['nama_kelas'] as String,
      ruangKelas: json['ruang_kelas'] as String,
    );
  }
}
