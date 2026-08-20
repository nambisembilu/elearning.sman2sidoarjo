-- ==========================================================================
-- DATA DEMO GURU — E-Learning SMAN 2 Sidoarjo
--
-- Dijalankan otomatis saat startup server (lihat seedDemo() di server/index.js).
-- Nonaktifkan dengan environment variable SEED_DEMO=false.
--
-- Aman dijalankan berulang kali: semua baris memakai id eksplisit + INSERT
-- IGNORE, dan blok UPDATE di bagian akhir menggeser ulang seluruh tanggal
-- demo relatif terhadap NOW() supaya demo tidak pernah terlihat basi.
--
-- Blok id yang dipakai data demo: 900+ (master), 9000+ (user & notifikasi).
-- Data seed dasar di elearning_sma.sql memakai id kecil dan tidak disentuh.
--
-- Akun demo utama : 3000 / password  (Budi Santoso, guru Matematika)
-- Siswa demo      : 4101 s/d 4134 / password
-- ==========================================================================

-- --------------------------------------------------------------------------
-- Mata pelajaran, kelas, dan penugasan mengajar
-- --------------------------------------------------------------------------
INSERT IGNORE INTO subjects (id, judul_mapel, jenjang, jurusan, koordinator_user_id) VALUES
  (901, 'Matematika', 'XI', 'IPA', 3);

INSERT IGNORE INTO guru_subjects (guru_user_id, subject_id) VALUES
  (3, 901);

INSERT IGNORE INTO classes (id, academic_year_id, jenjang, jurusan, nama_kelas, ruang_kelas, wali_kelas_user_id) VALUES
  (901, 1, 'X',  'IPA', 'X IPA 2',  'Ruang A2', 4),
  (902, 1, 'XI', 'IPA', 'XI IPA 1', 'Ruang B2', 3);

INSERT IGNORE INTO class_subjects (id, class_id, subject_id, guru_user_id, academic_year_id) VALUES
  (901, 901, 1,   3, 1),
  (902, 902, 901, 3, 1);

