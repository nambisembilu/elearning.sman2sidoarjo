# Deployment ke Coolify (Dockerfile-only)

Deploy memakai **build pack Dockerfile** — tanpa docker-compose. MySQL dipakai
dari **Managed Database** milik Coolify (resource terpisah).

Aplikasi dikemas sebagai **satu container**: Express melayani REST API (`/api`),
file upload (`/uploads`), sekaligus hasil build frontend (SPA React). Karena
frontend & API satu origin, tidak perlu CORS dan `VITE_API_URL` cukup path
relatif `/api`.

Saat startup, server **otomatis meng-import** `database/elearning_sma.sql`
(skema + akun demo). File itu idempoten (`CREATE TABLE IF NOT EXISTS` +
`INSERT IGNORE`), jadi aman dijalankan setiap boot. Jadi Anda **tidak perlu**
import SQL manual.

## File deployment

| File | Fungsi |
|---|---|
| `Dockerfile` | Multi-stage: build Vite → runtime Node produksi + healthcheck |
| `.dockerignore` | Mengecualikan `flutter/`, `node_modules`, `.env`, dsb. |
| `.env.production.example` | Daftar environment variable untuk diisi di Coolify |

---

## Langkah deploy

### 1. Push project ke Git

Pastikan `.env` **tidak** ikut ter-commit (sudah di `.gitignore`).

### 2. Buat Managed Database (MySQL) di Coolify

- **New Resource → Database → MySQL** (disarankan MySQL 8).
- Setelah jalan, catat kredensialnya: **host internal**, port, user, password.
  Coolify menyediakan hostname internal antar-resource — pakai itu sebagai
  `DB_HOST` (bukan `localhost`).
- Pastikan sebuah database bernama `elearning_sma` tersedia (buat lewat UI
  Coolify bila belum ada). User DB harus punya akses penuh ke database tsb.

> Auto-migrate hanya membuat **tabel** di dalam database yang sudah ada; ia tidak
> menjalankan `CREATE DATABASE` (statement itu sengaja dibuang agar cocok dengan
> user managed yang berhak terbatas). Jadi database-nya harus sudah ada dulu.

### 3. Buat aplikasi

- **New Resource → Application → Dockerfile** (atau pilih repo, lalu set
  **Build Pack = Dockerfile**).
- Arahkan ke repo & branch Anda. Dockerfile terdeteksi otomatis di root.

### 4. Isi Environment Variables

Di tab **Environment Variables** aplikasi (lihat `.env.production.example`):

```
DB_HOST=<host internal MySQL dari Coolify>
DB_PORT=3306
DB_USER=elearning
DB_PASSWORD=<password DB>
DB_NAME=elearning_sma
JWT_SECRET=<hasil `openssl rand -hex 32`>
```

`NODE_ENV`, `HOST=0.0.0.0`, `PORT=4000`, dan `AUTO_MIGRATE=true` sudah menjadi
default di Dockerfile — override hanya bila perlu.

### 5. Set domain & port

- **Port yang di-expose = `4000`**.
- Set **Domain** aplikasi (mis. `https://elearning.sman2sidoarjo.sch.id`).
  Coolify mengurus HTTPS/Let's Encrypt otomatis.

### 6. Persistent storage untuk upload

File yang diunggah pengguna disimpan di `/app/uploads` dalam container. Tanpa
volume, file hilang setiap redeploy. Di Coolify → tab **Storages** aplikasi,
tambahkan **Persistent Storage**:

- Mount path: `/app/uploads`

### 7. Deploy & verifikasi

- Klik **Deploy**.
- Cek health: `https://<domain>/api/health` → `{"ok":true}`.
- Login dengan akun demo (identifier `1000`, password `password`) untuk
  memastikan koneksi DB & auto-migrate berhasil.

---

## Catatan keamanan (lakukan sebelum go-live)

- **Ganti `JWT_SECRET`** dengan string acak — jangan pakai nilai default.
- **Ganti password DB** dari nilai contoh.
- **Akun demo memakai password plaintext** (`password`, identifier `1000`/`2000`/
  `3000`/`4000`). Login menerima plaintext untuk akun seed ini dan bcrypt untuk
  akun baru. Untuk produksi: ganti/hapus akun demo dan set password lewat fitur
  aplikasi (tersimpan sebagai bcrypt).
- Endpoint `forgot-password` mengembalikan OTP di respons dan belum terhubung ke
  email/SMS — hubungkan ke layanan nyata sebelum dipakai publik.
- Setelah seed pertama sukses, Anda boleh set `AUTO_MIGRATE=false` agar server
  tidak menjalankan ulang skrip seed di tiap boot.

---

## Uji lokal sebelum push (opsional, butuh Docker)

```bash
docker build -t elearning-sma .
docker run --rm -p 4000:4000 \
  -e DB_HOST=host.docker.internal \
  -e DB_USER=elearning -e DB_PASSWORD=... -e DB_NAME=elearning_sma \
  -e JWT_SECRET=uji-lokal \
  elearning-sma
```

Lalu buka `http://localhost:4000` (perlu MySQL yang bisa dijangkau dari
container, mis. MySQL lokal via `host.docker.internal`).
