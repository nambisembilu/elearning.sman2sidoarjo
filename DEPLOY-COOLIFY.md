# Deployment ke Coolify

Aplikasi dikemas sebagai **satu container**: Express melayani REST API (`/api`),
file upload (`/uploads`), sekaligus hasil build frontend (SPA React). Karena
frontend dan API satu origin, tidak ada masalah CORS dan `VITE_API_URL` tidak
perlu di-hardcode ke domain tertentu — cukup path relatif `/api`.

Database MySQL berjalan sebagai service terpisah di dalam `docker-compose.yaml`.

## Ringkasan file deployment

| File | Fungsi |
|---|---|
| `Dockerfile` | Multi-stage: build Vite → runtime Node (produksi saja) |
| `docker-compose.yaml` | Stack `app` + `db` (MySQL), volume, healthcheck, auto-seed |
| `.dockerignore` | Mengecualikan `flutter/`, `node_modules`, `.env`, dsb. |
| `.env.production.example` | Daftar environment variable untuk diisi di Coolify |

---

## Cara deploy (rekomendasi: Docker Compose)

1. **Push project ke Git** (GitHub/GitLab/Gitea) yang terhubung ke Coolify.
   Pastikan `.env` **tidak** ikut ter-commit (sudah di `.gitignore`).

2. Di Coolify: **New Resource → Docker Compose**, arahkan ke repo & branch,
   set **Compose file** = `docker-compose.yaml`.

3. Di tab **Environment Variables**, isi minimal berikut (lihat
   `.env.production.example`):

   ```
   JWT_SECRET=<hasil `openssl rand -hex 32`>
   DB_USER=elearning
   DB_PASSWORD=<password kuat>
   DB_ROOT_PASSWORD=<password kuat lain>
   DB_NAME=elearning_sma
   ```

4. Pada service **app**, set **Domain** (mis. `https://elearning.sman2sidoarjo.sch.id`)
   dan **Port** yang di-expose = `4000`. Coolify mengurus HTTPS/Let's Encrypt.

5. Klik **Deploy**. Saat pertama kali, container `db` otomatis meng-import
   `database/elearning_sma.sql` (skema + akun demo).

6. Cek health: `https://<domain>/api/health` → `{"ok":true}`.

---

## Alternatif: Managed Database Coolify

Jika ingin memakai database MySQL yang dikelola Coolify (bukan service `db`):

1. Buat resource **Database → MySQL** di Coolify.
2. Deploy hanya `app` (pakai build pack **Dockerfile**, bukan compose).
3. Isi `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` ke kredensial
   database managed tersebut, dan `HOST=0.0.0.0`, `PORT=4000`.
4. Import skema sekali secara manual ke database tersebut:
   ```bash
   mysql -h <host> -u <user> -p elearning_sma < database/elearning_sma.sql
   ```

> Catatan: `database/elearning_sma.sql` melakukan `CREATE DATABASE elearning_sma`
> dan `USE elearning_sma`. Pertahankan `DB_NAME=elearning_sma`, atau sesuaikan
> SQL bila ingin nama lain.

---

## Persistensi data

Dua volume didefinisikan agar data tidak hilang saat redeploy:

- `db_data` → `/var/lib/mysql` (data MySQL)
- `uploads` → `/app/uploads` (file yang diunggah pengguna)

Import seed `.sql` hanya berjalan **sekali**, yaitu ketika volume `db_data`
masih kosong. Perubahan skema berikutnya ditangani `ensureSchema()` di server.

---

## Catatan keamanan (lakukan sebelum go-live)

- **Ganti `JWT_SECRET`** dengan string acak — jangan pakai nilai default.
- **Ganti semua password DB** dari nilai contoh.
- **Akun demo memakai password plaintext** (`password`, identifier `1000`/`2000`/
  `3000`/`4000`). Login menerima plaintext untuk akun seed ini dan bcrypt untuk
  akun baru. Untuk produksi: ganti/hapus akun demo dan set password lewat fitur
  aplikasi (tersimpan sebagai bcrypt).
- Endpoint `forgot-password` mengembalikan OTP di respons dan belum terhubung ke
  email/SMS — hubungkan ke layanan nyata sebelum dipakai publik.

---

## Uji lokal sebelum push (opsional)

```bash
docker compose up --build
```

Lalu buka `http://localhost:4000`. Hentikan dengan `docker compose down`
(tambah `-v` untuk menghapus volume/data).
