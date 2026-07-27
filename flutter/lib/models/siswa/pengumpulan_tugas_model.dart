class PengumpulanTugasDetailModel {
  final int? pengumpulanTugasId;
  final int? tugasId;
  final int? siswaId;
  final String? statusPengumpulan;
  final DateTime? waktuPengumpulan;
  final DateTime? deadline;
  final List<String>? files;
  final String? status; // untuk "error" atau "belum_kumpul"
  final String? message; // pesan error

  PengumpulanTugasDetailModel({
    this.pengumpulanTugasId,
    this.tugasId,
    this.siswaId,
    this.statusPengumpulan,
    this.waktuPengumpulan,
    this.deadline,
    this.files,
    this.status,
    this.message,
  });

  factory PengumpulanTugasDetailModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('status') && json['status'] != null) {
      // response error
      return PengumpulanTugasDetailModel(
        status: json['status'],
        message: json['message'],
      );
    }

    return PengumpulanTugasDetailModel(
      pengumpulanTugasId: json['pengumpulan_tugas_id'],
      tugasId: json['tugas_id'],
      siswaId: json['siswa_id'],
      statusPengumpulan: json['status_pengumpulan'],
      waktuPengumpulan: DateTime.parse(json['waktu_pengumpulan']),
      deadline: DateTime.parse(json['deadline']),
      files: (json['files'] != null) ? List<String>.from(json['files']) : [],
    );
  }
}
