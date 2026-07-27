class RoutesNames {
  static const String landing = '/';
  static const String login = '/login';
  static const String splashScreen = '/splash';
  static const String roleScreen = '/role';
  static const String main = '/main';

  // STAFF
  static const String dataGuru = '/main/dataGuru';
  static const String dataSiswa = '/main/dataSiswa';
  static const String kelas = '/main/kelas';
  static const String mataPelajaran = '/main/mataPelajaran';
  static const String jadwalAkademik = '/main/jadwalAkademik';
  static const String jadwalPelajaran = '/main/jadwalPelajaran';
  static const String rubrikMapelStaff = '/main/rubrikMapel';
  static const String detailRubrikMapelStaff = '/main/rubrikMapel/detail';
  static const String tahunAjaran = '/main/tahunAjaran';
  static const String nilaiAkhir = '/main/nilaiAkhir';
  static const String nilaiLatsol = '/main/nilaiLatsol';
  static const String nilaiTugas = '/main/nilaiTugas';
  static const String nilaiUjianSumatif = '/main/nilaiUjianSumatif';
  static const String sumatifLingkupMateri = '/main/sumatifLingkupMateri';
  static const String rangeNilaiKategori = '/main/rangeNilaiKategori';

  // GURU
  static const String jadwalMengajar = '/main/jadwalMengajar';
  static const String kelompokBelajar = '/main/kelompokBelajar';
  static const String kelasGuru = '/main/kelasGuru';
  static const String detailKelas = '/main/kelasGuru/detail';
  static const String materiKelas = '/main/kelasGuru/detail/materi';
  static const String pratinjauMateri =
      '/main/kelasGuru/detail/materi/pratinjau';
  static const String editMateri = '/main/kelasGuru/detail/materi/edit';
  static const String tambahMateri = '/main/kelasGuru/detail/materi/tambah';
  static const String siswaKelas = '/main/kelasGuru/detail/daftarSiswa';
  static const String tugasKelas = '/main/kelasGuru/detail/tugas';
  static const String detailTugas = '/main/kelasGuru/detail/tugas/detail';
  static const String tambahTugas = '/main/kelasGuru/detail/tugas/tambah';
  static const String editTugas = '/main/kelasGuru/detail/tugas/edit';
  static const String penilaianTugas = '/main/kelasGuru/detail/tugas/penilaian';
  static const String ujianKelas = '/main/kelasGuru/detail/ujian';
  static const String listPengerjaanUjian =
      '/main/kelasGuru/detail/ujian/list-pengerjaan';
  static const String detailPengerjaanUjian =
      '/main/kelasGuru/detail/ujian/list-pengerjaan/detail';
  static const String kelolaUjian = '/main/kelasGuru/detail/ujian/kelola';

  // sampe sini
  static const String nilaiAkhirKelas = '/main/nilaiAkhirKelas';
  static const String nilaiLatsolKelas = '/main/nilaiLatsolKelas';
  static const String nilaiTugasKelas = '/main/nilaiTugasKelas';
  static const String nilaiUjianSumatifKelas = '/main/nilaiUjianSumatifKelas';
  static const String sumatifLingkupMateriKelas =
      '/main/sumatifLingkupMateriKelas';
  static const String rubrikMapelKelas = '/main/rubrikMapelKelas';
  static const String kelolaRubrikMapel = '/main/kelolaRubrikMapel';
  static const String detailRubrikMapel = '/main/detailRubrikMapel';

  // siswa
  static const String kelasSiswa = '/main/kelasSiswa';
  static const String jadwalSiswa = '/main/jadwalSiswa';
  static const String detailKelasSiswa = '/main/kelasSiswa/detail';
  static const String detailMateriSiswa = '/main/kelasSiswa/detail/materi';
  static const String detailTugasSiswa = '/main/kelasSiswa/detail/tugas';
  static const String editTugasSiswa = '/main/kelasSiswa/detail/tugas/edit';
  static const String pengumpulanTugasSiswa =
      '/main/kelasSiswa/detail/tugas/pengumpulan';

  static const String detailUjianSiswa = '/main/kelasSiswa/detail/ujian';
  static const String soalUjianSiswa = '/main/kelasSiswa/detail/ujian/soal';
  static const String jawabanUjianSiswa =
      '/main/kelasSiswa/detail/ujian/jawaban';

  // ADMIN
  static const String daftarStaff = '/main/daftarStaff';
  static const String logAktivitas = '/main/logAktivitas';
}
