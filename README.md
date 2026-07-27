# E-Learning SMAN 2 Sidoarjo

Rebuild aplikasi Flutter e-learning menjadi stack web:

- Frontend: React + Vite + Tailwind CSS dengan komponen shadcn-style lokal.
- Backend: Express.js REST API.
- Database: MySQL database `elearning_sma`.

Kode Flutter lama tetap ada sebagai referensi migrasi di folder `flutter/`. Aplikasi web baru berada di root project (`src/`, `server/`, `database/`).

## Fitur

- Auth role-based: admin, staff kurikulum, guru, siswa.
- Admin: daftar staff kurikulum dan log aktivitas.
- Staff: data guru, data siswa, kelas, mata pelajaran, jadwal akademik, jadwal pelajaran, rubrik mapel, tahun ajaran, range nilai, dan rekap nilai.
- Guru: kelas mengajar, materi, komentar, tugas, pengumpulan tugas, ujian, jawaban ujian, kelompok belajar, rubrik, jadwal mengajar, dan nilai.
- Siswa: kelas, materi, komentar, tugas, pengumpulan tugas, ujian, jawaban, jadwal pelajaran, dan nilai.
- Upload file lokal melalui backend `/uploads`.

## Setup

1. Install dependency:

```bash
npm install
```

2. Siapkan `.env` dari contoh:

```bash
cp .env.example .env
```

3. Isi kredensial MySQL di `.env`, lalu import skema:

```bash
mysql -u <user> -p < database/elearning_sma.sql
```

4. Jalankan backend dan frontend:

```bash
npm run server
npm run dev
```

Frontend: `http://127.0.0.1:5173/`

Backend: `http://127.0.0.1:4000/api`

## Akun Demo

Identifier dan password untuk login (info ini tidak ditampilkan di halaman login):

| Role | Identifier | Password |
|---|---|---|
| Admin | `1000` | `password` |
| Staff Kurikulum | `2000` | `password` |
| Guru | `3000` | `password` |
| Siswa | `4000` | `password` |

## Verifikasi

```bash
npm run build
npm audit --audit-level=high
node --check server/index.js
```
