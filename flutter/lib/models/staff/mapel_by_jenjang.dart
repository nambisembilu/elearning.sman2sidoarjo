class MapelByJenjang {
  final int id;
  final String judul;

  MapelByJenjang({required this.id, required this.judul});

  factory MapelByJenjang.fromJson(Map<String, dynamic> json) {
    return MapelByJenjang (id: json['id'] as int, judul: json['judul'] as String);
  }
}