-- --------------------------------------------------------------------------
-- Siswa demo (34 orang) — password sama dengan seed dasar: 'password'
-- --------------------------------------------------------------------------
INSERT IGNORE INTO users (id, identifier, password_hash, nama, email, no_telp, alamat, role, jenis_kelamin, agama) VALUES
  (9001, '4101', 'password', 'Aditya Nugroho', 'aditya4101@student.sman2sidoarjo.sch.id', '08123000000', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9002, '4102', 'password', 'Bella Safitri', 'bella4102@student.sman2sidoarjo.sch.id', '08123000001', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9003, '4103', 'password', 'Candra Kusuma', 'candra4103@student.sman2sidoarjo.sch.id', '08123000002', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9004, '4104', 'password', 'Dinda Ayu Lestari', 'dinda4104@student.sman2sidoarjo.sch.id', '08123000003', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9005, '4105', 'password', 'Erlangga Saputra', 'erlangga4105@student.sman2sidoarjo.sch.id', '08123000004', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9006, '4106', 'password', 'Farah Nabila', 'farah4106@student.sman2sidoarjo.sch.id', '08123000005', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9007, '4107', 'password', 'Gilang Ramadhan', 'gilang4107@student.sman2sidoarjo.sch.id', '08123000006', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9008, '4108', 'password', 'Hanifah Zahra', 'hanifah4108@student.sman2sidoarjo.sch.id', '08123000007', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9009, '4109', 'password', 'Irfan Maulana', 'irfan4109@student.sman2sidoarjo.sch.id', '08123000008', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9010, '4110', 'password', 'Julia Anggraini', 'julia4110@student.sman2sidoarjo.sch.id', '08123000009', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9011, '4111', 'password', 'Kevin Hartanto', 'kevin4111@student.sman2sidoarjo.sch.id', '08123000010', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9012, '4112', 'password', 'Laras Wulandari', 'laras4112@student.sman2sidoarjo.sch.id', '08123000011', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9013, '4113', 'password', 'Muhammad Rizky', 'muhammad4113@student.sman2sidoarjo.sch.id', '08123000012', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9014, '4114', 'password', 'Nadia Salsabila', 'nadia4114@student.sman2sidoarjo.sch.id', '08123000013', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9015, '4115', 'password', 'Oktavian Pradana', 'oktavian4115@student.sman2sidoarjo.sch.id', '08123000014', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9016, '4116', 'password', 'Putri Amelia', 'putri4116@student.sman2sidoarjo.sch.id', '08123000015', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9017, '4117', 'password', 'Qori Ananda', 'qori4117@student.sman2sidoarjo.sch.id', '08123000016', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9018, '4118', 'password', 'Rendra Setiawan', 'rendra4118@student.sman2sidoarjo.sch.id', '08123000017', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9019, '4119', 'password', 'Salsa Dwi Cahya', 'salsa4119@student.sman2sidoarjo.sch.id', '08123000018', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9020, '4120', 'password', 'Taufik Hidayat', 'taufik4120@student.sman2sidoarjo.sch.id', '08123000019', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9021, '4121', 'password', 'Ulfa Rahmawati', 'ulfa4121@student.sman2sidoarjo.sch.id', '08123000020', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9022, '4122', 'password', 'Vino Ardiansyah', 'vino4122@student.sman2sidoarjo.sch.id', '08123000021', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9023, '4123', 'password', 'Wulan Permata', 'wulan4123@student.sman2sidoarjo.sch.id', '08123000022', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9024, '4124', 'password', 'Yoga Prasetyo', 'yoga4124@student.sman2sidoarjo.sch.id', '08123000023', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9025, '4125', 'password', 'Zahra Aulia', 'zahra4125@student.sman2sidoarjo.sch.id', '08123000024', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9026, '4126', 'password', 'Arif Budiman', 'arif4126@student.sman2sidoarjo.sch.id', '08123000025', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9027, '4127', 'password', 'Bunga Meilani', 'bunga4127@student.sman2sidoarjo.sch.id', '08123000026', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9028, '4128', 'password', 'Cahyo Wibowo', 'cahyo4128@student.sman2sidoarjo.sch.id', '08123000027', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9029, '4129', 'password', 'Dewi Anjani', 'dewi4129@student.sman2sidoarjo.sch.id', '08123000028', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9030, '4130', 'password', 'Eka Fitriani', 'eka4130@student.sman2sidoarjo.sch.id', '08123000029', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9031, '4131', 'password', 'Fajar Nurcahyo', 'fajar4131@student.sman2sidoarjo.sch.id', '08123000030', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9032, '4132', 'password', 'Gita Maharani', 'gita4132@student.sman2sidoarjo.sch.id', '08123000031', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (9033, '4133', 'password', 'Hendra Alfarizi', 'hendra4133@student.sman2sidoarjo.sch.id', '08123000032', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (9034, '4134', 'password', 'Intan Purnama', 'intan4134@student.sman2sidoarjo.sch.id', '08123000033', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam');

INSERT IGNORE INTO siswa_profiles (user_id, nis, nisn, kelas_id, nama_wali_murid, alamat_wali_murid, no_telp_wali_murid, status_wali_murid) VALUES
  (9001, '2025101', '4101', 1, 'Orang tua Aditya', 'Sidoarjo', '08134000000', 'Ayah'),
  (9002, '2025102', '4102', 1, 'Orang tua Bella', 'Sidoarjo', '08134000001', 'Ibu'),
  (9003, '2025103', '4103', 1, 'Orang tua Candra', 'Sidoarjo', '08134000002', 'Ayah'),
  (9004, '2025104', '4104', 1, 'Orang tua Dinda', 'Sidoarjo', '08134000003', 'Ibu'),
  (9005, '2025105', '4105', 1, 'Orang tua Erlangga', 'Sidoarjo', '08134000004', 'Ayah'),
  (9006, '2025106', '4106', 1, 'Orang tua Farah', 'Sidoarjo', '08134000005', 'Ibu'),
  (9007, '2025107', '4107', 1, 'Orang tua Gilang', 'Sidoarjo', '08134000006', 'Ayah'),
  (9008, '2025108', '4108', 1, 'Orang tua Hanifah', 'Sidoarjo', '08134000007', 'Ibu'),
  (9009, '2025109', '4109', 1, 'Orang tua Irfan', 'Sidoarjo', '08134000008', 'Ayah'),
  (9010, '2025110', '4110', 1, 'Orang tua Julia', 'Sidoarjo', '08134000009', 'Ibu'),
  (9011, '2025111', '4111', 901, 'Orang tua Kevin', 'Sidoarjo', '08134000010', 'Ayah'),
  (9012, '2025112', '4112', 901, 'Orang tua Laras', 'Sidoarjo', '08134000011', 'Ibu'),
  (9013, '2025113', '4113', 901, 'Orang tua Muhammad', 'Sidoarjo', '08134000012', 'Ayah'),
  (9014, '2025114', '4114', 901, 'Orang tua Nadia', 'Sidoarjo', '08134000013', 'Ibu'),
  (9015, '2025115', '4115', 901, 'Orang tua Oktavian', 'Sidoarjo', '08134000014', 'Ayah'),
  (9016, '2025116', '4116', 901, 'Orang tua Putri', 'Sidoarjo', '08134000015', 'Ibu'),
  (9017, '2025117', '4117', 901, 'Orang tua Qori', 'Sidoarjo', '08134000016', 'Ayah'),
  (9018, '2025118', '4118', 901, 'Orang tua Rendra', 'Sidoarjo', '08134000017', 'Ibu'),
  (9019, '2025119', '4119', 901, 'Orang tua Salsa', 'Sidoarjo', '08134000018', 'Ayah'),
  (9020, '2025120', '4120', 901, 'Orang tua Taufik', 'Sidoarjo', '08134000019', 'Ibu'),
  (9021, '2025121', '4121', 901, 'Orang tua Ulfa', 'Sidoarjo', '08134000020', 'Ayah'),
  (9022, '2025122', '4122', 901, 'Orang tua Vino', 'Sidoarjo', '08134000021', 'Ibu'),
  (9023, '2025123', '4123', 902, 'Orang tua Wulan', 'Sidoarjo', '08134000022', 'Ayah'),
  (9024, '2025124', '4124', 902, 'Orang tua Yoga', 'Sidoarjo', '08134000023', 'Ibu'),
  (9025, '2025125', '4125', 902, 'Orang tua Zahra', 'Sidoarjo', '08134000024', 'Ayah'),
  (9026, '2025126', '4126', 902, 'Orang tua Arif', 'Sidoarjo', '08134000025', 'Ibu'),
  (9027, '2025127', '4127', 902, 'Orang tua Bunga', 'Sidoarjo', '08134000026', 'Ayah'),
  (9028, '2025128', '4128', 902, 'Orang tua Cahyo', 'Sidoarjo', '08134000027', 'Ibu'),
  (9029, '2025129', '4129', 902, 'Orang tua Dewi', 'Sidoarjo', '08134000028', 'Ayah'),
  (9030, '2025130', '4130', 902, 'Orang tua Eka', 'Sidoarjo', '08134000029', 'Ibu'),
  (9031, '2025131', '4131', 902, 'Orang tua Fajar', 'Sidoarjo', '08134000030', 'Ayah'),
  (9032, '2025132', '4132', 902, 'Orang tua Gita', 'Sidoarjo', '08134000031', 'Ibu'),
  (9033, '2025133', '4133', 902, 'Orang tua Hendra', 'Sidoarjo', '08134000032', 'Ayah'),
  (9034, '2025134', '4134', 902, 'Orang tua Intan', 'Sidoarjo', '08134000033', 'Ibu');

-- --------------------------------------------------------------------------
-- Jadwal pelajaran guru demo
-- --------------------------------------------------------------------------
INSERT IGNORE INTO lesson_schedules (id, class_subject_id, hari, waktu, ruang_kelas) VALUES
  (901, 1, 'Rabu', '10:15 - 11:45', 'Ruang A1'),
  (902, 901, 'Selasa', '07:00 - 08:30', 'Ruang A2'),
  (903, 901, 'Kamis', '08:30 - 10:00', 'Ruang A2'),
  (904, 902, 'Senin', '10:15 - 11:45', 'Ruang B2'),
  (905, 902, 'Rabu', '07:00 - 08:30', 'Ruang B2'),
  (906, 902, 'Jumat', '08:30 - 10:00', 'Lab Matematika');

-- --------------------------------------------------------------------------
-- Jadwal akademik (agenda sekolah) — sebagian sudah lewat, sebagian mendatang
-- --------------------------------------------------------------------------
INSERT IGNORE INTO academic_events (id, academic_year_id, nama_kegiatan, tanggal_mulai, tanggal_selesai) VALUES
  (901, 1, 'Rapat Awal Semester Genap', DATE_SUB(CURDATE(), INTERVAL 150 DAY), DATE_SUB(CURDATE(), INTERVAL 150 DAY)),
  (902, 1, 'Penilaian Tengah Semester Genap', DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 53 DAY)),
  (903, 1, 'Pekan Literasi Sekolah', DATE_SUB(CURDATE(), INTERVAL 40 DAY), DATE_SUB(CURDATE(), INTERVAL 36 DAY)),
  (904, 1, 'Studi Lapangan Kelas XI', DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 19 DAY)),
  (905, 1, 'Pembagian Rapor Tengah Semester', DATE_SUB(CURDATE(), INTERVAL 14 DAY), DATE_SUB(CURDATE(), INTERVAL 14 DAY)),
  (906, 1, 'Simulasi Ujian Sumatif Akhir', DATE_ADD(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY)),
  (907, 1, 'Penilaian Sumatif Akhir Semester', DATE_ADD(CURDATE(), INTERVAL 21 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY)),
  (908, 1, 'Class Meeting & Pentas Seni', DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY));

