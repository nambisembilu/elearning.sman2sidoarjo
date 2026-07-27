class DetailUjian {
  final int ujianId;
  final String judulUjian;
  final String tanggalUjian;
  final String jamMulai;
  final String jamSelesai;
  final String deskripsi;
  final String statusNilai;
  final bool statusPengerjaan;
  final double nilaiUjian;

  DetailUjian({
    required this.ujianId,
    required this.judulUjian,
    required this.tanggalUjian,
    required this.jamMulai,
    required this.jamSelesai,
    required this.deskripsi,
    required this.statusNilai,
    required this.statusPengerjaan,
    required this.nilaiUjian,
  });

  factory DetailUjian.fromJson(Map<String, dynamic> json) {
    return DetailUjian(
      ujianId: json['ujian_id'] as int? ?? 0,
      judulUjian: json['judul_ujian'] as String? ?? '',
      tanggalUjian: json['tanggal_ujian'] as String? ?? '',
      jamMulai: json['jam_mulai'] as String? ?? '',
      jamSelesai: json['jam_selesai'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      statusNilai: json['status_nilai'] as String? ?? '',
      statusPengerjaan: json['sudah_mengerjakan'] as bool? ?? false,
      // PERBAIKAN DI SINI: Konversi ke double dengan aman
      nilaiUjian: (json['nilai_ujian'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
