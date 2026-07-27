class KelasAktif {
  final int id;
  final String nama_kelas;
  final String jurusan;

  KelasAktif({
    required this.id,
    required this.nama_kelas,
    required this.jurusan,
  });

  factory KelasAktif.fromJson(Map<String, dynamic> json) {
    return KelasAktif(
      id: json['Id'],
      nama_kelas: json['Nama Kelas'],
      jurusan: json['Jurusan'],
    );
  }
}
