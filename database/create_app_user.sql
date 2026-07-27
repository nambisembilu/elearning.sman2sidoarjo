-- =====================================================================
--  Buat user aplikasi + set password + beri akses penuh ke satu database
--  Target: database `elearning_sma` (e-learning SMAN 2 Sidoarjo)
--  Kompatibel: MySQL 8.x
--
--  Jalankan sebagai root:
--      mysql -u root -p < database/create_app_user.sql
--  atau tempel isinya di dalam sesi `mysql -u root -p`.
--
--  GANTI dulu nilai password di bawah sebelum dipakai di produksi.
-- =====================================================================

-- 1) Pastikan database ada (charset utf8mb4 agar mendukung emoji/aksara lengkap).
CREATE DATABASE IF NOT EXISTS `elearning_sma`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- 2) Buat user aplikasi.
--    - '%'         = bisa konek dari host mana pun (dipakai Docker/Coolify,
--                    karena app container konek lewat jaringan, bukan localhost).
--    - 'localhost' = hanya dari mesin yang sama (dipakai jika app & MySQL 1 server).
--    Buat keduanya agar aman untuk kedua skenario; hapus yang tak perlu.

CREATE USER IF NOT EXISTS 'elearning'@'%'
  IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';

CREATE USER IF NOT EXISTS 'elearning'@'localhost'
  IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';

-- 3) (Opsional) Set/ubah password bila user sudah ada sebelumnya.
ALTER USER 'elearning'@'%'         IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';
ALTER USER 'elearning'@'localhost' IDENTIFIED BY 'GANTI_DENGAN_PASSWORD_KUAT';

-- 4) Beri akses PENUH, tetapi HANYA ke database `elearning_sma`
--    (bukan seluruh server). Ini praktik aman: user aplikasi tidak boleh
--    menyentuh database lain.
GRANT ALL PRIVILEGES ON `elearning_sma`.* TO 'elearning'@'%';
GRANT ALL PRIVILEGES ON `elearning_sma`.* TO 'elearning'@'localhost';

-- 5) Terapkan perubahan privilege.
FLUSH PRIVILEGES;

-- 6) Verifikasi (opsional) — tampilkan hak akses yang diberikan.
SHOW GRANTS FOR 'elearning'@'%';
SHOW GRANTS FOR 'elearning'@'localhost';
