CREATE DATABASE IF NOT EXISTS elearning_sma
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE elearning_sma;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  identifier VARCHAR(64) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  nama VARCHAR(160) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  no_telp VARCHAR(32),
  alamat TEXT,
  role ENUM('admin', 'staff', 'guru', 'siswa') NOT NULL,
  jenis_kelamin VARCHAR(24),
  agama VARCHAR(64),
  token TEXT,
  reset_otp VARCHAR(12),
  reset_otp_expires_at DATETIME,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS guru_profiles (
  user_id INT PRIMARY KEY,
  nip_nuptk VARCHAR(64) NOT NULL UNIQUE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS academic_years (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tahun_ajaran VARCHAR(24) NOT NULL UNIQUE,
  is_active TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS semesters (
  id INT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id INT NOT NULL,
  judul_semester ENUM('Ganjil', 'Genap') NOT NULL,
  tanggal_mulai DATE,
  is_active TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY uniq_semester_year (academic_year_id, judul_semester),
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS classes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id INT NOT NULL,
  jenjang ENUM('X', 'XI', 'XII') NOT NULL,
  jurusan VARCHAR(64) NOT NULL,
  nama_kelas VARCHAR(96) NOT NULL,
  ruang_kelas VARCHAR(96),
  wali_kelas_user_id INT,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_class_year (academic_year_id, nama_kelas),
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
  FOREIGN KEY (wali_kelas_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS siswa_profiles (
  user_id INT PRIMARY KEY,
  nis VARCHAR(64) NOT NULL UNIQUE,
  nisn VARCHAR(64) NOT NULL UNIQUE,
  kelas_id INT,
  nama_wali_murid VARCHAR(160),
  alamat_wali_murid TEXT,
  no_telp_wali_murid VARCHAR(32),
  status_wali_murid VARCHAR(64),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (kelas_id) REFERENCES classes(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS class_students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  siswa_user_id INT NOT NULL,
  academic_year_id INT NOT NULL,
  status ENUM('Aktif', 'Naik', 'Tinggal', 'Lulus', 'Pindah') NOT NULL DEFAULT 'Aktif',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_class_student (class_id, siswa_user_id),
  KEY idx_class_student_siswa (siswa_user_id),
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (siswa_user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id)
);

CREATE TABLE IF NOT EXISTS subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  judul_mapel VARCHAR(160) NOT NULL,
  jenjang ENUM('X', 'XI', 'XII') NOT NULL,
  jurusan VARCHAR(64) NOT NULL,
  koordinator_user_id INT,
  deleted_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_subject_scope (judul_mapel, jenjang, jurusan),
  FOREIGN KEY (koordinator_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS guru_subjects (
  guru_user_id INT NOT NULL,
  subject_id INT NOT NULL,
  PRIMARY KEY (guru_user_id, subject_id),
  FOREIGN KEY (guru_user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS class_subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_id INT NOT NULL,
  subject_id INT NOT NULL,
  guru_user_id INT NOT NULL,
  academic_year_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_class_subject_teacher (class_id, subject_id, guru_user_id),
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (guru_user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id)
);

CREATE TABLE IF NOT EXISTS lesson_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_subject_id INT NOT NULL,
  hari VARCHAR(24) NOT NULL,
  waktu VARCHAR(64) NOT NULL,
  ruang_kelas VARCHAR(96),
  deleted_at DATETIME NULL,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS academic_events (
  id INT AUTO_INCREMENT PRIMARY KEY,
  academic_year_id INT NOT NULL,
  nama_kegiatan VARCHAR(180) NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_selesai DATE NOT NULL,
  deleted_at DATETIME NULL,
  FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS rubric_scopes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  subject_id INT NOT NULL,
  semester_id INT NOT NULL,
  lingkup_materi VARCHAR(180) NOT NULL,
  status_kunci TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS learning_objectives (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rubric_scope_id INT NOT NULL,
  deskripsi TEXT NOT NULL,
  perlu_bimbingan TEXT,
  cukup TEXT,
  baik TEXT,
  sangat_baik TEXT,
  FOREIGN KEY (rubric_scope_id) REFERENCES rubric_scopes(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS materials (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_subject_id INT NOT NULL,
  rubric_scope_id INT,
  judul VARCHAR(180) NOT NULL,
  deskripsi MEDIUMTEXT,
  status ENUM('Draft', 'Visible', 'Hidden') NOT NULL DEFAULT 'Draft',
  created_by INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (rubric_scope_id) REFERENCES rubric_scopes(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS material_files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  material_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  material_id INT NOT NULL,
  user_id INT NOT NULL,
  komentar TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  FOREIGN KEY (material_id) REFERENCES materials(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS assignments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_subject_id INT NOT NULL,
  learning_objective_id INT,
  judul VARCHAR(180) NOT NULL,
  deskripsi MEDIUMTEXT,
  deadline DATETIME,
  status ENUM('Draft', 'Visible', 'Hidden') NOT NULL DEFAULT 'Draft',
  created_by INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (learning_objective_id) REFERENCES learning_objectives(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS assignment_files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS assignment_submissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  assignment_id INT NOT NULL,
  siswa_user_id INT NOT NULL,
  status ENUM('Terkirim', 'Revisi', 'Dinilai') NOT NULL DEFAULT 'Terkirim',
  nilai DECIMAL(5,2),
  feedback TEXT,
  submitted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_assignment_student (assignment_id, siswa_user_id),
  FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
  FOREIGN KEY (siswa_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS submission_files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  submission_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  FOREIGN KEY (submission_id) REFERENCES assignment_submissions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exams (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_subject_id INT NOT NULL,
  learning_objective_id INT,
  tipe_ujian ENUM('Latihan Soal', 'Sumatif Lingkup Materi', 'STS', 'SAS') NOT NULL,
  judul VARCHAR(180) NOT NULL,
  deskripsi MEDIUMTEXT,
  tanggal_ujian DATE,
  jam_mulai TIME,
  jam_selesai TIME,
  status_nilai ENUM('Draft', 'Visible', 'Hidden') NOT NULL DEFAULT 'Draft',
  status_ujian ENUM('Draft', 'Visible', 'Hidden') NOT NULL DEFAULT 'Draft',
  created_by INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (learning_objective_id) REFERENCES learning_objectives(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS exam_questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exam_id INT NOT NULL,
  tipe_soal ENUM('Pilihan Ganda', 'Esai') NOT NULL,
  pertanyaan MEDIUMTEXT NOT NULL,
  opsi_a TEXT,
  opsi_b TEXT,
  opsi_c TEXT,
  opsi_d TEXT,
  jawaban_benar VARCHAR(8),
  bobot DECIMAL(5,2) NOT NULL DEFAULT 1,
  urutan INT NOT NULL DEFAULT 1,
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS exam_answers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  exam_id INT NOT NULL,
  question_id INT NOT NULL,
  siswa_user_id INT NOT NULL,
  jawaban_pilgan VARCHAR(8),
  jawaban_esai MEDIUMTEXT,
  nilai DECIMAL(5,2),
  status ENUM('Tersimpan', 'Dinilai') NOT NULL DEFAULT 'Tersimpan',
  answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_answer (question_id, siswa_user_id),
  FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES exam_questions(id) ON DELETE CASCADE,
  FOREIGN KEY (siswa_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS study_groups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_subject_id INT NOT NULL,
  nama_kelompok VARCHAR(160) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS study_group_members (
  group_id INT NOT NULL,
  siswa_user_id INT NOT NULL,
  PRIMARY KEY (group_id, siswa_user_id),
  FOREIGN KEY (group_id) REFERENCES study_groups(id) ON DELETE CASCADE,
  FOREIGN KEY (siswa_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS staff_curriculum (
  user_id INT PRIMARY KEY,
  assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS grade_ranges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kategori VARCHAR(80) NOT NULL,
  min_nilai DECIMAL(5,2) NOT NULL,
  max_nilai DECIMAL(5,2) NOT NULL,
  deskripsi TEXT
);

CREATE TABLE IF NOT EXISTS announcements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  author_user_id INT NOT NULL,
  class_subject_id INT NULL,
  sasaran ENUM('semua', 'siswa', 'kelas') NOT NULL DEFAULT 'kelas',
  judul VARCHAR(180) NOT NULL,
  isi MEDIUMTEXT NOT NULL,
  prioritas ENUM('Normal', 'Penting', 'Mendesak') NOT NULL DEFAULT 'Normal',
  pinned TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  FOREIGN KEY (author_user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  tipe VARCHAR(48) NOT NULL DEFAULT 'announcement',
  judul VARCHAR(200) NOT NULL,
  isi TEXT,
  link VARCHAR(255),
  ref_id INT,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notif_user (user_id, is_read),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  aksi VARCHAR(160) NOT NULL,
  entitas VARCHAR(120),
  entitas_id INT,
  detail TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

INSERT IGNORE INTO users (id, identifier, password_hash, nama, email, no_telp, alamat, role, jenis_kelamin, agama) VALUES
  (1, '1000', 'password', 'Admin E-Learning', 'admin@sman2sidoarjo.sch.id', '081200000001', 'SMAN 2 Sidoarjo', 'admin', 'Laki-laki', 'Islam'),
  (2, '2000', 'password', 'Wakasek Kurikulum', 'staff@sman2sidoarjo.sch.id', '081200000002', 'SMAN 2 Sidoarjo', 'staff', 'Perempuan', 'Islam'),
  (3, '3000', 'password', 'Budi Santoso', 'budi@sman2sidoarjo.sch.id', '081200000003', 'Sidoarjo', 'guru', 'Laki-laki', 'Islam'),
  (4, '3001', 'password', 'Siti Rahma', 'siti@sman2sidoarjo.sch.id', '081200000004', 'Sidoarjo', 'guru', 'Perempuan', 'Islam'),
  (5, '4000', 'password', 'Andi Pratama', 'andi@student.sman2sidoarjo.sch.id', '081200000005', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam'),
  (6, '4001', 'password', 'Maya Putri', 'maya@student.sman2sidoarjo.sch.id', '081200000006', 'Sidoarjo', 'siswa', 'Perempuan', 'Islam'),
  (7, '4002', 'password', 'Raka Wijaya', 'raka@student.sman2sidoarjo.sch.id', '081200000007', 'Sidoarjo', 'siswa', 'Laki-laki', 'Islam');

INSERT IGNORE INTO guru_profiles (user_id, nip_nuptk) VALUES
  (3, '3000'),
  (4, '3001');

INSERT IGNORE INTO academic_years (id, tahun_ajaran, is_active) VALUES
  (1, '2025/2026', 1),
  (2, '2026/2027', 0);

INSERT IGNORE INTO semesters (id, academic_year_id, judul_semester, tanggal_mulai, is_active) VALUES
  (1, 1, 'Ganjil', '2025-07-14', 0),
  (2, 1, 'Genap', '2026-01-05', 1),
  (3, 2, 'Ganjil', '2026-07-13', 0),
  (4, 2, 'Genap', '2027-01-04', 0);

INSERT IGNORE INTO classes (id, academic_year_id, jenjang, jurusan, nama_kelas, ruang_kelas, wali_kelas_user_id) VALUES
  (1, 1, 'X', 'IPA', 'X IPA 1', 'Ruang A1', 3),
  (2, 1, 'XI', 'IPS', 'XI IPS 1', 'Ruang B1', 4);

INSERT IGNORE INTO siswa_profiles (user_id, nis, nisn, kelas_id, nama_wali_murid, alamat_wali_murid, no_telp_wali_murid, status_wali_murid) VALUES
  (5, '2025001', '4000', 1, 'Slamet', 'Sidoarjo', '081211111111', 'Ayah'),
  (6, '2025002', '4001', 1, 'Wati', 'Sidoarjo', '081222222222', 'Ibu'),
  (7, '2025003', '4002', 2, 'Hendra', 'Sidoarjo', '081233333333', 'Ayah');

INSERT IGNORE INTO subjects (id, judul_mapel, jenjang, jurusan, koordinator_user_id) VALUES
  (1, 'Matematika', 'X', 'IPA', 3),
  (2, 'Bahasa Indonesia', 'X', 'IPA', 4),
  (3, 'Ekonomi', 'XI', 'IPS', 4);

INSERT IGNORE INTO guru_subjects (guru_user_id, subject_id) VALUES
  (3, 1),
  (4, 2),
  (4, 3);

INSERT IGNORE INTO class_subjects (id, class_id, subject_id, guru_user_id, academic_year_id) VALUES
  (1, 1, 1, 3, 1),
  (2, 1, 2, 4, 1),
  (3, 2, 3, 4, 1);

INSERT IGNORE INTO lesson_schedules (id, class_subject_id, hari, waktu, ruang_kelas) VALUES
  (1, 1, 'Senin', '07:00 - 08:30', 'Ruang A1'),
  (2, 2, 'Selasa', '08:30 - 10:00', 'Ruang A1'),
  (3, 3, 'Rabu', '10:15 - 11:45', 'Ruang B1');

INSERT IGNORE INTO academic_events (id, academic_year_id, nama_kegiatan, tanggal_mulai, tanggal_selesai) VALUES
  (1, 1, 'Penilaian Akhir Semester Genap', '2026-06-08', '2026-06-15'),
  (2, 1, 'Class Meeting', '2026-06-17', '2026-06-19');

INSERT IGNORE INTO rubric_scopes (id, subject_id, semester_id, lingkup_materi, status_kunci) VALUES
  (1, 1, 2, 'Fungsi Kuadrat', 1),
  (2, 2, 2, 'Teks Argumentasi', 0),
  (3, 3, 2, 'Pasar dan Harga', 0);

INSERT IGNORE INTO learning_objectives (id, rubric_scope_id, deskripsi, perlu_bimbingan, cukup, baik, sangat_baik) VALUES
  (1, 1, 'Menganalisis grafik fungsi kuadrat', 'Perlu memahami bentuk dasar grafik', 'Dapat membaca grafik sederhana', 'Dapat menganalisis titik penting', 'Dapat memecahkan masalah kontekstual'),
  (2, 1, 'Menyelesaikan persamaan kuadrat', 'Perlu latihan faktorisasi', 'Dapat memakai rumus umum', 'Dapat memilih metode efektif', 'Dapat menjelaskan alasan metode'),
  (3, 2, 'Menyusun argumen berbasis data', 'Argumen belum runtut', 'Argumen cukup runtut', 'Argumen jelas dan berbukti', 'Argumen kuat, kritis, dan koheren');

INSERT IGNORE INTO materials (id, class_subject_id, rubric_scope_id, judul, deskripsi, status, created_by) VALUES
  (1, 1, 1, 'Pengantar Fungsi Kuadrat', 'Bahan belajar konsep dasar fungsi kuadrat dan bentuk grafiknya.', 'Visible', 3),
  (2, 2, 2, 'Struktur Teks Argumentasi', 'Materi tentang tesis, argumen, dan penegasan ulang.', 'Visible', 4);

INSERT IGNORE INTO material_files (material_id, file_name, file_url) VALUES
  (1, 'fungsi-kuadrat.pdf', '/uploads/sample/fungsi-kuadrat.pdf'),
  (2, 'teks-argumentasi.pdf', '/uploads/sample/teks-argumentasi.pdf');

INSERT IGNORE INTO comments (material_id, user_id, komentar) VALUES
  (1, 5, 'Pak, contoh soal nomor 3 bisa dibahas lagi?'),
  (1, 3, 'Bisa, nanti kita bahas di pertemuan berikutnya.');

INSERT IGNORE INTO assignments (id, class_subject_id, learning_objective_id, judul, deskripsi, deadline, status, created_by) VALUES
  (1, 1, 1, 'Latihan Grafik Fungsi Kuadrat', 'Kerjakan analisis grafik dari lembar soal.', '2026-06-10 23:59:00', 'Visible', 3),
  (2, 2, 3, 'Esai Argumentasi Lingkungan', 'Tulis esai argumentasi singkat berbasis data.', '2026-06-12 23:59:00', 'Visible', 4);

INSERT IGNORE INTO assignment_files (assignment_id, file_name, file_url) VALUES
  (1, 'latihan-grafik.pdf', '/uploads/sample/latihan-grafik.pdf');

INSERT IGNORE INTO assignment_submissions (id, assignment_id, siswa_user_id, status, nilai, feedback) VALUES
  (1, 1, 5, 'Dinilai', 88.00, 'Analisis grafik sudah baik.'),
  (2, 1, 6, 'Terkirim', NULL, NULL);

INSERT IGNORE INTO submission_files (submission_id, file_name, file_url) VALUES
  (1, 'jawaban-andi.pdf', '/uploads/sample/jawaban-andi.pdf');

INSERT IGNORE INTO exams (id, class_subject_id, learning_objective_id, tipe_ujian, judul, deskripsi, tanggal_ujian, jam_mulai, jam_selesai, status_nilai, status_ujian, created_by) VALUES
  (1, 1, 2, 'Sumatif Lingkup Materi', 'Sumatif LM Fungsi Kuadrat', 'Ujian singkat lingkup materi fungsi kuadrat.', '2026-06-05', '08:00:00', '09:00:00', 'Visible', 'Visible', 3),
  (2, 1, NULL, 'STS', 'STS Matematika Genap', 'Penilaian tengah semester genap.', '2026-06-14', '08:00:00', '10:00:00', 'Draft', 'Draft', 3);

INSERT IGNORE INTO exam_questions (id, exam_id, tipe_soal, pertanyaan, opsi_a, opsi_b, opsi_c, opsi_d, jawaban_benar, bobot, urutan) VALUES
  (1, 1, 'Pilihan Ganda', 'Sumbu simetri dari y = x^2 - 4x + 3 adalah ...', 'x = 1', 'x = 2', 'x = 3', 'x = 4', 'B', 50, 1),
  (2, 1, 'Esai', 'Jelaskan langkah menentukan titik puncak fungsi kuadrat.', NULL, NULL, NULL, NULL, NULL, 50, 2);

INSERT IGNORE INTO exam_answers (exam_id, question_id, siswa_user_id, jawaban_pilgan, jawaban_esai, nilai, status) VALUES
  (1, 1, 5, 'B', NULL, 50.00, 'Dinilai'),
  (1, 2, 5, NULL, 'Gunakan rumus -b/2a lalu substitusi nilai x.', 42.00, 'Dinilai');

INSERT IGNORE INTO study_groups (id, class_subject_id, nama_kelompok) VALUES
  (1, 1, 'Kelompok Aljabar');

INSERT IGNORE INTO study_group_members (group_id, siswa_user_id) VALUES
  (1, 5),
  (1, 6);

INSERT IGNORE INTO staff_curriculum (user_id) VALUES (2);

INSERT IGNORE INTO grade_ranges (id, kategori, min_nilai, max_nilai, deskripsi) VALUES
  (1, 'Perlu Bimbingan', 0, 69.99, 'Memerlukan pendampingan intensif'),
  (2, 'Cukup', 70, 79.99, 'Capaian dasar terpenuhi'),
  (3, 'Baik', 80, 89.99, 'Capaian kuat dan konsisten'),
  (4, 'Sangat Baik', 90, 100, 'Capaian sangat menonjol');

INSERT IGNORE INTO activity_logs (user_id, aksi, entitas, entitas_id, detail) VALUES
  (1, 'Seed database', 'system', NULL, 'Data awal elearning_sma berhasil dibuat'),
  (3, 'Membuat materi', 'materials', 1, 'Pengantar Fungsi Kuadrat');
