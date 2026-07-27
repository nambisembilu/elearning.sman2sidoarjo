class JadwalMataPelajaran {
  final int id;
  final int kelasId;
  final String namaKelas;
  final String hari;
  final String waktu;
  final int mapelId;
  final String mataPelajaran;
  final int guruId;
  final String guru;

  JadwalMataPelajaran({
    required this.id,
    required this.kelasId,
    required this.namaKelas,
    required this.hari,
    required this.waktu,
    required this.mapelId,
    required this.mataPelajaran,
    required this.guruId,
    required this.guru,
  });

  factory JadwalMataPelajaran.fromJson(Map<String, dynamic> json) {
    return JadwalMataPelajaran(
      id: json['jadwal_mapel_id'] as int,
      kelasId: json['kelas_id'] as int,
      namaKelas: json['nama_kelas'] as String,
      hari: json['hari'] as String,
      waktu: json['waktu'] as String,
      mapelId: json['mapel_id'] as int,
      mataPelajaran: json['mata_pelajaran'] as String,
      guruId: json['guru_id'] as int,
      guru: json['guru'] as String,
    );
  }
}
