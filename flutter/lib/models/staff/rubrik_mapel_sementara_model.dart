import 'dart:convert';

class TujuanPembelajaran {
  int idTpTemp;
  String deskripsi;
  String perluBimbingan;
  String cukup;
  String baik;
  String sangatBaik;

  TujuanPembelajaran({
    required this.idTpTemp,
    required this.deskripsi,
    required this.perluBimbingan,
    required this.cukup,
    required this.baik,
    required this.sangatBaik,
  });

  Map<String, dynamic> toJson() => {
    "idTpTemp": idTpTemp,
    "deskripsi": deskripsi,
    "perluBimbingan": perluBimbingan,
    "cukup": cukup,
    "baik": baik,
    "sangatBaik": sangatBaik,
  };

  factory TujuanPembelajaran.fromJson(Map<String, dynamic> json) {
    return TujuanPembelajaran(
      idTpTemp: json["idTpTemp"],
      deskripsi: json["deskripsi"],
      perluBimbingan: json["perluBimbingan"],
      cukup: json["cukup"],
      baik: json["baik"],
      sangatBaik: json["sangatBaik"],
    );
  }

  TujuanPembelajaran copyWith({
    int? idTpTemp,
    String? deskripsi,
    String? perluBimbingan,
    String? cukup,
    String? baik,
    String? sangatBaik,
  }) {
    return TujuanPembelajaran(
      idTpTemp: idTpTemp ?? this.idTpTemp,
      deskripsi: deskripsi ?? this.deskripsi,
      perluBimbingan: perluBimbingan ?? this.perluBimbingan,
      cukup: cukup ?? this.cukup,
      baik: baik ?? this.baik,
      sangatBaik: sangatBaik ?? this.sangatBaik,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class RubrikItem {
  int idTemp;
  String lingkupMateri;
  List<TujuanPembelajaran> tujuanPembelajaran;

  RubrikItem({
    required this.idTemp,
    required this.lingkupMateri,
    required this.tujuanPembelajaran,
  });

  Map<String, dynamic> toJson() => {
    "idTemp": idTemp,
    "lingkupMateri": lingkupMateri,
    "tujuanPembelajaran": tujuanPembelajaran.map((e) => e.toJson()).toList(),
  };

  factory RubrikItem.fromJson(Map<String, dynamic> json) {
    return RubrikItem(
      idTemp: json["idTemp"],
      lingkupMateri: json["lingkupMateri"],
      tujuanPembelajaran:
          (json["tujuanPembelajaran"] as List)
              .map((e) => TujuanPembelajaran.fromJson(e))
              .toList(),
    );
  }

  RubrikItem copyWith({
    int? idTemp,
    String? lingkupMateri,
    List<TujuanPembelajaran>? tujuanPembelajaran,
  }) {
    return RubrikItem(
      idTemp: idTemp ?? this.idTemp,
      lingkupMateri: lingkupMateri ?? this.lingkupMateri,
      tujuanPembelajaran: tujuanPembelajaran ?? this.tujuanPembelajaran,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