-- --------------------------------------------------------------------------
-- Rubrik: lingkup materi + tujuan pembelajaran beserta deskriptor capaian
-- --------------------------------------------------------------------------
INSERT IGNORE INTO rubric_scopes (id, subject_id, semester_id, lingkup_materi, status_kunci) VALUES
  (901, 1, 2, 'Sistem Persamaan Linear Dua Variabel', 1),
  (902, 1, 2, 'Statistika Dasar', 0),
  (903, 1, 2, 'Trigonometri Dasar', 0),
  (904, 901, 2, 'Barisan dan Deret', 1),
  (905, 901, 2, 'Limit Fungsi Aljabar', 0),
  (906, 1, 1, 'Bilangan Berpangkat dan Logaritma', 1);

INSERT IGNORE INTO learning_objectives (id, rubric_scope_id, deskripsi, perlu_bimbingan, cukup, baik, sangat_baik) VALUES
  (901, 901, 'Memodelkan masalah kontekstual ke dalam SPLDV', 'Belum dapat menerjemahkan soal cerita menjadi persamaan', 'Dapat menyusun persamaan dengan bantuan langkah terarah', 'Dapat menyusun model SPLDV secara mandiri', 'Dapat menyusun sekaligus menilai kelayakan model yang dibuat'),
  (902, 901, 'Menyelesaikan SPLDV dengan metode eliminasi dan substitusi', 'Masih keliru pada operasi dasar', 'Dapat memakai satu metode', 'Dapat memilih metode yang efisien', 'Dapat membandingkan efisiensi antar metode'),
  (903, 902, 'Menyajikan data dalam tabel dan diagram yang tepat', 'Penyajian data belum sesuai jenis data', 'Penyajian benar dengan arahan', 'Penyajian tepat dan rapi', 'Penyajian tepat disertai alasan pemilihan diagram'),
  (904, 902, 'Menafsirkan ukuran pemusatan dan penyebaran data', 'Belum dapat menghitung mean/median/modus', 'Dapat menghitung tetapi belum menafsirkan', 'Dapat menghitung dan menafsirkan', 'Dapat menafsirkan sekaligus menarik simpulan kontekstual'),
  (905, 903, 'Menentukan perbandingan trigonometri pada segitiga siku-siku', 'Belum hafal perbandingan dasar', 'Dapat menentukan dengan bantuan gambar', 'Dapat menentukan secara mandiri', 'Dapat menerapkan pada masalah kontekstual'),
  (906, 903, 'Menggunakan identitas trigonometri dasar', 'Belum mengenali bentuk identitas', 'Dapat memakai satu identitas', 'Dapat memakai beberapa identitas', 'Dapat membuktikan identitas baru'),
  (907, 904, 'Menentukan pola, suku ke-n, dan jumlah deret aritmetika', 'Belum mengenali pola', 'Dapat menentukan suku ke-n sederhana', 'Dapat menentukan suku ke-n dan jumlah deret', 'Dapat menyelesaikan masalah kontekstual bertingkat'),
  (908, 904, 'Menerapkan barisan dan deret geometri pada masalah nyata', 'Belum membedakan aritmetika dan geometri', 'Dapat menghitung rasio dan suku ke-n', 'Dapat menghitung jumlah deret geometri', 'Dapat memodelkan pertumbuhan/peluruhan'),
  (909, 905, 'Menentukan nilai limit fungsi aljabar', 'Belum memahami konsep pendekatan nilai', 'Dapat menghitung limit substitusi langsung', 'Dapat menangani bentuk tak tentu', 'Dapat menjelaskan alasan tiap langkah penyelesaian'),
  (910, 905, 'Menggunakan limit untuk menganalisis perilaku fungsi', 'Belum dapat membaca perilaku grafik', 'Dapat membaca perilaku sederhana', 'Dapat menganalisis asimtot', 'Dapat menyimpulkan perilaku fungsi secara menyeluruh'),
  (911, 906, 'Menerapkan sifat bilangan berpangkat', 'Masih keliru pada sifat dasar', 'Dapat memakai sifat dengan contoh serupa', 'Dapat memakai sifat secara mandiri', 'Dapat menyederhanakan bentuk kompleks'),
  (912, 906, 'Menyelesaikan persamaan logaritma sederhana', 'Belum memahami definisi logaritma', 'Dapat menyelesaikan bentuk dasar', 'Dapat menyelesaikan bentuk bertingkat', 'Dapat menjelaskan strategi penyelesaian');

-- --------------------------------------------------------------------------
-- Materi kelas
-- --------------------------------------------------------------------------
INSERT IGNORE INTO materials (id, class_subject_id, rubric_scope_id, judul, deskripsi, status, created_by) VALUES
  (901, 1, 901, 'Modul SPLDV dan Penerapannya', 'Modul lengkap beserta contoh soal kontekstual SPLDV.', 'Visible', 3),
  (902, 1, 902, 'Ringkasan Statistika Dasar', 'Rangkuman ukuran pemusatan dan penyebaran data.', 'Visible', 3),
  (903, 901, 901, 'Modul SPLDV dan Penerapannya', 'Modul lengkap beserta contoh soal kontekstual SPLDV.', 'Visible', 3),
  (904, 901, 903, 'Pengantar Trigonometri', 'Perbandingan trigonometri pada segitiga siku-siku.', 'Visible', 3),
  (905, 902, 904, 'Barisan dan Deret Aritmetika', 'Konsep pola bilangan, suku ke-n, dan jumlah deret.', 'Visible', 3),
  (906, 902, 905, 'Pengantar Limit Fungsi', 'Konsep pendekatan nilai dan bentuk tak tentu.', 'Visible', 3);

INSERT IGNORE INTO material_files (id, material_id, file_name, file_url) VALUES
  (901, 901, 'materi-901.pdf', '/uploads/sample/materi-901.pdf'),
  (902, 902, 'materi-902.pdf', '/uploads/sample/materi-902.pdf'),
  (903, 903, 'materi-903.pdf', '/uploads/sample/materi-903.pdf'),
  (904, 904, 'materi-904.pdf', '/uploads/sample/materi-904.pdf'),
  (905, 905, 'materi-905.pdf', '/uploads/sample/materi-905.pdf'),
  (906, 906, 'materi-906.pdf', '/uploads/sample/materi-906.pdf');

