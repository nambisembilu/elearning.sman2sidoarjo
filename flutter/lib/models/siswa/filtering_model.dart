class TahunAjaran {
  final int id;
  final String tahunAjaran;
  final String isActive;

  TahunAjaran({
    required this.id,
    required this.tahunAjaran,
    required this.isActive,
  });

  factory TahunAjaran.fromJson(Map<String, dynamic> json) {
    return TahunAjaran(
      id: json['id'] as int,
      tahunAjaran: json['tahun_ajaran'] as String,
      isActive: json['is_active'] as String,
    );
  }
}

class KelasByTahunAjaran {
  final int id;
  final String namaKelas;
  final String jurusan;

  KelasByTahunAjaran({
    required this.id,
    required this.namaKelas,
    required this.jurusan,
  });

  factory KelasByTahunAjaran.fromJson(Map<String, dynamic> json) {
    return KelasByTahunAjaran(
      id: json['id'] as int,
      namaKelas: json['nama_kelas'] as String,
      jurusan: json['jurusan'] as String,
    );
  }
}

class Semester {
  final int semesterId;
  final int tahunAjaranId;
  final String judulSemester;
  final String isActive;

  Semester({
    required this.semesterId,
    required this.tahunAjaranId,
    required this.judulSemester,
    required this.isActive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semesterId: json['semester_id'] as int,
      tahunAjaranId: json['tahun_ajaran_id'] as int,
      judulSemester: json['judul'] as String,
      isActive: json['is_active'] as String,
    );
  }
}

class MataPelajaran {
  final int mapelId;
  final String judulMapel;

  MataPelajaran({required this.mapelId, required this.judulMapel});

  factory MataPelajaran.fromJson(Map<String, dynamic> json) {
    return MataPelajaran(
      mapelId: json['mapel_id'] as int,
      judulMapel: json['judul_mapel'] as String,
    );
  }
}

class KelasMapelGuru {
  final int kmpId;
  final String namaKmp;

  KelasMapelGuru({required this.kmpId, required this.namaKmp});

  factory KelasMapelGuru.fromJson(Map<String, dynamic> json) {
    return KelasMapelGuru(
      kmpId: json['kmp_id'] as int,
      namaKmp: json['nama_kmp'] as String,
    );
  }
}

class LingkupMateri {
  final int lingkupMateriId;
  final String judulLM;
  final List<Map<String, dynamic>> tujuanPembelajaran;

  LingkupMateri({
    required this.lingkupMateriId,
    required this.judulLM,
    required this.tujuanPembelajaran,
  });

  factory LingkupMateri.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> tujuanPembelajaranList = [];

    final tujuanPembelajaranJson = json['tujuan_pembelajaran'];

    if (tujuanPembelajaranJson != null && tujuanPembelajaranJson is List) {
      tujuanPembelajaranList = List<Map<String, dynamic>>.from(
        tujuanPembelajaranJson.map((e) => Map<String, dynamic>.from(e)),
      );
    }

    return LingkupMateri(
      lingkupMateriId: json['lingkup_materi_id'] as int,
      judulLM: json['judul'] as String,
      tujuanPembelajaran: tujuanPembelajaranList,
    );
  }
}
