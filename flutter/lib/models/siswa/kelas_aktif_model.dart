class KelasAktif {
  final int id;
  final String namaKelas;
  final String jurusan;

  KelasAktif({
    required this.id,
    required this.namaKelas,
    required this.jurusan,
  });

  factory KelasAktif.fromJson(Map<String, dynamic> json) {
    return KelasAktif(
      id: json['Id'],
      namaKelas: json['Nama Kelas'],
      jurusan: json['Jurusan'],
    );
  }
}