INSERT IGNORE INTO comments (id, material_id, user_id, komentar) VALUES
  (901, 901, 9001, 'Pak, untuk metode campuran apakah boleh dipakai saat ulangan?'),
  (902, 901, 3, 'Boleh, asal langkahnya ditulis lengkap.'),
  (903, 905, 9023, 'Pak, contoh nomor 4 hasilnya kok berbeda ya?');

-- --------------------------------------------------------------------------
-- Tugas
-- --------------------------------------------------------------------------
INSERT IGNORE INTO assignments (id, class_subject_id, learning_objective_id, judul, deskripsi, deadline, status, created_by) VALUES
  (901, 1, 901, 'Tugas 1 - SPLDV', 'Kerjakan lembar kerja SPLDV sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Visible', 3),
  (902, 1, 903, 'Tugas 2 - Statistika', 'Kerjakan lembar kerja Statistika sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 115 DAY), 'Visible', 3),
  (903, 1, 905, 'Tugas 3 - Trigonometri', 'Kerjakan lembar kerja Trigonometri sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 80 DAY), 'Visible', 3),
  (904, 1, 902, 'Tugas 4 - SPLDV Lanjut', 'Kerjakan lembar kerja SPLDV Lanjut sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 45 DAY), 'Visible', 3),
  (905, 1, 904, 'Tugas 5 - Statistika Lanjut', 'Kerjakan lembar kerja Statistika Lanjut sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (906, 1, 906, 'Tugas 6 - Trigonometri Lanjut', 'Kerjakan lembar kerja Trigonometri Lanjut sesuai rubrik yang berlaku.', DATE_ADD(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (907, 901, 901, 'Tugas 1 - SPLDV', 'Kerjakan lembar kerja SPLDV sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Visible', 3),
  (908, 901, 903, 'Tugas 2 - Statistika', 'Kerjakan lembar kerja Statistika sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 115 DAY), 'Visible', 3),
  (909, 901, 905, 'Tugas 3 - Trigonometri', 'Kerjakan lembar kerja Trigonometri sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 80 DAY), 'Visible', 3),
  (910, 901, 902, 'Tugas 4 - SPLDV Lanjut', 'Kerjakan lembar kerja SPLDV Lanjut sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 45 DAY), 'Visible', 3),
  (911, 901, 904, 'Tugas 5 - Statistika Lanjut', 'Kerjakan lembar kerja Statistika Lanjut sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (912, 901, 906, 'Tugas 6 - Trigonometri Lanjut', 'Kerjakan lembar kerja Trigonometri Lanjut sesuai rubrik yang berlaku.', DATE_ADD(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (913, 902, 907, 'Tugas 1 - Barisan Aritmetika', 'Kerjakan lembar kerja Barisan Aritmetika sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 150 DAY), 'Visible', 3),
  (914, 902, 909, 'Tugas 2 - Limit Aljabar', 'Kerjakan lembar kerja Limit Aljabar sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 115 DAY), 'Visible', 3),
  (915, 902, 908, 'Tugas 3 - Deret Geometri', 'Kerjakan lembar kerja Deret Geometri sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 80 DAY), 'Visible', 3),
  (916, 902, 910, 'Tugas 4 - Perilaku Fungsi', 'Kerjakan lembar kerja Perilaku Fungsi sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 45 DAY), 'Visible', 3),
  (917, 902, 907, 'Tugas 5 - Barisan Lanjut', 'Kerjakan lembar kerja Barisan Lanjut sesuai rubrik yang berlaku.', DATE_SUB(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (918, 902, 909, 'Tugas 6 - Limit Lanjut', 'Kerjakan lembar kerja Limit Lanjut sesuai rubrik yang berlaku.', DATE_ADD(NOW(), INTERVAL 12 DAY), 'Visible', 3),
  (919, 1, 911, 'Tugas 1 - Bilangan Berpangkat', 'Lembar kerja semester ganjil.', DATE_SUB(NOW(), INTERVAL 240 DAY), 'Visible', 3),
  (920, 1, 912, 'Tugas 2 - Logaritma', 'Lembar kerja semester ganjil.', DATE_SUB(NOW(), INTERVAL 200 DAY), 'Visible', 3),
  (921, 901, 911, 'Tugas 1 - Bilangan Berpangkat', 'Lembar kerja semester ganjil.', DATE_SUB(NOW(), INTERVAL 240 DAY), 'Visible', 3),
  (922, 901, 912, 'Tugas 2 - Logaritma', 'Lembar kerja semester ganjil.', DATE_SUB(NOW(), INTERVAL 200 DAY), 'Visible', 3);

INSERT IGNORE INTO assignment_submissions (id, assignment_id, siswa_user_id, status, nilai, feedback, submitted_at) VALUES
  (901, 901, 5, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 901, 6, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 901, 9001, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (904, 901, 9002, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 901, 9003, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 901, 9004, 'Dinilai', 92.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 901, 9005, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (908, 901, 9006, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 901, 9007, 'Dinilai', 60.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 901, 9008, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 901, 9009, 'Dinilai', 75.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (912, 901, 9010, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 902, 5, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 902, 6, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (915, 902, 9001, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (916, 902, 9002, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (917, 902, 9003, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (918, 902, 9004, 'Dinilai', 94.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (919, 902, 9005, 'Dinilai', 67.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (920, 902, 9006, 'Dinilai', 83.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (921, 902, 9007, 'Dinilai', 62.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (922, 902, 9008, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (923, 902, 9009, 'Dinilai', 77.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (924, 902, 9010, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (925, 903, 5, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (926, 903, 6, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (927, 903, 9001, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (928, 903, 9002, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (929, 903, 9003, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (930, 903, 9004, 'Dinilai', 96.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (931, 903, 9005, 'Dinilai', 69.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (932, 903, 9006, 'Dinilai', 85.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (933, 903, 9007, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (934, 903, 9008, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (935, 903, 9009, 'Dinilai', 79.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (936, 903, 9010, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (937, 904, 5, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (938, 904, 6, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (939, 904, 9001, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (940, 904, 9002, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (941, 904, 9003, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (942, 904, 9004, 'Dinilai', 98.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (943, 904, 9005, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (944, 904, 9006, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (945, 904, 9007, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (946, 904, 9008, 'Dinilai', 88.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (947, 904, 9009, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (948, 904, 9010, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (949, 905, 5, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (950, 905, 6, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (951, 905, 9001, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (952, 905, 9002, 'Dinilai', 70.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (953, 905, 9003, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (954, 905, 9004, 'Dinilai', 100.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (955, 905, 9005, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (956, 905, 9006, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (957, 905, 9007, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (958, 905, 9008, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (959, 905, 9009, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (960, 905, 9010, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (961, 907, 9011, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (962, 907, 9012, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (963, 907, 9013, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (964, 907, 9014, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (965, 907, 9015, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (966, 907, 9016, 'Dinilai', 92.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (967, 907, 9017, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (968, 907, 9018, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (969, 907, 9019, 'Dinilai', 60.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (970, 907, 9020, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (971, 907, 9021, 'Dinilai', 75.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (972, 907, 9022, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (973, 908, 9011, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (974, 908, 9012, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (975, 908, 9013, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (976, 908, 9014, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (977, 908, 9015, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (978, 908, 9016, 'Dinilai', 94.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (979, 908, 9017, 'Dinilai', 67.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (980, 908, 9018, 'Dinilai', 83.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (981, 908, 9019, 'Dinilai', 62.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (982, 908, 9020, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (983, 908, 9021, 'Dinilai', 77.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (984, 908, 9022, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (985, 909, 9011, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (986, 909, 9012, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (987, 909, 9013, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (988, 909, 9014, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (989, 909, 9015, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (990, 909, 9016, 'Dinilai', 96.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (991, 909, 9017, 'Dinilai', 69.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (992, 909, 9018, 'Dinilai', 85.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (993, 909, 9019, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (994, 909, 9020, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (995, 909, 9021, 'Dinilai', 79.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (996, 909, 9022, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (997, 910, 9011, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (998, 910, 9012, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (999, 910, 9013, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1000, 910, 9014, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1001, 910, 9015, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1002, 910, 9016, 'Dinilai', 98.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1003, 910, 9017, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1004, 910, 9018, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1005, 910, 9019, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1006, 910, 9020, 'Dinilai', 88.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1007, 910, 9021, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1008, 910, 9022, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1009, 911, 9011, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1010, 911, 9012, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1011, 911, 9013, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1012, 911, 9014, 'Dinilai', 70.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1013, 911, 9015, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1014, 911, 9016, 'Dinilai', 100.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1015, 911, 9017, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1016, 911, 9018, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1017, 911, 9019, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1018, 911, 9020, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1019, 911, 9021, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1020, 911, 9022, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1021, 913, 9023, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1022, 913, 9024, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1023, 913, 9025, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1024, 913, 9026, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1025, 913, 9027, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1026, 913, 9028, 'Dinilai', 92.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1027, 913, 9029, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1028, 913, 9030, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1029, 913, 9031, 'Dinilai', 60.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1030, 913, 9032, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1031, 913, 9033, 'Dinilai', 75.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1032, 913, 9034, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1033, 914, 9023, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1034, 914, 9024, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1035, 914, 9025, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1036, 914, 9026, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1037, 914, 9027, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1038, 914, 9028, 'Dinilai', 94.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1039, 914, 9029, 'Dinilai', 67.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1040, 914, 9030, 'Dinilai', 83.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1041, 914, 9031, 'Dinilai', 62.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1042, 914, 9032, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1043, 914, 9033, 'Dinilai', 77.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1044, 914, 9034, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1045, 915, 9023, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1046, 915, 9024, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1047, 915, 9025, 'Dinilai', 80.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1048, 915, 9026, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1049, 915, 9027, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1050, 915, 9028, 'Dinilai', 96.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1051, 915, 9029, 'Dinilai', 69.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1052, 915, 9030, 'Dinilai', 85.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1053, 915, 9031, 'Dinilai', 64.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1054, 915, 9032, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1055, 915, 9033, 'Dinilai', 79.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1056, 915, 9034, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1057, 916, 9023, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1058, 916, 9024, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1059, 916, 9025, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1060, 916, 9026, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1061, 916, 9027, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1062, 916, 9028, 'Dinilai', 98.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1063, 916, 9029, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1064, 916, 9030, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1065, 916, 9031, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1066, 916, 9032, 'Dinilai', 88.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1067, 916, 9033, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1068, 916, 9034, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1069, 917, 9023, 'Dinilai', 95.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1070, 917, 9024, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1071, 917, 9025, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1072, 917, 9026, 'Dinilai', 70.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1073, 917, 9027, 'Dinilai', 86.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1074, 917, 9028, 'Dinilai', 100.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1075, 917, 9029, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1076, 917, 9030, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1077, 917, 9031, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1078, 917, 9032, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1079, 917, 9033, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1080, 917, 9034, 'Terkirim', NULL, NULL, DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1081, 919, 5, 'Dinilai', 96.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1082, 919, 6, 'Dinilai', 85.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1083, 919, 9001, 'Dinilai', 74.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1084, 919, 9002, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1085, 919, 9003, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1086, 919, 9004, 'Dinilai', 90.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1087, 919, 9005, 'Dinilai', 74.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1088, 919, 9006, 'Dinilai', 79.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1089, 919, 9007, 'Dinilai', 69.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1090, 919, 9008, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1091, 919, 9009, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1092, 919, 9010, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1093, 920, 5, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1094, 920, 6, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1095, 920, 9001, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1096, 920, 9002, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1097, 920, 9003, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1098, 920, 9004, 'Dinilai', 92.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1099, 920, 9005, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1100, 920, 9006, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1101, 920, 9007, 'Dinilai', 60.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1102, 920, 9008, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1103, 920, 9009, 'Dinilai', 75.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1104, 920, 9010, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1105, 921, 9011, 'Dinilai', 96.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1106, 921, 9012, 'Dinilai', 85.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1107, 921, 9013, 'Dinilai', 74.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1108, 921, 9014, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1109, 921, 9015, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1110, 921, 9016, 'Dinilai', 90.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1111, 921, 9017, 'Dinilai', 74.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1112, 921, 9018, 'Dinilai', 79.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1113, 921, 9019, 'Dinilai', 69.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1114, 921, 9020, 'Dinilai', 91.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1115, 921, 9021, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1116, 921, 9022, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1117, 922, 9011, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1118, 922, 9012, 'Dinilai', 87.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1119, 922, 9013, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1120, 922, 9014, 'Dinilai', 73.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1121, 922, 9015, 'Dinilai', 89.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1122, 922, 9016, 'Dinilai', 92.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1123, 922, 9017, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1124, 922, 9018, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1125, 922, 9019, 'Dinilai', 60.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1126, 922, 9020, 'Dinilai', 93.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1127, 922, 9021, 'Dinilai', 75.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (1128, 922, 9022, 'Dinilai', 78.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 180 DAY));

-- --------------------------------------------------------------------------
-- Ujian: Sumatif Lingkup Materi, STS, dan SAS
-- --------------------------------------------------------------------------
INSERT IGNORE INTO exams (id, class_subject_id, learning_objective_id, tipe_ujian, judul, deskripsi, tanggal_ujian, jam_mulai, jam_selesai, status_nilai, status_ujian, created_by) VALUES
  (901, 1, 901, 'Sumatif Lingkup Materi', 'Sumatif LM 1 - SPLDV', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 130 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (902, 1, 903, 'Sumatif Lingkup Materi', 'Sumatif LM 2 - Statistika', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 60 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (903, 1, 905, 'STS', 'STS Genap Matematika', 'Penilaian sts sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 25 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (904, 1, 902, 'SAS', 'SAS Genap Matematika', 'Penilaian sas sesuai rubrik lingkup materi.', DATE_ADD(CURDATE(), INTERVAL 21 DAY), '07:30:00', '09:00:00', 'Draft', 'Draft', 3),
  (905, 901, 901, 'Sumatif Lingkup Materi', 'Sumatif LM 1 - SPLDV', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 130 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (906, 901, 903, 'Sumatif Lingkup Materi', 'Sumatif LM 2 - Statistika', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 60 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (907, 901, 905, 'STS', 'STS Genap Matematika', 'Penilaian sts sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 25 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (908, 901, 902, 'SAS', 'SAS Genap Matematika', 'Penilaian sas sesuai rubrik lingkup materi.', DATE_ADD(CURDATE(), INTERVAL 21 DAY), '07:30:00', '09:00:00', 'Draft', 'Draft', 3),
  (909, 902, 907, 'Sumatif Lingkup Materi', 'Sumatif LM 1 - Barisan Aritmetika', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 130 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (910, 902, 909, 'Sumatif Lingkup Materi', 'Sumatif LM 2 - Limit Aljabar', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 60 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (911, 902, 908, 'STS', 'STS Genap Matematika', 'Penilaian sts sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 25 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (912, 902, 910, 'SAS', 'SAS Genap Matematika', 'Penilaian sas sesuai rubrik lingkup materi.', DATE_ADD(CURDATE(), INTERVAL 21 DAY), '07:30:00', '09:00:00', 'Draft', 'Draft', 3),
  (913, 1, 911, 'Sumatif Lingkup Materi', 'Sumatif LM Ganjil - Bilangan Berpangkat', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 210 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3),
  (914, 901, 911, 'Sumatif Lingkup Materi', 'Sumatif LM Ganjil - Bilangan Berpangkat', 'Penilaian sumatif lingkup materi sesuai rubrik lingkup materi.', DATE_SUB(CURDATE(), INTERVAL 210 DAY), '07:30:00', '09:00:00', 'Visible', 'Visible', 3);

INSERT IGNORE INTO exam_questions (id, exam_id, tipe_soal, pertanyaan, bobot, urutan) VALUES
  (901, 901, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (902, 902, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (903, 903, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (904, 904, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (905, 905, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (906, 906, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (907, 907, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (908, 908, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (909, 909, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (910, 910, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (911, 911, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (912, 912, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (913, 913, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1),
  (914, 914, 'Esai', 'Kerjakan seluruh butir soal sesuai instruksi pada lembar ujian.', 100, 1);

INSERT IGNORE INTO exam_answers (exam_id, question_id, siswa_user_id, jawaban_esai, nilai, status, answered_at) VALUES
  (901, 901, 5, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 6, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9001, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9002, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9003, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9004, 'Jawaban dikerjakan pada lembar ujian.', 93.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9005, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9006, 'Jawaban dikerjakan pada lembar ujian.', 82.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9007, 'Jawaban dikerjakan pada lembar ujian.', 61.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9008, 'Jawaban dikerjakan pada lembar ujian.', 94.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9009, 'Jawaban dikerjakan pada lembar ujian.', 76.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (901, 901, 9010, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 5, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 6, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9001, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9002, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9003, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9004, 'Jawaban dikerjakan pada lembar ujian.', 95.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9005, 'Jawaban dikerjakan pada lembar ujian.', 68.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9006, 'Jawaban dikerjakan pada lembar ujian.', 84.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9007, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9008, 'Jawaban dikerjakan pada lembar ujian.', 85.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9009, 'Jawaban dikerjakan pada lembar ujian.', 78.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (902, 902, 9010, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 5, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 6, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9001, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9002, 'Jawaban dikerjakan pada lembar ujian.', 67.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9003, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9004, 'Jawaban dikerjakan pada lembar ujian.', 97.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9005, 'Jawaban dikerjakan pada lembar ujian.', 70.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9006, 'Jawaban dikerjakan pada lembar ujian.', 86.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9007, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9008, 'Jawaban dikerjakan pada lembar ujian.', 87.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9009, 'Jawaban dikerjakan pada lembar ujian.', 80.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (903, 903, 9010, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9011, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9012, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9013, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9014, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9015, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9016, 'Jawaban dikerjakan pada lembar ujian.', 93.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9017, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9018, 'Jawaban dikerjakan pada lembar ujian.', 82.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9019, 'Jawaban dikerjakan pada lembar ujian.', 61.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9020, 'Jawaban dikerjakan pada lembar ujian.', 94.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9021, 'Jawaban dikerjakan pada lembar ujian.', 76.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (905, 905, 9022, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9011, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9012, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9013, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9014, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9015, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9016, 'Jawaban dikerjakan pada lembar ujian.', 95.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9017, 'Jawaban dikerjakan pada lembar ujian.', 68.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9018, 'Jawaban dikerjakan pada lembar ujian.', 84.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9019, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9020, 'Jawaban dikerjakan pada lembar ujian.', 85.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9021, 'Jawaban dikerjakan pada lembar ujian.', 78.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (906, 906, 9022, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9011, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9012, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9013, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9014, 'Jawaban dikerjakan pada lembar ujian.', 67.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9015, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9016, 'Jawaban dikerjakan pada lembar ujian.', 97.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9017, 'Jawaban dikerjakan pada lembar ujian.', 70.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9018, 'Jawaban dikerjakan pada lembar ujian.', 86.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9019, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9020, 'Jawaban dikerjakan pada lembar ujian.', 87.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9021, 'Jawaban dikerjakan pada lembar ujian.', 80.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (907, 907, 9022, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9023, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9024, 'Jawaban dikerjakan pada lembar ujian.', 88.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9025, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9026, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9027, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9028, 'Jawaban dikerjakan pada lembar ujian.', 93.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9029, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9030, 'Jawaban dikerjakan pada lembar ujian.', 82.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9031, 'Jawaban dikerjakan pada lembar ujian.', 61.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9032, 'Jawaban dikerjakan pada lembar ujian.', 94.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9033, 'Jawaban dikerjakan pada lembar ujian.', 76.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (909, 909, 9034, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9023, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9024, 'Jawaban dikerjakan pada lembar ujian.', 90.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9025, 'Jawaban dikerjakan pada lembar ujian.', 79.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9026, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9027, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9028, 'Jawaban dikerjakan pada lembar ujian.', 95.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9029, 'Jawaban dikerjakan pada lembar ujian.', 68.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9030, 'Jawaban dikerjakan pada lembar ujian.', 84.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9031, 'Jawaban dikerjakan pada lembar ujian.', 63.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9032, 'Jawaban dikerjakan pada lembar ujian.', 85.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9033, 'Jawaban dikerjakan pada lembar ujian.', 78.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (910, 910, 9034, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9023, 'Jawaban dikerjakan pada lembar ujian.', 92.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9024, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9025, 'Jawaban dikerjakan pada lembar ujian.', 81.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9026, 'Jawaban dikerjakan pada lembar ujian.', 67.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9027, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9028, 'Jawaban dikerjakan pada lembar ujian.', 97.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9029, 'Jawaban dikerjakan pada lembar ujian.', 70.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9030, 'Jawaban dikerjakan pada lembar ujian.', 86.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9031, 'Jawaban dikerjakan pada lembar ujian.', 65.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9032, 'Jawaban dikerjakan pada lembar ujian.', 87.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9033, 'Jawaban dikerjakan pada lembar ujian.', 80.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (911, 911, 9034, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 5, 'Jawaban dikerjakan pada lembar ujian.', 89.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 6, 'Jawaban dikerjakan pada lembar ujian.', 89.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9001, 'Jawaban dikerjakan pada lembar ujian.', 78.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9002, 'Jawaban dikerjakan pada lembar ujian.', 64.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9003, 'Jawaban dikerjakan pada lembar ujian.', 91.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9004, 'Jawaban dikerjakan pada lembar ujian.', 94.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9005, 'Jawaban dikerjakan pada lembar ujian.', 67.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9006, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9007, 'Jawaban dikerjakan pada lembar ujian.', 62.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9008, 'Jawaban dikerjakan pada lembar ujian.', 95.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9009, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (913, 913, 9010, 'Jawaban dikerjakan pada lembar ujian.', 80.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9011, 'Jawaban dikerjakan pada lembar ujian.', 89.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9012, 'Jawaban dikerjakan pada lembar ujian.', 89.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9013, 'Jawaban dikerjakan pada lembar ujian.', 78.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9014, 'Jawaban dikerjakan pada lembar ujian.', 64.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9015, 'Jawaban dikerjakan pada lembar ujian.', 91.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9016, 'Jawaban dikerjakan pada lembar ujian.', 94.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9017, 'Jawaban dikerjakan pada lembar ujian.', 67.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9018, 'Jawaban dikerjakan pada lembar ujian.', 83.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9019, 'Jawaban dikerjakan pada lembar ujian.', 62.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9020, 'Jawaban dikerjakan pada lembar ujian.', 95.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9021, 'Jawaban dikerjakan pada lembar ujian.', 77.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY)),
  (914, 914, 9022, 'Jawaban dikerjakan pada lembar ujian.', 80.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 180 DAY));

-- --------------------------------------------------------------------------
-- Melengkapi nilai tugas & ujian bawaan seed dasar di X IPA 1, supaya tidak
-- ada kolom yang hampir seluruhnya kosong ketika demo. Baris milik Andi (5)
-- dan Maya (6) tidak tersentuh karena unique key sudah menahannya.
-- --------------------------------------------------------------------------
INSERT IGNORE INTO assignment_submissions (id, assignment_id, siswa_user_id, status, nilai, feedback, submitted_at) VALUES
  (1202, 1, 9001, 'Dinilai', 82.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1203, 1, 9002, 'Dinilai', 68.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1204, 1, 9003, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1205, 1, 9004, 'Dinilai', 98.00, 'Pekerjaan sangat rapi dan lengkap.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1206, 1, 9005, 'Dinilai', 71.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1207, 1, 9006, 'Dinilai', 76.00, 'Cukup, perbanyak latihan soal serupa.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1208, 1, 9007, 'Dinilai', 66.00, 'Perlu bimbingan, silakan ikut sesi remedial.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1209, 1, 9008, 'Dinilai', 88.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1210, 1, 9009, 'Dinilai', 81.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 160 DAY)),
  (1211, 1, 9010, 'Dinilai', 84.00, 'Sudah baik, tingkatkan ketelitian langkah akhir.', DATE_SUB(NOW(), INTERVAL 160 DAY));

INSERT IGNORE INTO exam_answers (exam_id, question_id, siswa_user_id, jawaban_pilgan, nilai, status, answered_at) VALUES
  (1, 1, 6, 'B', 42.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9001, 'B', 36.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9002, 'B', 35.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9003, 'B', 43.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9004, 'B', 50.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9005, 'B', 36.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9006, 'B', 39.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9007, 'B', 34.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9008, 'B', 45.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9009, 'B', 36.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 1, 9010, 'B', 43.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY));

INSERT IGNORE INTO exam_answers (exam_id, question_id, siswa_user_id, jawaban_esai, nilai, status, answered_at) VALUES
  (1, 2, 6, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 43.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9001, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 37.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9002, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 36.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9003, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 44.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9004, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 45.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9005, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 37.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9006, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 40.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9007, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 29.50, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9008, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 46.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9009, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 37.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY)),
  (1, 2, 9010, 'Tentukan sumbu simetri lalu substitusi untuk memperoleh titik puncak.', 44.00, 'Dinilai', DATE_SUB(NOW(), INTERVAL 150 DAY));

-- --------------------------------------------------------------------------
-- Kelompok belajar
-- --------------------------------------------------------------------------
INSERT IGNORE INTO study_groups (id, class_subject_id, nama_kelompok) VALUES
  (901, 901, 'Kelompok Eliminasi'),
  (902, 901, 'Kelompok Substitusi'),
  (903, 902, 'Kelompok Deret');

INSERT IGNORE INTO study_group_members (group_id, siswa_user_id) VALUES
  (901, 9011),
  (901, 9012),
  (901, 9013),
  (901, 9014),
  (902, 9015),
  (902, 9016),
  (902, 9017),
  (902, 9018),
  (903, 9023),
  (903, 9024),
  (903, 9025),
  (903, 9026);

-- --------------------------------------------------------------------------
-- Pengumuman + notifikasi siswa (lonceng notifikasi di header)
-- --------------------------------------------------------------------------
INSERT IGNORE INTO announcements (id, author_user_id, class_subject_id, judul, isi, prioritas, pinned, created_at) VALUES
  (901, 3, 1, 'Persiapan Sumatif Akhir Semester', 'Silakan pelajari kembali lingkup materi SPLDV dan Statistika. Kisi-kisi sudah diunggah di menu Materi.', 'Penting', 1, DATE_SUB(NOW(), INTERVAL 3 DAY)),
  (902, 3, 901, 'Pengumpulan Tugas 5 Diperpanjang', 'Batas pengumpulan Tugas 5 diperpanjang sampai akhir pekan ini. Manfaatkan sebaik-baiknya.', 'Normal', 0, DATE_SUB(NOW(), INTERVAL 4 DAY)),
  (903, 3, 902, 'Jadwal Remedial Barisan dan Deret', 'Remedial dilaksanakan hari Jumat sepulang sekolah di Lab Matematika.', 'Mendesak', 1, DATE_SUB(NOW(), INTERVAL 5 DAY));

INSERT IGNORE INTO notifications (id, user_id, tipe, judul, isi, link, ref_id, is_read) VALUES
  (9001, 5, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9002, 6, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9003, 9001, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9004, 9002, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9005, 9003, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9006, 9004, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9007, 9005, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9008, 9006, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9009, 9007, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9010, 9008, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9011, 9009, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9012, 9010, 'announcement', 'Pengumuman: Persiapan Sumatif Akhir Semester', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 901, 0),
  (9013, 9011, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9014, 9012, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9015, 9013, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9016, 9014, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9017, 9015, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9018, 9016, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9019, 9017, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9020, 9018, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9021, 9019, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9022, 9020, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9023, 9021, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9024, 9022, 'announcement', 'Pengumuman: Pengumpulan Tugas 5 Diperpanjang', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 902, 0),
  (9025, 9023, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9026, 9024, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9027, 9025, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9028, 9026, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9029, 9027, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9030, 9028, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9031, 9029, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9032, 9030, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9033, 9031, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9034, 9032, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9035, 9033, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0),
  (9036, 9034, 'announcement', 'Pengumuman: Jadwal Remedial Barisan dan Deret', 'Budi Santoso membagikan pengumuman baru.', '/main/pengumumanSiswa', 903, 0);

-- ==========================================================================
-- Penyegaran tanggal
--
-- INSERT IGNORE di atas hanya berjalan sekali; blok berikut dijalankan tiap
-- startup supaya seluruh tanggal demo selalu relatif terhadap hari ini.
-- Tanpa ini, setelah beberapa bulan semua tugas/ujian demo akan tampak
-- kedaluwarsa dan panel 'Tugas Aktif' / 'Ujian Mendatang' menjadi kosong.
-- ==========================================================================

UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 150 DAY) WHERE id IN (901,907,913);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 115 DAY) WHERE id IN (902,908,914);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 80 DAY) WHERE id IN (903,909,915);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 45 DAY) WHERE id IN (904,910,916);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 12 DAY) WHERE id IN (905,911,917);
UPDATE assignments SET deadline = DATE_ADD(NOW(), INTERVAL 12 DAY) WHERE id IN (906,912,918);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 240 DAY) WHERE id IN (919,921);
UPDATE assignments SET deadline = DATE_SUB(NOW(), INTERVAL 200 DAY) WHERE id IN (920,922);

UPDATE exams SET tanggal_ujian = DATE_SUB(CURDATE(), INTERVAL 130 DAY) WHERE id IN (901,905,909);
UPDATE exams SET tanggal_ujian = DATE_SUB(CURDATE(), INTERVAL 60 DAY) WHERE id IN (902,906,910);
UPDATE exams SET tanggal_ujian = DATE_SUB(CURDATE(), INTERVAL 25 DAY) WHERE id IN (903,907,911);
UPDATE exams SET tanggal_ujian = DATE_ADD(CURDATE(), INTERVAL 21 DAY) WHERE id IN (904,908,912);
UPDATE exams SET tanggal_ujian = DATE_SUB(CURDATE(), INTERVAL 210 DAY) WHERE id IN (913,914);

-- Tanggal pengumpulan tugas ikut digeser; updated_at menjadi sumbu grafik
-- tren nilai 6 bulan pada dashboard guru, jadi tiap slot harus jatuh di
-- bulan yang berbeda.
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 152 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 150 DAY) WHERE assignment_id IN (901,907,913);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 117 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 115 DAY) WHERE assignment_id IN (902,908,914);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 82 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 80 DAY) WHERE assignment_id IN (903,909,915);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 47 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 45 DAY) WHERE assignment_id IN (904,910,916);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 14 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 12 DAY) WHERE assignment_id IN (905,911,917);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 242 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 240 DAY) WHERE assignment_id IN (919,921);
UPDATE assignment_submissions SET submitted_at = DATE_SUB(NOW(), INTERVAL 202 DAY), updated_at = DATE_SUB(NOW(), INTERVAL 200 DAY) WHERE assignment_id IN (920,922);

UPDATE exam_answers SET answered_at = DATE_SUB(NOW(), INTERVAL 130 DAY) WHERE exam_id IN (901,905,909);
UPDATE exam_answers SET answered_at = DATE_SUB(NOW(), INTERVAL 60 DAY) WHERE exam_id IN (902,906,910);
UPDATE exam_answers SET answered_at = DATE_SUB(NOW(), INTERVAL 25 DAY) WHERE exam_id IN (903,907,911);
UPDATE exam_answers SET answered_at = DATE_SUB(NOW(), INTERVAL 210 DAY) WHERE exam_id IN (913,914);

UPDATE announcements SET created_at = DATE_SUB(NOW(), INTERVAL 3 DAY) WHERE id = 901;
UPDATE announcements SET created_at = DATE_SUB(NOW(), INTERVAL 4 DAY) WHERE id = 902;
UPDATE announcements SET created_at = DATE_SUB(NOW(), INTERVAL 5 DAY) WHERE id = 903;

UPDATE academic_events SET tanggal_mulai = CASE id
    WHEN 901 THEN DATE_SUB(CURDATE(), INTERVAL 150 DAY)
    WHEN 902 THEN DATE_SUB(CURDATE(), INTERVAL 60 DAY)
    WHEN 903 THEN DATE_SUB(CURDATE(), INTERVAL 40 DAY)
    WHEN 904 THEN DATE_SUB(CURDATE(), INTERVAL 20 DAY)
    WHEN 905 THEN DATE_SUB(CURDATE(), INTERVAL 14 DAY)
    WHEN 906 THEN DATE_ADD(CURDATE(), INTERVAL 10 DAY)
    WHEN 907 THEN DATE_ADD(CURDATE(), INTERVAL 21 DAY)
    WHEN 908 THEN DATE_ADD(CURDATE(), INTERVAL 30 DAY)
  END,
  tanggal_selesai = CASE id
    WHEN 901 THEN DATE_SUB(CURDATE(), INTERVAL 150 DAY)
    WHEN 902 THEN DATE_SUB(CURDATE(), INTERVAL 53 DAY)
    WHEN 903 THEN DATE_SUB(CURDATE(), INTERVAL 36 DAY)
    WHEN 904 THEN DATE_SUB(CURDATE(), INTERVAL 19 DAY)
    WHEN 905 THEN DATE_SUB(CURDATE(), INTERVAL 14 DAY)
    WHEN 906 THEN DATE_ADD(CURDATE(), INTERVAL 9 DAY)
    WHEN 907 THEN DATE_ADD(CURDATE(), INTERVAL 14 DAY)
    WHEN 908 THEN DATE_ADD(CURDATE(), INTERVAL 28 DAY)
  END
WHERE id BETWEEN 901 AND 908;

