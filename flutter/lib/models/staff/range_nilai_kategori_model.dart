class RangeNilaiKategori {
  final int id;
  final String kategoriNilai;
  final int nilaiMinimum;
  final int nilaiMaksimum;
  final String deskripsi;

  RangeNilaiKategori({
    required this.id,
    required this.kategoriNilai,
    required this.nilaiMinimum,
    required this.nilaiMaksimum,
    required this.deskripsi,
  });

  factory RangeNilaiKategori.fromJson(Map<String, dynamic> json) {
    return RangeNilaiKategori(
      id: json['id'] as int,
      kategoriNilai: json['kategori_nilai'] as String,
      nilaiMinimum: json['nilai_minimum'] as int,
      nilaiMaksimum: json['nilai_maksimum'] as int,
      deskripsi: json['deskripsi'] as String
    );
  }
}
