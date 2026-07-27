import "dotenv/config";
import bcrypt from "bcryptjs";
import cors from "cors";
import express from "express";
import fs from "node:fs";
import jwt from "jsonwebtoken";
import multer from "multer";
import mysql from "mysql2/promise";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, "..");
const uploadDir = path.join(rootDir, "uploads");

fs.mkdirSync(uploadDir, { recursive: true });

const app = express();
const port = Number(process.env.PORT || 4000);
const jwtSecret = process.env.JWT_SECRET || "elearning-sma-local-secret";

const pool = mysql.createPool({
  host: process.env.DB_HOST || "127.0.0.1",
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "elearning_sma",
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: false,
  dateStrings: true,
});

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const safeName = file.originalname.replace(/[^\w.-]+/g, "-");
    cb(null, `${Date.now()}-${safeName}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 25 * 1024 * 1024, files: 10 },
});

const configuredOrigins = (process.env.CLIENT_ORIGIN || "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);
const allowedOrigins = new Set([
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  ...configuredOrigins,
]);

function isLocalDevOrigin(origin) {
  try {
    const url = new URL(origin);
    return (
      process.env.NODE_ENV !== "production" &&
      ["http:", "https:"].includes(url.protocol) &&
      ["localhost", "127.0.0.1", "::1"].includes(url.hostname)
    );
  } catch {
    return false;
  }
}

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || allowedOrigins.has(origin) || isLocalDevOrigin(origin)) {
        callback(null, true);
        return;
      }
      callback(new Error(`Origin tidak diizinkan CORS: ${origin}`));
    },
    credentials: true,
  })
);
app.use(express.json({ limit: "10mb" }));
app.use("/uploads", express.static(uploadDir));

// Sajikan hasil build frontend (SPA) dari container yang sama saat produksi.
const distDir = path.join(rootDir, "dist");
const serveClient = process.env.SERVE_CLIENT !== "false" && fs.existsSync(distDir);
if (serveClient) {
  app.use(express.static(distDir));
}

const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

function publicUser(row) {
  if (!row) return null;
  const { password_hash, reset_otp, reset_otp_expires_at, deleted_at, ...rest } =
    row;
  return {
    ...rest,
    id: Number(row.id),
    noTelp: row.no_telp,
    jenisKelamin: row.jenis_kelamin,
  };
}

function numberOrNull(value) {
  if (value === undefined || value === null || value === "") return null;
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
}

function normalizePage(req) {
  return {
    page: Math.max(Number(req.query.page || 1), 1),
    limit: Math.min(Math.max(Number(req.query.limit || 10), 1), 100),
    search: String(req.query.search || "").trim(),
  };
}

function parseJson(value, fallback = []) {
  if (value === null || value === undefined) return fallback;
  if (Array.isArray(value) || typeof value === "object") return value;
  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}

function splitIds(value) {
  if (Array.isArray(value)) return value.map(Number).filter(Boolean);
  if (typeof value === "string") {
    try {
      const parsed = JSON.parse(value);
      if (Array.isArray(parsed)) return parsed.map(Number).filter(Boolean);
    } catch {
      return value
        .split(",")
        .map((item) => Number(item.trim()))
        .filter(Boolean);
    }
  }
  return [];
}

function filesFromRequest(files = []) {
  return files.map((file) => ({
    fileName: file.originalname,
    fileUrl: `/uploads/${file.filename}`,
  }));
}

async function q(sql, params = []) {
  const [rows] = await pool.query(sql, sanitizeParams(params));
  return rows;
}

async function one(sql, params = []) {
  const rows = await q(sql, params);
  return rows[0] || null;
}

async function tx(work) {
  const connection = await pool.getConnection();
  const db = {
    execute(sql, params = []) {
      return connection.query(sql, sanitizeParams(params));
    },
    query(sql, params = []) {
      return connection.query(sql, sanitizeParams(params));
    },
  };
  try {
    await connection.beginTransaction();
    const result = await work(db);
    await connection.commit();
    return result;
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

function sanitizeParams(params = []) {
  return params.map((param) => {
    if (param === undefined) return null;
    if (param instanceof Date) return param;
    if (Array.isArray(param) || (param && typeof param === "object")) {
      return JSON.stringify(param);
    }
    return param;
  });
}

async function logActivity(userId, aksi, entitas, entitasId, detail = "") {
  try {
    await q(
      "INSERT INTO activity_logs (user_id, aksi, entitas, entitas_id, detail) VALUES (?, ?, ?, ?, ?)",
      [userId || null, aksi, entitas, entitasId || null, detail]
    );
  } catch (error) {
    console.error("Failed to write activity log", error.message);
  }
}

function signToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role, nama: user.nama },
    jwtSecret,
    { expiresIn: "7d" }
  );
}

async function auth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;
  if (!token) return res.status(401).json({ message: "Token tidak ditemukan" });
  try {
    const decoded = jwt.verify(token, jwtSecret);
    const user = await one(
      "SELECT * FROM users WHERE id = ? AND deleted_at IS NULL",
      [decoded.id]
    );
    if (!user) return res.status(401).json({ message: "User tidak valid" });
    req.user = user;
    next();
  } catch {
    return res.status(401).json({ message: "Token tidak valid" });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: "Akses role tidak diizinkan" });
    }
    next();
  };
}

async function paged(req, baseSql, countSql, params = []) {
  const { page, limit } = normalizePage(req);
  const offset = (page - 1) * limit;
  const totalRow = await one(countSql, params);
  const rows = await q(`${baseSql} LIMIT ? OFFSET ?`, [...params, limit, offset]);
  const total = Number(totalRow?.total || 0);
  return {
    page,
    total,
    totalPage: Math.ceil(total / limit),
    data: rows,
  };
}

async function activeAcademicYearId() {
  const active = await one("SELECT id FROM academic_years WHERE is_active = 1");
  return active?.id || null;
}

app.get("/api/health", asyncHandler(async (_req, res) => {
  await q("SELECT 1 AS ok");
  res.json({ ok: true, service: "elearning-sma-api" });
}));

app.post("/api/auth/login", asyncHandler(async (req, res) => {
  const { identifier, password } = req.body;
  const user = await one(
    "SELECT * FROM users WHERE identifier = ? AND deleted_at IS NULL",
    [identifier]
  );
  if (!user) return res.status(401).json({ message: "Akun tidak ditemukan" });

  const hash = user.password_hash || "";
  const valid = hash.startsWith("$2")
    ? await bcrypt.compare(password, hash)
    : password === hash;

  if (!valid) return res.status(401).json({ message: "Password salah" });

  await logActivity(user.id, "Login", "auth", user.id, `${user.nama} masuk`);
  res.json({ token: signToken(user), user: publicUser(user) });
}));

app.post("/api/auth/forgot-password", asyncHandler(async (req, res) => {
  const { identifier } = req.body;
  const user = await one(
    "SELECT id, email FROM users WHERE identifier = ? OR email = ?",
    [identifier, identifier]
  );
  if (!user) return res.status(404).json({ message: "Akun tidak ditemukan" });
  const otp = String(Math.floor(100000 + Math.random() * 900000));
  await q(
    "UPDATE users SET reset_otp = ?, reset_otp_expires_at = DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE id = ?",
    [otp, user.id]
  );
  res.json({
    message: "OTP dibuat. Hubungkan endpoint ini ke layanan email/SMS produksi.",
    otp,
  });
}));

app.post("/api/auth/verify-otp", asyncHandler(async (req, res) => {
  const { identifier, otp } = req.body;
  const user = await one(
    "SELECT id FROM users WHERE (identifier = ? OR email = ?) AND reset_otp = ? AND reset_otp_expires_at > NOW()",
    [identifier, identifier, otp]
  );
  if (!user) return res.status(400).json({ message: "OTP tidak valid" });
  res.json({ ok: true });
}));

app.post("/api/auth/reset-password", asyncHandler(async (req, res) => {
  const { identifier, otp, password } = req.body;
  const user = await one(
    "SELECT id FROM users WHERE (identifier = ? OR email = ?) AND reset_otp = ? AND reset_otp_expires_at > NOW()",
    [identifier, identifier, otp]
  );
  if (!user) return res.status(400).json({ message: "OTP tidak valid" });
  const hash = await bcrypt.hash(password, 10);
  await q(
    "UPDATE users SET password_hash = ?, reset_otp = NULL, reset_otp_expires_at = NULL WHERE id = ?",
    [hash, user.id]
  );
  res.json({ ok: true });
}));

app.get("/api/me", auth, asyncHandler(async (req, res) => {
  res.json({ user: publicUser(req.user) });
}));

// ── User Management (staff / admin) ──────────────────────────────────────────

// Helper: roles yang boleh dikelola berdasarkan role peminta
function allowedTargetRoles(requesterRole) {
  if (requesterRole === "admin") return ["admin", "staff", "guru", "siswa"];
  return ["guru", "siswa"]; // staff hanya kelola guru & siswa
}

app.get("/api/users", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const requestedRole = req.query.role || "";
  const status = req.query.status || "active";
  const allowed = allowedTargetRoles(req.user.role);

  const params = [];
  // Batasi ke role yang boleh diakses
  const roleList = (requestedRole && allowed.includes(requestedRole))
    ? [requestedRole]
    : allowed;
  const rolePlaceholders = roleList.map(() => "?").join(",");
  const filters = [`u.role IN (${rolePlaceholders})`];
  params.push(...roleList);

  if (status === "inactive") {
    filters.push("u.deleted_at IS NOT NULL");
  } else {
    filters.push("u.deleted_at IS NULL");
  }
  if (search) {
    filters.push("(u.nama LIKE ? OR u.identifier LIKE ? OR u.email LIKE ?)");
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }

  const where = filters.join(" AND ");
  const result = await paged(
    req,
    `SELECT u.id, u.identifier, u.nama, u.email, u.role,
            u.no_telp AS noTelp, u.created_at AS createdAt,
            CASE WHEN u.deleted_at IS NULL THEN 1 ELSE 0 END AS isActive
     FROM users u
     WHERE ${where}
     ORDER BY FIELD(u.role,'admin','staff','guru','siswa'), u.nama`,
    `SELECT COUNT(*) AS total FROM users u WHERE ${where}`,
    params
  );
  res.json(result);
}));

app.put("/api/users/:id/password", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { newPassword } = req.body;
  if (!newPassword || newPassword.length < 6) {
    return res.status(400).json({ message: "Password minimal 6 karakter" });
  }
  const allowed = allowedTargetRoles(req.user.role);
  const rolePlaceholders = allowed.map(() => "?").join(",");
  const user = await one(
    `SELECT id, role FROM users WHERE id = ? AND role IN (${rolePlaceholders})`,
    [req.params.id, ...allowed]
  );
  if (!user) return res.status(404).json({ message: "User tidak ditemukan atau tidak punya akses" });
  const hash = await bcrypt.hash(newPassword, 10);
  await q("UPDATE users SET password_hash = ? WHERE id = ?", [hash, req.params.id]);
  await logActivity(req.user.id, "Reset password", "users", req.params.id, `Reset password user id ${req.params.id}`);
  res.json({ ok: true });
}));

app.put("/api/users/:id/identifier", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { identifier } = req.body;
  if (!identifier || !identifier.trim()) {
    return res.status(400).json({ message: "Identifier tidak boleh kosong" });
  }
  const allowed = allowedTargetRoles(req.user.role);
  const rolePlaceholders = allowed.map(() => "?").join(",");
  const user = await one(
    `SELECT id, role FROM users WHERE id = ? AND role IN (${rolePlaceholders})`,
    [req.params.id, ...allowed]
  );
  if (!user) return res.status(404).json({ message: "User tidak ditemukan atau tidak punya akses" });
  const existing = await one("SELECT id FROM users WHERE identifier = ? AND id != ?", [identifier.trim(), req.params.id]);
  if (existing) return res.status(409).json({ message: "Identifier sudah digunakan oleh user lain" });
  await q("UPDATE users SET identifier = ? WHERE id = ?", [identifier.trim(), req.params.id]);
  await logActivity(req.user.id, "Ubah identifier", "users", req.params.id, identifier.trim());
  res.json({ ok: true });
}));

app.put("/api/users/:id/status", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  if (Number(req.params.id) === req.user.id) {
    return res.status(400).json({ message: "Tidak dapat mengubah status akun sendiri" });
  }
  const allowed = allowedTargetRoles(req.user.role);
  const rolePlaceholders = allowed.map(() => "?").join(",");
  const user = await one(
    `SELECT id, nama, role, deleted_at FROM users WHERE id = ? AND role IN (${rolePlaceholders})`,
    [req.params.id, ...allowed]
  );
  if (!user) return res.status(404).json({ message: "User tidak ditemukan atau tidak punya akses" });
  const willActivate = !!user.deleted_at;
  await q("UPDATE users SET deleted_at = ? WHERE id = ?", [willActivate ? null : new Date(), req.params.id]);
  await logActivity(req.user.id, willActivate ? "Aktifkan user" : "Nonaktifkan user", "users", req.params.id, user.nama);
  res.json({ ok: true, isActive: willActivate });
}));

// ─────────────────────────────────────────────────────────────────────────────

app.get("/api/options", auth, asyncHandler(async (req, res) => {
  const [
    academicYears,
    semesters,
    classes,
    subjects,
    teachers,
    students,
    classSubjects,
    waliCandidates,
  ] = await Promise.all([
    q("SELECT id, tahun_ajaran AS tahunAjaran, is_active AS isActive FROM academic_years ORDER BY tahun_ajaran DESC"),
    q("SELECT s.id, s.academic_year_id AS academicYearId, s.judul_semester AS judulSemester, s.is_active AS isActive FROM semesters s ORDER BY s.academic_year_id DESC, s.id"),
    q("SELECT id, nama_kelas AS namaKelas, jenjang, jurusan, ruang_kelas AS ruangKelas FROM classes WHERE deleted_at IS NULL ORDER BY nama_kelas"),
    q("SELECT id, judul_mapel AS judulMapel, jenjang, jurusan FROM subjects WHERE deleted_at IS NULL ORDER BY judul_mapel"),
    q("SELECT u.id, u.nama, gp.nip_nuptk AS nipNuptk FROM users u JOIN guru_profiles gp ON gp.user_id = u.id WHERE u.role = 'guru' AND u.deleted_at IS NULL ORDER BY u.nama"),
    q("SELECT u.id, u.nama, sp.nis, sp.nisn, sp.kelas_id AS kelasId FROM users u JOIN siswa_profiles sp ON sp.user_id = u.id WHERE u.role = 'siswa' AND u.deleted_at IS NULL ORDER BY u.nama"),
    req.user.role === "guru"
      ? q(`SELECT cs.id, c.nama_kelas AS namaKelas, s.judul_mapel AS judulMapel, u.nama AS guruPengampu, s.id AS subjectId
           FROM class_subjects cs
           JOIN classes c ON c.id = cs.class_id
           JOIN subjects s ON s.id = cs.subject_id
           JOIN users u ON u.id = cs.guru_user_id
           WHERE cs.guru_user_id = ?
           ORDER BY c.nama_kelas, s.judul_mapel`, [req.user.id])
      : q(`SELECT cs.id, c.nama_kelas AS namaKelas, s.judul_mapel AS judulMapel, u.nama AS guruPengampu, s.id AS subjectId
           FROM class_subjects cs
           JOIN classes c ON c.id = cs.class_id
           JOIN subjects s ON s.id = cs.subject_id
           JOIN users u ON u.id = cs.guru_user_id
           ORDER BY c.nama_kelas, s.judul_mapel`),
    q("SELECT u.id, u.nama FROM users u WHERE u.role IN ('guru', 'staff') AND u.deleted_at IS NULL ORDER BY u.nama"),
  ]);

  res.json({
    academicYears,
    semesters,
    classes,
    subjects,
    teachers,
    students,
    classSubjects,
    waliCandidates,
  });
}));

app.get("/api/overview", auth, asyncHandler(async (req, res) => {
  const classFilter =
    req.user.role === "guru"
      ? "WHERE guru_user_id = ?"
      : req.user.role === "siswa"
        ? `WHERE class_id = (SELECT kelas_id FROM siswa_profiles WHERE user_id = ?)`
        : "";
  const classParams =
    req.user.role === "guru" || req.user.role === "siswa" ? [req.user.id] : [];

  const [counts, recentLogs, events, upcomingAssignments, exams] =
    await Promise.all([
      Promise.all([
        one("SELECT COUNT(*) AS total FROM users WHERE role = 'guru' AND deleted_at IS NULL"),
        one("SELECT COUNT(*) AS total FROM users WHERE role = 'siswa' AND deleted_at IS NULL"),
        one(`SELECT COUNT(*) AS total FROM class_subjects ${classFilter}`, classParams),
        one("SELECT COUNT(*) AS total FROM assignments WHERE deleted_at IS NULL"),
      ]),
      q(`SELECT l.id, l.aksi, l.entitas, l.detail, l.created_at AS createdAt, u.nama
         FROM activity_logs l LEFT JOIN users u ON u.id = l.user_id
         ORDER BY l.created_at DESC LIMIT 8`),
      q(`SELECT e.id, e.nama_kegiatan AS namaKegiatan, e.tanggal_mulai AS tanggalMulai, e.tanggal_selesai AS tanggalSelesai
         FROM academic_events e WHERE e.deleted_at IS NULL ORDER BY e.tanggal_mulai DESC LIMIT 6`),
      q(`SELECT a.id, a.judul, a.deadline, c.nama_kelas AS namaKelas, s.judul_mapel AS judulMapel
         FROM assignments a
         JOIN class_subjects cs ON cs.id = a.class_subject_id
         JOIN classes c ON c.id = cs.class_id
         JOIN subjects s ON s.id = cs.subject_id
         WHERE a.deleted_at IS NULL ORDER BY a.deadline ASC LIMIT 6`),
      q(`SELECT e.id, e.judul, e.tipe_ujian AS tipeUjian, e.tanggal_ujian AS tanggalUjian
         FROM exams e WHERE e.deleted_at IS NULL ORDER BY e.tanggal_ujian ASC LIMIT 6`),
    ]);

  res.json({
    counts: {
      guru: Number(counts[0]?.total || 0),
      siswa: Number(counts[1]?.total || 0),
      kelasMapel: Number(counts[2]?.total || 0),
      tugas: Number(counts[3]?.total || 0),
    },
    recentLogs,
    events,
    upcomingAssignments,
    exams,
  });
}));

app.get("/api/teachers", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  let where = "u.role = 'guru' AND u.deleted_at IS NULL";
  if (search) {
    where += " AND (u.nama LIKE ? OR gp.nip_nuptk LIKE ? OR u.email LIKE ?)";
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  const result = await paged(
    req,
    `SELECT u.id, u.nama, u.email, u.no_telp AS noTelp, u.alamat, gp.nip_nuptk AS nipNuptk,
            GROUP_CONCAT(s.id) AS subjectIds, GROUP_CONCAT(s.judul_mapel SEPARATOR ', ') AS mapel
     FROM users u
     JOIN guru_profiles gp ON gp.user_id = u.id
     LEFT JOIN guru_subjects gs ON gs.guru_user_id = u.id
     LEFT JOIN subjects s ON s.id = gs.subject_id
     WHERE ${where}
     GROUP BY u.id
     ORDER BY u.nama`,
    `SELECT COUNT(*) AS total FROM users u JOIN guru_profiles gp ON gp.user_id = u.id WHERE ${where}`,
    params
  );
  result.data = result.data.map((row) => ({
    ...row,
    subjectIds: row.subjectIds ? row.subjectIds.split(",").map(Number) : [],
  }));
  res.json(result);
}));

app.post("/api/teachers", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { nama, nipNuptk, email, noTelp, alamat, subjectIds = [] } = req.body;
  const passwordHash = await bcrypt.hash(req.body.password || "password", 10);
  const id = await tx(async (connection) => {
    const [userResult] = await connection.execute(
      "INSERT INTO users (identifier, password_hash, nama, email, no_telp, alamat, role) VALUES (?, ?, ?, ?, ?, ?, 'guru')",
      [nipNuptk, passwordHash, nama, email, noTelp, alamat]
    );
    const userId = userResult.insertId;
    await connection.execute(
      "INSERT INTO guru_profiles (user_id, nip_nuptk) VALUES (?, ?)",
      [userId, nipNuptk]
    );
    for (const subjectId of splitIds(subjectIds)) {
      await connection.execute(
        "INSERT IGNORE INTO guru_subjects (guru_user_id, subject_id) VALUES (?, ?)",
        [userId, subjectId]
      );
    }
    return userId;
  });
  await logActivity(req.user.id, "Tambah guru", "users", id, nama);
  res.status(201).json({ id });
}));

app.put("/api/teachers/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { nama, nipNuptk, email, noTelp, alamat, subjectIds = [] } = req.body;
  await tx(async (connection) => {
    await connection.execute(
      "UPDATE users SET identifier = ?, nama = ?, email = ?, no_telp = ?, alamat = ? WHERE id = ?",
      [nipNuptk, nama, email, noTelp, alamat, req.params.id]
    );
    await connection.execute(
      "UPDATE guru_profiles SET nip_nuptk = ? WHERE user_id = ?",
      [nipNuptk, req.params.id]
    );
    await connection.execute("DELETE FROM guru_subjects WHERE guru_user_id = ?", [
      req.params.id,
    ]);
    for (const subjectId of splitIds(subjectIds)) {
      await connection.execute(
        "INSERT IGNORE INTO guru_subjects (guru_user_id, subject_id) VALUES (?, ?)",
        [req.params.id, subjectId]
      );
    }
  });
  await logActivity(req.user.id, "Ubah guru", "users", req.params.id, nama);
  res.json({ ok: true });
}));

app.delete("/api/teachers/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE users SET deleted_at = NOW() WHERE id = ? AND role = 'guru'", [
    req.params.id,
  ]);
  await logActivity(req.user.id, "Hapus guru", "users", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/students", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  const filters = ["u.role = 'siswa'", "u.deleted_at IS NULL"];
  if (req.query.academicYearId) {
    filters.push("c.academic_year_id = ?");
    params.push(req.query.academicYearId);
  }
  if (req.query.jenjang && req.query.jenjang !== "Semua Jenjang") {
    filters.push("c.jenjang = ?");
    params.push(req.query.jenjang);
  }
  if (req.query.jurusan && req.query.jurusan !== "Semua Jurusan") {
    filters.push("c.jurusan = ?");
    params.push(req.query.jurusan);
  }
  if (search) {
    filters.push("(u.nama LIKE ? OR sp.nis LIKE ? OR sp.nisn LIKE ? OR u.email LIKE ?)");
    params.push(`%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`);
  }
  const where = filters.join(" AND ");
  const result = await paged(
    req,
    `SELECT u.id, u.nama, u.email, u.no_telp AS noTelp, u.alamat, u.jenis_kelamin AS jenisKelamin,
            u.agama, sp.nis, sp.nisn, sp.kelas_id AS kelasId, c.nama_kelas AS namaKelas,
            sp.nama_wali_murid AS namaWaliMurid, sp.alamat_wali_murid AS alamatWaliMurid,
            sp.no_telp_wali_murid AS noTelpWaliMurid, sp.status_wali_murid AS statusWaliMurid
     FROM users u
     JOIN siswa_profiles sp ON sp.user_id = u.id
     LEFT JOIN classes c ON c.id = sp.kelas_id
     WHERE ${where}
     ORDER BY u.nama`,
    `SELECT COUNT(*) AS total
     FROM users u
     JOIN siswa_profiles sp ON sp.user_id = u.id
     LEFT JOIN classes c ON c.id = sp.kelas_id
     WHERE ${where}`,
    params
  );
  res.json(result);
}));

app.post("/api/students", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const {
    nis,
    nisn,
    nama,
    jenisKelamin,
    agama,
    email,
    noTelp,
    alamat,
    kelasId,
    namaWaliMurid,
    alamatWaliMurid,
    noTelpWaliMurid,
    statusWaliMurid,
  } = req.body;
  const passwordHash = await bcrypt.hash(req.body.password || "password", 10);
  const id = await tx(async (connection) => {
    const [userResult] = await connection.execute(
      `INSERT INTO users (identifier, password_hash, nama, email, no_telp, alamat, role, jenis_kelamin, agama)
       VALUES (?, ?, ?, ?, ?, ?, 'siswa', ?, ?)`,
      [nisn, passwordHash, nama, email, noTelp, alamat, jenisKelamin, agama]
    );
    const userId = userResult.insertId;
    await connection.execute(
      `INSERT INTO siswa_profiles
       (user_id, nis, nisn, kelas_id, nama_wali_murid, alamat_wali_murid, no_telp_wali_murid, status_wali_murid)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        nis,
        nisn,
        numberOrNull(kelasId),
        namaWaliMurid,
        alamatWaliMurid,
        noTelpWaliMurid,
        statusWaliMurid,
      ]
    );
    return userId;
  });
  await logActivity(req.user.id, "Tambah siswa", "users", id, nama);
  res.status(201).json({ id });
}));

app.post("/api/students/bulk", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const rows = Array.isArray(req.body.rows) ? req.body.rows : [];
  let inserted = 0;
  for (const row of rows) {
    if (!row.nisn || !row.nis || !row.nama || !row.email) continue;
    const exists = await one("SELECT id FROM users WHERE identifier = ?", [
      row.nisn,
    ]);
    if (exists) continue;
    const kelas = row.kelasId
      ? { id: row.kelasId }
      : await one("SELECT id FROM classes WHERE nama_kelas = ?", [
          row.namaKelas || "",
        ]);
    const passwordHash = await bcrypt.hash("password", 10);
    await tx(async (connection) => {
      const [userResult] = await connection.execute(
        `INSERT INTO users (identifier, password_hash, nama, email, no_telp, alamat, role, jenis_kelamin, agama)
         VALUES (?, ?, ?, ?, ?, ?, 'siswa', ?, ?)`,
        [
          row.nisn,
          passwordHash,
          row.nama,
          row.email,
          row.noTelp || "",
          row.alamat || "",
          row.jenisKelamin || "",
          row.agama || "",
        ]
      );
      await connection.execute(
        "INSERT INTO siswa_profiles (user_id, nis, nisn, kelas_id) VALUES (?, ?, ?, ?)",
        [userResult.insertId, row.nis, row.nisn, kelas?.id || null]
      );
    });
    inserted += 1;
  }
  await logActivity(req.user.id, "Import siswa", "users", null, `${inserted} data`);
  res.json({ inserted });
}));

app.put("/api/students/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const {
    nis,
    nisn,
    nama,
    jenisKelamin,
    agama,
    email,
    noTelp,
    alamat,
    kelasId,
    namaWaliMurid,
    alamatWaliMurid,
    noTelpWaliMurid,
    statusWaliMurid,
  } = req.body;
  await tx(async (connection) => {
    await connection.execute(
      `UPDATE users SET identifier = ?, nama = ?, email = ?, no_telp = ?, alamat = ?,
       jenis_kelamin = ?, agama = ? WHERE id = ?`,
      [nisn, nama, email, noTelp, alamat, jenisKelamin, agama, req.params.id]
    );
    await connection.execute(
      `UPDATE siswa_profiles SET nis = ?, nisn = ?, kelas_id = ?, nama_wali_murid = ?,
       alamat_wali_murid = ?, no_telp_wali_murid = ?, status_wali_murid = ? WHERE user_id = ?`,
      [
        nis,
        nisn,
        numberOrNull(kelasId),
        namaWaliMurid,
        alamatWaliMurid,
        noTelpWaliMurid,
        statusWaliMurid,
        req.params.id,
      ]
    );
  });
  await logActivity(req.user.id, "Ubah siswa", "users", req.params.id, nama);
  res.json({ ok: true });
}));

app.delete("/api/students/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE users SET deleted_at = NOW() WHERE id = ? AND role = 'siswa'", [
    req.params.id,
  ]);
  await logActivity(req.user.id, "Hapus siswa", "users", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/classes", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  const filters = ["c.deleted_at IS NULL"];
  if (req.query.academicYearId) {
    filters.push("c.academic_year_id = ?");
    params.push(req.query.academicYearId);
  }
  if (req.query.jenjang && req.query.jenjang !== "Semua Jenjang") {
    filters.push("c.jenjang = ?");
    params.push(req.query.jenjang);
  }
  if (req.query.jurusan && req.query.jurusan !== "Semua Jurusan") {
    filters.push("c.jurusan = ?");
    params.push(req.query.jurusan);
  }
  if (search) {
    filters.push("(c.nama_kelas LIKE ? OR c.ruang_kelas LIKE ? OR u.nama LIKE ?)");
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }
  const where = filters.join(" AND ");
  const result = await paged(
    req,
    `SELECT c.id, c.academic_year_id AS academicYearId, ay.tahun_ajaran AS tahunAjaran,
            c.jenjang, c.jurusan, c.nama_kelas AS namaKelas, c.ruang_kelas AS ruangKelas,
            c.wali_kelas_user_id AS waliKelasUserId, u.nama AS waliKelas,
            COUNT(sp.user_id) AS jumlahSiswa
     FROM classes c
     JOIN academic_years ay ON ay.id = c.academic_year_id
     LEFT JOIN users u ON u.id = c.wali_kelas_user_id
     LEFT JOIN siswa_profiles sp ON sp.kelas_id = c.id
     WHERE ${where}
     GROUP BY c.id
     ORDER BY c.nama_kelas`,
    `SELECT COUNT(*) AS total FROM classes c LEFT JOIN users u ON u.id = c.wali_kelas_user_id WHERE ${where}`,
    params
  );
  res.json(result);
}));

app.post("/api/classes", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const academicYearId = req.body.academicYearId || (await activeAcademicYearId());
  const { jenjang, jurusan, namaKelas, ruangKelas, waliKelasUserId } = req.body;
  const result = await q(
    `INSERT INTO classes (academic_year_id, jenjang, jurusan, nama_kelas, ruang_kelas, wali_kelas_user_id)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [
      academicYearId,
      jenjang,
      jurusan,
      namaKelas || `${jenjang} ${jurusan}`,
      ruangKelas,
      numberOrNull(waliKelasUserId),
    ]
  );
  const id = result.insertId;
  await logActivity(req.user.id, "Tambah kelas", "classes", id, namaKelas);
  res.status(201).json({ id });
}));

app.put("/api/classes/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { academicYearId, jenjang, jurusan, namaKelas, ruangKelas, waliKelasUserId } =
    req.body;
  await q(
    `UPDATE classes SET academic_year_id = ?, jenjang = ?, jurusan = ?, nama_kelas = ?,
     ruang_kelas = ?, wali_kelas_user_id = ? WHERE id = ?`,
    [
      academicYearId,
      jenjang,
      jurusan,
      namaKelas,
      ruangKelas,
      numberOrNull(waliKelasUserId),
      req.params.id,
    ]
  );
  await logActivity(req.user.id, "Ubah kelas", "classes", req.params.id, namaKelas);
  res.json({ ok: true });
}));

app.delete("/api/classes/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE classes SET deleted_at = NOW() WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus kelas", "classes", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/subjects", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  const filters = ["s.deleted_at IS NULL"];
  if (req.query.jenjang && req.query.jenjang !== "Semua Jenjang") {
    filters.push("s.jenjang = ?");
    params.push(req.query.jenjang);
  }
  if (req.query.jurusan && req.query.jurusan !== "Semua Jurusan") {
    filters.push("s.jurusan = ?");
    params.push(req.query.jurusan);
  }
  if (search) {
    filters.push("(s.judul_mapel LIKE ? OR u.nama LIKE ?)");
    params.push(`%${search}%`, `%${search}%`);
  }
  const where = filters.join(" AND ");
  const result = await paged(
    req,
    `SELECT s.id, s.judul_mapel AS judulMapel, s.jenjang, s.jurusan,
            s.koordinator_user_id AS koordinatorUserId, u.nama AS koordinator
     FROM subjects s LEFT JOIN users u ON u.id = s.koordinator_user_id
     WHERE ${where}
     ORDER BY s.judul_mapel`,
    `SELECT COUNT(*) AS total FROM subjects s LEFT JOIN users u ON u.id = s.koordinator_user_id WHERE ${where}`,
    params
  );
  res.json(result);
}));

app.post("/api/subjects", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { judulMapel, jenjang, jurusan, koordinatorUserId } = req.body;
  const result = await q(
    "INSERT INTO subjects (judul_mapel, jenjang, jurusan, koordinator_user_id) VALUES (?, ?, ?, ?)",
    [judulMapel, jenjang, jurusan, numberOrNull(koordinatorUserId)]
  );
  await logActivity(req.user.id, "Tambah mata pelajaran", "subjects", result.insertId, judulMapel);
  res.status(201).json({ id: result.insertId });
}));

app.put("/api/subjects/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { judulMapel, jenjang, jurusan, koordinatorUserId } = req.body;
  await q(
    "UPDATE subjects SET judul_mapel = ?, jenjang = ?, jurusan = ?, koordinator_user_id = ? WHERE id = ?",
    [judulMapel, jenjang, jurusan, numberOrNull(koordinatorUserId), req.params.id]
  );
  await logActivity(req.user.id, "Ubah mata pelajaran", "subjects", req.params.id, judulMapel);
  res.json({ ok: true });
}));

app.delete("/api/subjects/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE subjects SET deleted_at = NOW() WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus mata pelajaran", "subjects", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/academic-years", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = search ? [`%${search}%`] : [];
  const where = search ? "WHERE tahun_ajaran LIKE ?" : "";
  const result = await paged(
    req,
    `SELECT ay.id, ay.tahun_ajaran AS tahunAjaran, ay.is_active AS isActive,
            JSON_ARRAYAGG(JSON_OBJECT('id', s.id, 'judulSemester', s.judul_semester, 'tanggalMulai', s.tanggal_mulai, 'isActive', s.is_active)) AS semester
     FROM academic_years ay LEFT JOIN semesters s ON s.academic_year_id = ay.id
     ${where}
     GROUP BY ay.id ORDER BY ay.tahun_ajaran DESC`,
    `SELECT COUNT(*) AS total FROM academic_years ${where}`,
    params
  );
  result.data = result.data.map((row) => ({
    ...row,
    semester: parseJson(row.semester, []).filter((item) => item.id !== null),
  }));
  res.json(result);
}));

app.post("/api/academic-years", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { tahunAjaran, tanggalMulaiSmtGanjil, tanggalMulaiSmtGenap, isActive } =
    req.body;
  const id = await tx(async (connection) => {
    if (Number(isActive)) {
      await connection.execute("UPDATE academic_years SET is_active = 0");
    }
    const [result] = await connection.execute(
      "INSERT INTO academic_years (tahun_ajaran, is_active) VALUES (?, ?)",
      [tahunAjaran, Number(isActive) ? 1 : 0]
    );
    await connection.execute(
      "INSERT INTO semesters (academic_year_id, judul_semester, tanggal_mulai, is_active) VALUES (?, 'Ganjil', ?, ?), (?, 'Genap', ?, ?)",
      [
        result.insertId,
        tanggalMulaiSmtGanjil || null,
        0,
        result.insertId,
        tanggalMulaiSmtGenap || null,
        Number(isActive) ? 1 : 0,
      ]
    );
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah tahun ajaran", "academic_years", id, tahunAjaran);
  res.status(201).json({ id });
}));

app.put("/api/academic-years/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { tahunAjaran, isActive } = req.body;
  await tx(async (connection) => {
    if (Number(isActive)) await connection.execute("UPDATE academic_years SET is_active = 0");
    await connection.execute(
      "UPDATE academic_years SET tahun_ajaran = ?, is_active = ? WHERE id = ?",
      [tahunAjaran, Number(isActive) ? 1 : 0, req.params.id]
    );
  });
  await logActivity(req.user.id, "Ubah tahun ajaran", "academic_years", req.params.id, tahunAjaran);
  res.json({ ok: true });
}));

app.delete("/api/academic-years/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("DELETE FROM academic_years WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus tahun ajaran", "academic_years", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/academic-events", auth, asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  const filters = ["e.deleted_at IS NULL"];
  if (req.query.academicYearId) {
    filters.push("e.academic_year_id = ?");
    params.push(req.query.academicYearId);
  }
  if (req.query.month) {
    filters.push("MONTH(e.tanggal_mulai) = ?");
    params.push(req.query.month);
  }
  if (search) {
    filters.push("e.nama_kegiatan LIKE ?");
    params.push(`%${search}%`);
  }
  const where = filters.join(" AND ");
  const result = await paged(
    req,
    `SELECT e.id, e.academic_year_id AS academicYearId, ay.tahun_ajaran AS tahunAjaran,
            e.nama_kegiatan AS namaKegiatan, e.tanggal_mulai AS tanggalMulai, e.tanggal_selesai AS tanggalSelesai
     FROM academic_events e JOIN academic_years ay ON ay.id = e.academic_year_id
     WHERE ${where} ORDER BY e.tanggal_mulai DESC`,
    `SELECT COUNT(*) AS total FROM academic_events e WHERE ${where}`,
    params
  );
  res.json(result);
}));

app.post("/api/academic-events", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const academicYearId = req.body.academicYearId || (await activeAcademicYearId());
  const { namaKegiatan, tanggalMulai, tanggalSelesai } = req.body;
  const result = await q(
    "INSERT INTO academic_events (academic_year_id, nama_kegiatan, tanggal_mulai, tanggal_selesai) VALUES (?, ?, ?, ?)",
    [academicYearId, namaKegiatan, tanggalMulai, tanggalSelesai]
  );
  await logActivity(req.user.id, "Tambah jadwal akademik", "academic_events", result.insertId, namaKegiatan);
  res.status(201).json({ id: result.insertId });
}));

app.put("/api/academic-events/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { academicYearId, namaKegiatan, tanggalMulai, tanggalSelesai } = req.body;
  await q(
    "UPDATE academic_events SET academic_year_id = ?, nama_kegiatan = ?, tanggal_mulai = ?, tanggal_selesai = ? WHERE id = ?",
    [academicYearId, namaKegiatan, tanggalMulai, tanggalSelesai, req.params.id]
  );
  await logActivity(req.user.id, "Ubah jadwal akademik", "academic_events", req.params.id, namaKegiatan);
  res.json({ ok: true });
}));

app.delete("/api/academic-events/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE academic_events SET deleted_at = NOW() WHERE id = ?", [
    req.params.id,
  ]);
  await logActivity(req.user.id, "Hapus jadwal akademik", "academic_events", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/class-subjects", auth, asyncHandler(async (req, res) => {
  const params = [];
  const filters = [];
  if (req.query.academicYearId) {
    filters.push("cs.academic_year_id = ?");
    params.push(req.query.academicYearId);
  }
  if (req.user.role === "guru") {
    filters.push("cs.guru_user_id = ?");
    params.push(req.user.id);
  }
  if (req.user.role === "siswa") {
    filters.push("cs.class_id = (SELECT kelas_id FROM siswa_profiles WHERE user_id = ?)");
    params.push(req.user.id);
  }
  if (req.query.search) {
    filters.push("(c.nama_kelas LIKE ? OR s.judul_mapel LIKE ? OR g.nama LIKE ?)");
    params.push(`%${req.query.search}%`, `%${req.query.search}%`, `%${req.query.search}%`);
  }
  const where = filters.length ? `WHERE ${filters.join(" AND ")}` : "";
  const rows = await q(
    `SELECT cs.id, cs.class_id AS classId, cs.subject_id AS subjectId, cs.guru_user_id AS guruUserId,
            c.nama_kelas AS namaKelas, c.jenjang, c.jurusan, c.ruang_kelas AS ruangKelas,
            s.judul_mapel AS judulMapel, g.nama AS guruPengampu,
            (SELECT COUNT(*) FROM materials m WHERE m.class_subject_id = cs.id AND m.deleted_at IS NULL) AS jumlahMateri,
            (SELECT COUNT(*) FROM assignments a WHERE a.class_subject_id = cs.id AND a.deleted_at IS NULL) AS jumlahTugas,
            (SELECT COUNT(*) FROM exams e WHERE e.class_subject_id = cs.id AND e.deleted_at IS NULL) AS jumlahUjian,
            (SELECT COUNT(*) FROM exams e WHERE e.class_subject_id = cs.id AND e.tipe_ujian = 'Latihan Soal' AND e.deleted_at IS NULL) AS jumlahLatihanSoal
     FROM class_subjects cs
     JOIN classes c ON c.id = cs.class_id
     JOIN subjects s ON s.id = cs.subject_id
     JOIN users g ON g.id = cs.guru_user_id
     ${where}
     ORDER BY c.nama_kelas, s.judul_mapel`,
    params
  );
  res.json({ total: rows.length, data: rows });
}));

app.post("/api/class-subjects", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const academicYearId = req.body.academicYearId || (await activeAcademicYearId());
  const { classId, subjectId, guruUserId } = req.body;
  const result = await q(
    "INSERT INTO class_subjects (class_id, subject_id, guru_user_id, academic_year_id) VALUES (?, ?, ?, ?)",
    [classId, subjectId, guruUserId, academicYearId]
  );
  await q(
    "INSERT IGNORE INTO guru_subjects (guru_user_id, subject_id) VALUES (?, ?)",
    [guruUserId, subjectId]
  );
  await logActivity(req.user.id, "Tambah jadwal pelajaran", "class_subjects", result.insertId);
  res.status(201).json({ id: result.insertId });
}));

app.get("/api/lesson-schedules", auth, asyncHandler(async (req, res) => {
  const params = [];
  const filters = ["ls.deleted_at IS NULL"];
  if (req.query.classId) {
    filters.push("cs.class_id = ?");
    params.push(req.query.classId);
  }
  if (req.user.role === "guru") {
    filters.push("cs.guru_user_id = ?");
    params.push(req.user.id);
  }
  if (req.user.role === "siswa") {
    filters.push("cs.class_id = (SELECT kelas_id FROM siswa_profiles WHERE user_id = ?)");
    params.push(req.user.id);
  }
  const where = filters.join(" AND ");
  const rows = await q(
    `SELECT ls.id, ls.class_subject_id AS classSubjectId, ls.hari, ls.waktu, ls.ruang_kelas AS ruangKelas,
            c.nama_kelas AS namaKelas, s.judul_mapel AS judulMapel, u.nama AS guruPengampu
     FROM lesson_schedules ls
     JOIN class_subjects cs ON cs.id = ls.class_subject_id
     JOIN classes c ON c.id = cs.class_id
     JOIN subjects s ON s.id = cs.subject_id
     JOIN users u ON u.id = cs.guru_user_id
     WHERE ${where}
     ORDER BY FIELD(ls.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), ls.waktu`,
    params
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/lesson-schedules", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { classSubjectId, hari, waktu, ruangKelas } = req.body;
  const result = await q(
    "INSERT INTO lesson_schedules (class_subject_id, hari, waktu, ruang_kelas) VALUES (?, ?, ?, ?)",
    [classSubjectId, hari, waktu, ruangKelas]
  );
  await logActivity(req.user.id, "Tambah jadwal pelajaran", "lesson_schedules", result.insertId);
  res.status(201).json({ id: result.insertId });
}));

app.put("/api/lesson-schedules/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const { classSubjectId, hari, waktu, ruangKelas } = req.body;
  await q(
    "UPDATE lesson_schedules SET class_subject_id = ?, hari = ?, waktu = ?, ruang_kelas = ? WHERE id = ?",
    [classSubjectId, hari, waktu, ruangKelas, req.params.id]
  );
  await logActivity(req.user.id, "Ubah jadwal pelajaran", "lesson_schedules", req.params.id);
  res.json({ ok: true });
}));

app.delete("/api/lesson-schedules/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("UPDATE lesson_schedules SET deleted_at = NOW() WHERE id = ?", [
    req.params.id,
  ]);
  await logActivity(req.user.id, "Hapus jadwal pelajaran", "lesson_schedules", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/class-subjects/:id/students", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT u.id AS userIdSiswa, sp.user_id AS siswaId, sp.nis, sp.nisn, u.nama AS namaSiswa,
            u.no_telp AS noTelpSiswa, u.email AS emailSiswa
     FROM class_subjects cs
     JOIN siswa_profiles sp ON sp.kelas_id = cs.class_id
     JOIN users u ON u.id = sp.user_id
     WHERE cs.id = ? AND u.deleted_at IS NULL
     ORDER BY u.nama`,
    [req.params.id]
  );
  res.json({ data: rows, total: rows.length });
}));

app.get("/api/rubrics", auth, asyncHandler(async (req, res) => {
  let subjectId = req.query.subjectId;
  if (!subjectId && req.query.classSubjectId) {
    const classSubject = await one(
      "SELECT subject_id FROM class_subjects WHERE id = ?",
      [req.query.classSubjectId]
    );
    subjectId = classSubject?.subject_id;
  }
  const params = [];
  const filters = [];
  if (subjectId) {
    filters.push("rs.subject_id = ?");
    params.push(subjectId);
  }
  if (req.query.semesterId) {
    filters.push("rs.semester_id = ?");
    params.push(req.query.semesterId);
  }
  const where = filters.length ? `WHERE ${filters.join(" AND ")}` : "";
  const rows = await q(
    `SELECT rs.id AS lingkupMateriId, rs.lingkup_materi AS lingkupMateri,
            rs.status_kunci AS statusKunci, rs.subject_id AS subjectId, rs.semester_id AS semesterId,
            s.judul_mapel AS judulMapel, COUNT(lo.id) AS jumlahTP
     FROM rubric_scopes rs
     JOIN subjects s ON s.id = rs.subject_id
     LEFT JOIN learning_objectives lo ON lo.rubric_scope_id = rs.id
     ${where}
     GROUP BY rs.id
     ORDER BY rs.created_at DESC`,
    params
  );
  for (const row of rows) {
    row.tujuanPembelajaran = await q(
      `SELECT id, deskripsi, perlu_bimbingan AS perluBimbingan, cukup, baik, sangat_baik AS sangatBaik
       FROM learning_objectives WHERE rubric_scope_id = ? ORDER BY id`,
      [row.lingkupMateriId]
    );
  }
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/rubrics", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const { subjectId, semesterId, lingkupMateri, statusKunci, objectives = [] } =
    req.body;
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      "INSERT INTO rubric_scopes (subject_id, semester_id, lingkup_materi, status_kunci) VALUES (?, ?, ?, ?)",
      [subjectId, semesterId, lingkupMateri, Number(statusKunci) ? 1 : 0]
    );
    for (const objective of objectives) {
      await connection.execute(
        `INSERT INTO learning_objectives
         (rubric_scope_id, deskripsi, perlu_bimbingan, cukup, baik, sangat_baik)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          result.insertId,
          objective.deskripsi,
          objective.perluBimbingan || "",
          objective.cukup || "",
          objective.baik || "",
          objective.sangatBaik || "",
        ]
      );
    }
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah rubrik", "rubric_scopes", id, lingkupMateri);
  res.status(201).json({ id });
}));

app.put("/api/rubrics/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const { subjectId, semesterId, lingkupMateri, statusKunci, objectives = [] } =
    req.body;
  await tx(async (connection) => {
    await connection.execute(
      "UPDATE rubric_scopes SET subject_id = ?, semester_id = ?, lingkup_materi = ?, status_kunci = ? WHERE id = ?",
      [subjectId, semesterId, lingkupMateri, Number(statusKunci) ? 1 : 0, req.params.id]
    );
    await connection.execute("DELETE FROM learning_objectives WHERE rubric_scope_id = ?", [
      req.params.id,
    ]);
    for (const objective of objectives) {
      await connection.execute(
        `INSERT INTO learning_objectives
         (rubric_scope_id, deskripsi, perlu_bimbingan, cukup, baik, sangat_baik)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          req.params.id,
          objective.deskripsi,
          objective.perluBimbingan || "",
          objective.cukup || "",
          objective.baik || "",
          objective.sangatBaik || "",
        ]
      );
    }
  });
  await logActivity(req.user.id, "Ubah rubrik", "rubric_scopes", req.params.id, lingkupMateri);
  res.json({ ok: true });
}));

app.delete("/api/rubrics/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("DELETE FROM rubric_scopes WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus rubrik", "rubric_scopes", req.params.id);
  res.json({ ok: true });
}));

async function materialRows(classSubjectId, userRole, search = "") {
  const params = [classSubjectId];
  const filters = ["m.class_subject_id = ?", "m.deleted_at IS NULL"];
  if (userRole === "siswa") filters.push("m.status = 'Visible'");
  if (search) {
    filters.push("(m.judul LIKE ? OR m.deskripsi LIKE ?)");
    params.push(`%${search}%`, `%${search}%`);
  }
  const rows = await q(
    `SELECT m.id, m.class_subject_id AS classSubjectId, m.rubric_scope_id AS rubricScopeId,
            rs.lingkup_materi AS lingkupMateri, m.judul, m.deskripsi, m.status,
            m.created_at AS createdAt,
            (SELECT JSON_ARRAYAGG(JSON_OBJECT('id', mf.id, 'fileName', mf.file_name, 'fileUrl', mf.file_url))
             FROM material_files mf WHERE mf.material_id = m.id) AS files,
            (SELECT COUNT(*) FROM comments c WHERE c.material_id = m.id AND c.deleted_at IS NULL) AS jumlahKomentar
     FROM materials m
     LEFT JOIN rubric_scopes rs ON rs.id = m.rubric_scope_id
     WHERE ${filters.join(" AND ")}
     ORDER BY m.created_at DESC`,
    params
  );
  return rows.map((row) => ({ ...row, files: parseJson(row.files, []) }));
}

app.get("/api/materials", auth, asyncHandler(async (req, res) => {
  const rows = await materialRows(req.query.classSubjectId, req.user.role, req.query.search || "");
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/materials", auth, requireRole("admin", "staff", "guru"), upload.array("files"), asyncHandler(async (req, res) => {
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      `INSERT INTO materials (class_subject_id, rubric_scope_id, judul, deskripsi, status, created_by)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        req.body.classSubjectId,
        numberOrNull(req.body.rubricScopeId),
        req.body.judul,
        req.body.deskripsi,
        req.body.status || "Draft",
        req.user.id,
      ]
    );
    for (const file of filesFromRequest(req.files)) {
      await connection.execute(
        "INSERT INTO material_files (material_id, file_name, file_url) VALUES (?, ?, ?)",
        [result.insertId, file.fileName, file.fileUrl]
      );
    }
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah materi", "materials", id, req.body.judul);
  res.status(201).json({ id });
}));

app.put("/api/materials/:id", auth, requireRole("admin", "staff", "guru"), upload.array("files"), asyncHandler(async (req, res) => {
  await tx(async (connection) => {
    await connection.execute(
      "UPDATE materials SET rubric_scope_id = ?, judul = ?, deskripsi = ?, status = ? WHERE id = ?",
      [
        numberOrNull(req.body.rubricScopeId),
        req.body.judul,
        req.body.deskripsi,
        req.body.status || "Draft",
        req.params.id,
      ]
    );
    for (const file of filesFromRequest(req.files)) {
      await connection.execute(
        "INSERT INTO material_files (material_id, file_name, file_url) VALUES (?, ?, ?)",
        [req.params.id, file.fileName, file.fileUrl]
      );
    }
  });
  await logActivity(req.user.id, "Ubah materi", "materials", req.params.id, req.body.judul);
  res.json({ ok: true });
}));

app.delete("/api/materials/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("UPDATE materials SET deleted_at = NOW() WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus materi", "materials", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/materials/:id/comments", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT c.id AS komentarId, c.user_id AS userId, u.role AS roleUser, u.nama AS username,
            c.komentar, c.created_at AS waktuKomentar
     FROM comments c JOIN users u ON u.id = c.user_id
     WHERE c.material_id = ? AND c.deleted_at IS NULL
     ORDER BY c.created_at ASC`,
    [req.params.id]
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/materials/:id/comments", auth, asyncHandler(async (req, res) => {
  const result = await q(
    "INSERT INTO comments (material_id, user_id, komentar) VALUES (?, ?, ?)",
    [req.params.id, req.user.id, req.body.komentar]
  );
  await logActivity(req.user.id, "Tambah komentar", "comments", result.insertId);
  res.status(201).json({ id: result.insertId });
}));

app.delete("/api/comments/:id", auth, asyncHandler(async (req, res) => {
  await q(
    "UPDATE comments SET deleted_at = NOW() WHERE id = ? AND (user_id = ? OR ? IN ('admin', 'staff'))",
    [req.params.id, req.user.id, req.user.role]
  );
  res.json({ ok: true });
}));

async function assignmentRows(classSubjectId, user, search = "") {
  const params = [classSubjectId];
  const filters = ["a.class_subject_id = ?", "a.deleted_at IS NULL"];
  if (user.role === "siswa") filters.push("a.status = 'Visible'");
  if (search) {
    filters.push("(a.judul LIKE ? OR a.deskripsi LIKE ?)");
    params.push(`%${search}%`, `%${search}%`);
  }
  const rows = await q(
    `SELECT a.id, a.class_subject_id AS classSubjectId, a.learning_objective_id AS learningObjectiveId,
            lo.deskripsi AS tujuanPembelajaran, a.judul, a.deskripsi, a.deadline, a.status,
            a.created_at AS createdAt,
            (SELECT JSON_ARRAYAGG(JSON_OBJECT('id', af.id, 'fileName', af.file_name, 'fileUrl', af.file_url))
             FROM assignment_files af WHERE af.assignment_id = a.id) AS files,
            (SELECT COUNT(*) FROM assignment_submissions sub WHERE sub.assignment_id = a.id) AS jumlahPengumpulan,
            sub.id AS pengumpulanId, sub.status AS statusPengumpulan, sub.nilai, sub.feedback
     FROM assignments a
     LEFT JOIN learning_objectives lo ON lo.id = a.learning_objective_id
     LEFT JOIN assignment_submissions sub ON sub.assignment_id = a.id AND sub.siswa_user_id = ?
     WHERE ${filters.join(" AND ")}
     ORDER BY a.deadline ASC, a.created_at DESC`,
    [user.id, ...params]
  );
  return rows.map((row) => ({ ...row, files: parseJson(row.files, []) }));
}

app.get("/api/assignments", auth, asyncHandler(async (req, res) => {
  const rows = await assignmentRows(req.query.classSubjectId, req.user, req.query.search || "");
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/assignments", auth, requireRole("admin", "staff", "guru"), upload.array("files"), asyncHandler(async (req, res) => {
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      `INSERT INTO assignments (class_subject_id, learning_objective_id, judul, deskripsi, deadline, status, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        req.body.classSubjectId,
        numberOrNull(req.body.learningObjectiveId),
        req.body.judul,
        req.body.deskripsi,
        req.body.deadline || null,
        req.body.status || "Draft",
        req.user.id,
      ]
    );
    for (const file of filesFromRequest(req.files)) {
      await connection.execute(
        "INSERT INTO assignment_files (assignment_id, file_name, file_url) VALUES (?, ?, ?)",
        [result.insertId, file.fileName, file.fileUrl]
      );
    }
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah tugas", "assignments", id, req.body.judul);
  res.status(201).json({ id });
}));

app.put("/api/assignments/:id", auth, requireRole("admin", "staff", "guru"), upload.array("files"), asyncHandler(async (req, res) => {
  await tx(async (connection) => {
    await connection.execute(
      "UPDATE assignments SET learning_objective_id = ?, judul = ?, deskripsi = ?, deadline = ?, status = ? WHERE id = ?",
      [
        numberOrNull(req.body.learningObjectiveId),
        req.body.judul,
        req.body.deskripsi,
        req.body.deadline || null,
        req.body.status || "Draft",
        req.params.id,
      ]
    );
    for (const file of filesFromRequest(req.files)) {
      await connection.execute(
        "INSERT INTO assignment_files (assignment_id, file_name, file_url) VALUES (?, ?, ?)",
        [req.params.id, file.fileName, file.fileUrl]
      );
    }
  });
  await logActivity(req.user.id, "Ubah tugas", "assignments", req.params.id, req.body.judul);
  res.json({ ok: true });
}));

app.delete("/api/assignments/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("UPDATE assignments SET deleted_at = NOW() WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus tugas", "assignments", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/assignments/:id/submissions", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT sub.id, sub.assignment_id AS assignmentId, sub.siswa_user_id AS siswaUserId,
            u.nama AS namaSiswa, sp.nis, sub.status, sub.nilai, sub.feedback,
            sub.submitted_at AS submittedAt,
            (SELECT JSON_ARRAYAGG(JSON_OBJECT('id', sf.id, 'fileName', sf.file_name, 'fileUrl', sf.file_url))
             FROM submission_files sf WHERE sf.submission_id = sub.id) AS files
     FROM assignment_submissions sub
     JOIN users u ON u.id = sub.siswa_user_id
     LEFT JOIN siswa_profiles sp ON sp.user_id = u.id
     WHERE sub.assignment_id = ?
     ORDER BY sub.submitted_at DESC`,
    [req.params.id]
  );
  res.json({ data: rows.map((row) => ({ ...row, files: parseJson(row.files, []) })), total: rows.length });
}));

app.post("/api/assignments/:id/submissions", auth, requireRole("siswa"), upload.array("files"), asyncHandler(async (req, res) => {
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      `INSERT INTO assignment_submissions (assignment_id, siswa_user_id, status)
       VALUES (?, ?, 'Terkirim')
       ON DUPLICATE KEY UPDATE status = 'Terkirim', updated_at = NOW(), nilai = nilai`,
      [req.params.id, req.user.id]
    );
    const submission =
      result.insertId ||
      (
        await connection.execute(
          "SELECT id FROM assignment_submissions WHERE assignment_id = ? AND siswa_user_id = ?",
          [req.params.id, req.user.id]
        )
      )[0][0].id;
    for (const file of filesFromRequest(req.files)) {
      await connection.execute(
        "INSERT INTO submission_files (submission_id, file_name, file_url) VALUES (?, ?, ?)",
        [submission, file.fileName, file.fileUrl]
      );
    }
    return submission;
  });
  await logActivity(req.user.id, "Mengumpulkan tugas", "assignment_submissions", id);
  res.status(201).json({ id });
}));

app.put("/api/submissions/:id/grade", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q(
    "UPDATE assignment_submissions SET nilai = ?, feedback = ?, status = 'Dinilai' WHERE id = ?",
    [req.body.nilai, req.body.feedback || "", req.params.id]
  );
  await logActivity(req.user.id, "Nilai tugas", "assignment_submissions", req.params.id, String(req.body.nilai));
  res.json({ ok: true });
}));

// Input nilai tugas langsung per siswa (buat submission jika belum ada)
app.put("/api/assignments/:id/grade-student", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const { studentId, nilai } = req.body;
  if (!studentId || nilai === undefined || nilai === null || nilai === "") {
    return res.status(400).json({ message: "studentId dan nilai diperlukan" });
  }
  const nilaiNum = Number(nilai);
  if (isNaN(nilaiNum) || nilaiNum < 0 || nilaiNum > 100) {
    return res.status(400).json({ message: "Nilai harus antara 0–100" });
  }
  const existing = await one(
    "SELECT id FROM assignment_submissions WHERE assignment_id = ? AND siswa_user_id = ?",
    [req.params.id, studentId]
  );
  if (existing) {
    await q("UPDATE assignment_submissions SET nilai = ?, status = 'Dinilai' WHERE id = ?", [nilaiNum, existing.id]);
  } else {
    await q(
      "INSERT INTO assignment_submissions (assignment_id, siswa_user_id, nilai, status) VALUES (?, ?, ?, 'Dinilai')",
      [req.params.id, studentId, nilaiNum]
    );
  }
  await logActivity(req.user.id, "Input nilai tugas", "assignment_submissions", req.params.id, `Siswa ${studentId}: ${nilaiNum}`);
  res.json({ ok: true });
}));

// Input nilai ujian langsung per siswa (set total, hapus & buat ulang jawaban dari soal pertama)
app.put("/api/exams/:id/grade-student", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const { studentId, nilai } = req.body;
  if (!studentId || nilai === undefined || nilai === null || nilai === "") {
    return res.status(400).json({ message: "studentId dan nilai diperlukan" });
  }
  const nilaiNum = Number(nilai);
  if (isNaN(nilaiNum) || nilaiNum < 0) {
    return res.status(400).json({ message: "Nilai tidak valid" });
  }
  const firstQuestion = await one(
    "SELECT id FROM exam_questions WHERE exam_id = ? ORDER BY urutan, id LIMIT 1",
    [req.params.id]
  );
  if (!firstQuestion) {
    return res.status(400).json({ message: "Ujian belum memiliki soal. Tambah soal terlebih dahulu." });
  }
  await q("DELETE FROM exam_answers WHERE exam_id = ? AND siswa_user_id = ?", [req.params.id, studentId]);
  await q(
    "INSERT INTO exam_answers (exam_id, question_id, siswa_user_id, nilai, status) VALUES (?, ?, ?, ?, 'Dinilai')",
    [req.params.id, firstQuestion.id, studentId, nilaiNum]
  );
  await logActivity(req.user.id, "Input nilai ujian", "exam_answers", req.params.id, `Siswa ${studentId}: ${nilaiNum}`);
  res.json({ ok: true });
}));

async function examRows(classSubjectId, user, search = "", tipeUjian = "") {
  const params = [classSubjectId];
  const filters = ["e.class_subject_id = ?", "e.deleted_at IS NULL"];
  if (user.role === "siswa") filters.push("e.status_ujian = 'Visible'");
  if (tipeUjian) {
    filters.push("e.tipe_ujian = ?");
    params.push(tipeUjian);
  }
  if (search) {
    filters.push("(e.judul LIKE ? OR e.deskripsi LIKE ?)");
    params.push(`%${search}%`, `%${search}%`);
  }
  const rows = await q(
    `SELECT e.id, e.class_subject_id AS classSubjectId, e.learning_objective_id AS learningObjectiveId,
            e.tipe_ujian AS tipeUjian, e.judul, e.deskripsi, e.tanggal_ujian AS tanggalUjian,
            e.jam_mulai AS jamMulai, e.jam_selesai AS jamSelesai, e.status_nilai AS statusNilai,
            e.status_ujian AS statusUjian, e.created_at AS createdAt,
            (SELECT COUNT(*) FROM exam_questions q WHERE q.exam_id = e.id) AS jumlahSoal,
            (SELECT COUNT(DISTINCT ea.siswa_user_id) FROM exam_answers ea WHERE ea.exam_id = e.id) AS jumlahPengerjaan,
            (SELECT SUM(ea.nilai) FROM exam_answers ea WHERE ea.exam_id = e.id AND ea.siswa_user_id = ?) AS nilaiSiswa
     FROM exams e
     WHERE ${filters.join(" AND ")}
     ORDER BY e.tanggal_ujian DESC, e.created_at DESC`,
    [user.id, ...params]
  );
  return rows;
}

app.get("/api/exams", auth, asyncHandler(async (req, res) => {
  const rows = await examRows(
    req.query.classSubjectId,
    req.user,
    req.query.search || "",
    req.query.tipeUjian || ""
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/exams", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const questions = Array.isArray(req.body.questions)
    ? req.body.questions
    : parseJson(req.body.questions, []);
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      `INSERT INTO exams
       (class_subject_id, learning_objective_id, tipe_ujian, judul, deskripsi, tanggal_ujian, jam_mulai, jam_selesai, status_nilai, status_ujian, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        req.body.classSubjectId,
        numberOrNull(req.body.learningObjectiveId),
        req.body.tipeUjian,
        req.body.judul,
        req.body.deskripsi,
        req.body.tanggalUjian || null,
        req.body.jamMulai || null,
        req.body.jamSelesai || null,
        req.body.statusNilai || "Draft",
        req.body.statusUjian || "Draft",
        req.user.id,
      ]
    );
    let index = 1;
    for (const question of questions) {
      await connection.execute(
        `INSERT INTO exam_questions
         (exam_id, tipe_soal, pertanyaan, opsi_a, opsi_b, opsi_c, opsi_d, jawaban_benar, bobot, urutan)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          result.insertId,
          question.tipeSoal || "Pilihan Ganda",
          question.pertanyaan,
          question.opsiA || null,
          question.opsiB || null,
          question.opsiC || null,
          question.opsiD || null,
          question.jawabanBenar || null,
          question.bobot || 1,
          index,
        ]
      );
      index += 1;
    }
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah ujian", "exams", id, req.body.judul);
  res.status(201).json({ id });
}));

app.put("/api/exams/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const questions = Array.isArray(req.body.questions)
    ? req.body.questions
    : parseJson(req.body.questions, []);
  await tx(async (connection) => {
    await connection.execute(
      `UPDATE exams SET learning_objective_id = ?, tipe_ujian = ?, judul = ?, deskripsi = ?,
       tanggal_ujian = ?, jam_mulai = ?, jam_selesai = ?, status_nilai = ?, status_ujian = ? WHERE id = ?`,
      [
        numberOrNull(req.body.learningObjectiveId),
        req.body.tipeUjian,
        req.body.judul,
        req.body.deskripsi,
        req.body.tanggalUjian || null,
        req.body.jamMulai || null,
        req.body.jamSelesai || null,
        req.body.statusNilai || "Draft",
        req.body.statusUjian || "Draft",
        req.params.id,
      ]
    );
    if (questions.length) {
      await connection.execute("DELETE FROM exam_questions WHERE exam_id = ?", [
        req.params.id,
      ]);
      let index = 1;
      for (const question of questions) {
        await connection.execute(
          `INSERT INTO exam_questions
           (exam_id, tipe_soal, pertanyaan, opsi_a, opsi_b, opsi_c, opsi_d, jawaban_benar, bobot, urutan)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          [
            req.params.id,
            question.tipeSoal || "Pilihan Ganda",
            question.pertanyaan,
            question.opsiA || null,
            question.opsiB || null,
            question.opsiC || null,
            question.opsiD || null,
            question.jawabanBenar || null,
            question.bobot || 1,
            index,
          ]
        );
        index += 1;
      }
    }
  });
  await logActivity(req.user.id, "Ubah ujian", "exams", req.params.id, req.body.judul);
  res.json({ ok: true });
}));

app.delete("/api/exams/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("UPDATE exams SET deleted_at = NOW() WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus ujian", "exams", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/exams/:id/questions", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT id, exam_id AS examId, tipe_soal AS tipeSoal, pertanyaan,
            opsi_a AS opsiA, opsi_b AS opsiB, opsi_c AS opsiC, opsi_d AS opsiD,
            jawaban_benar AS jawabanBenar, bobot, urutan
     FROM exam_questions WHERE exam_id = ? ORDER BY urutan`,
    [req.params.id]
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/exams/:id/answers", auth, requireRole("siswa"), asyncHandler(async (req, res) => {
  const answers = Array.isArray(req.body.answers) ? req.body.answers : [];
  const questions = await q("SELECT * FROM exam_questions WHERE exam_id = ?", [
    req.params.id,
  ]);
  const questionMap = new Map(questions.map((item) => [Number(item.id), item]));
  await tx(async (connection) => {
    for (const answer of answers) {
      const question = questionMap.get(Number(answer.questionId));
      if (!question) continue;
      const autoScore =
        question.tipe_soal === "Pilihan Ganda" &&
        String(answer.jawabanPilgan || "").toUpperCase() === question.jawaban_benar
          ? Number(question.bobot)
          : question.tipe_soal === "Pilihan Ganda"
            ? 0
            : null;
      await connection.execute(
        `INSERT INTO exam_answers
         (exam_id, question_id, siswa_user_id, jawaban_pilgan, jawaban_esai, nilai, status)
         VALUES (?, ?, ?, ?, ?, ?, ?)
         ON DUPLICATE KEY UPDATE jawaban_pilgan = VALUES(jawaban_pilgan),
          jawaban_esai = VALUES(jawaban_esai), nilai = VALUES(nilai), status = VALUES(status), answered_at = NOW()`,
        [
          req.params.id,
          answer.questionId,
          req.user.id,
          answer.jawabanPilgan || null,
          answer.jawabanEsai || null,
          autoScore,
          autoScore === null ? "Tersimpan" : "Dinilai",
        ]
      );
    }
  });
  await logActivity(req.user.id, "Mengumpulkan ujian", "exam_answers", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/exams/:id/attempts", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT u.id AS siswaUserId, u.nama AS namaSiswa, sp.nis,
            COUNT(ea.id) AS jumlahJawaban, SUM(ea.nilai) AS nilaiTotal,
            MAX(ea.answered_at) AS terakhirMengerjakan
     FROM exam_answers ea
     JOIN users u ON u.id = ea.siswa_user_id
     LEFT JOIN siswa_profiles sp ON sp.user_id = u.id
     WHERE ea.exam_id = ?
     GROUP BY u.id
     ORDER BY u.nama`,
    [req.params.id]
  );
  res.json({ data: rows, total: rows.length });
}));

app.get("/api/exams/:id/answers/:studentId", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT ea.id AS jawabanUjianId, ea.question_id AS soalUjianId, eq.tipe_soal AS tipeSoal,
            eq.pertanyaan, eq.jawaban_benar AS jawabanBenar, eq.bobot,
            ea.jawaban_pilgan AS jawabanPilgan, ea.jawaban_esai AS jawabanEsai,
            ea.status AS statusJawaban, ea.nilai AS nilaiJawaban
     FROM exam_answers ea
     JOIN exam_questions eq ON eq.id = ea.question_id
     WHERE ea.exam_id = ? AND ea.siswa_user_id = ?
     ORDER BY eq.urutan`,
    [req.params.id, req.params.studentId]
  );
  res.json({ data: rows, total: rows.length });
}));

app.put("/api/exam-answers/:id/grade", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("UPDATE exam_answers SET nilai = ?, status = 'Dinilai' WHERE id = ?", [
    req.body.nilai,
    req.params.id,
  ]);
  await logActivity(req.user.id, "Nilai jawaban ujian", "exam_answers", req.params.id, String(req.body.nilai));
  res.json({ ok: true });
}));

app.get("/api/class-subjects/:id/groups", auth, asyncHandler(async (req, res) => {
  const rows = await q(
    `SELECT sg.id, sg.nama_kelompok AS namaKelompok,
            JSON_ARRAYAGG(JSON_OBJECT('id', u.id, 'nama', u.nama, 'nis', sp.nis)) AS anggotaKelompok
     FROM study_groups sg
     LEFT JOIN study_group_members sgm ON sgm.group_id = sg.id
     LEFT JOIN users u ON u.id = sgm.siswa_user_id
     LEFT JOIN siswa_profiles sp ON sp.user_id = u.id
     WHERE sg.class_subject_id = ?
     GROUP BY sg.id
     ORDER BY sg.nama_kelompok`,
    [req.params.id]
  );
  res.json({
    data: rows.map((row) => ({
      ...row,
      anggotaKelompok: parseJson(row.anggotaKelompok, []).filter((item) => item.id),
      jumlahAnggota: parseJson(row.anggotaKelompok, []).filter((item) => item.id).length,
    })),
    total: rows.length,
  });
}));

app.post("/api/class-subjects/:id/groups", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const memberIds = splitIds(req.body.memberIds);
  const id = await tx(async (connection) => {
    const [result] = await connection.execute(
      "INSERT INTO study_groups (class_subject_id, nama_kelompok) VALUES (?, ?)",
      [req.params.id, req.body.namaKelompok]
    );
    for (const memberId of memberIds) {
      await connection.execute(
        "INSERT IGNORE INTO study_group_members (group_id, siswa_user_id) VALUES (?, ?)",
        [result.insertId, memberId]
      );
    }
    return result.insertId;
  });
  await logActivity(req.user.id, "Tambah kelompok belajar", "study_groups", id, req.body.namaKelompok);
  res.status(201).json({ id });
}));

app.put("/api/groups/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const memberIds = splitIds(req.body.memberIds);
  await tx(async (connection) => {
    await connection.execute("UPDATE study_groups SET nama_kelompok = ? WHERE id = ?", [
      req.body.namaKelompok,
      req.params.id,
    ]);
    await connection.execute("DELETE FROM study_group_members WHERE group_id = ?", [
      req.params.id,
    ]);
    for (const memberId of memberIds) {
      await connection.execute(
        "INSERT IGNORE INTO study_group_members (group_id, siswa_user_id) VALUES (?, ?)",
        [req.params.id, memberId]
      );
    }
  });
  await logActivity(req.user.id, "Ubah kelompok belajar", "study_groups", req.params.id, req.body.namaKelompok);
  res.json({ ok: true });
}));

app.delete("/api/groups/:id", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  await q("DELETE FROM study_groups WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus kelompok belajar", "study_groups", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/grades", auth, requireRole("admin", "staff", "guru"), asyncHandler(async (req, res) => {
  const { classSubjectId } = req.query;
  const type = req.query.type || "final";

  if (!classSubjectId) {
    return res.status(400).json({ message: "classSubjectId diperlukan" });
  }

  // Guru hanya boleh lihat kelasnya sendiri
  if (req.user.role === "guru") {
    const cs = await one(
      "SELECT id FROM class_subjects WHERE id = ? AND guru_user_id = ?",
      [classSubjectId, req.user.id]
    );
    if (!cs) return res.status(403).json({ message: "Akses tidak diizinkan untuk kelas ini" });
  }

  // Ambil siswa sekali
  const students = await q(
    `SELECT u.id AS siswaId, sp.nis, u.nama AS namaSiswa
     FROM class_subjects cs
     JOIN siswa_profiles sp ON sp.kelas_id = cs.class_id
     JOIN users u ON u.id = sp.user_id
     WHERE cs.id = ? AND u.deleted_at IS NULL
     ORDER BY u.nama`,
    [classSubjectId]
  );

  if (!students.length) return res.json({ data: [], total: 0 });

  // Ambil semua tugas sekali
  const allAssignments = await q(
    `SELECT id, judul FROM assignments WHERE class_subject_id = ? AND deleted_at IS NULL ORDER BY created_at`,
    [classSubjectId]
  );

  // Ambil semua ujian sekali (dengan tipe)
  const allExams = await q(
    `SELECT id, judul, tipe_ujian AS tipeUjian FROM exams WHERE class_subject_id = ? AND deleted_at IS NULL ORDER BY tanggal_ujian`,
    [classSubjectId]
  );

  // Filter ujian sesuai type
  const relevantExams =
    type === "practice"   ? allExams.filter((e) => e.tipeUjian === "Latihan Soal") :
    type === "sumative"   ? allExams.filter((e) => e.tipeUjian === "Sumatif Lingkup Materi") :
    type === "exam"       ? allExams.filter((e) => e.tipeUjian === "STS" || e.tipeUjian === "SAS") :
    allExams;

  const studentIds = students.map((s) => s.siswaId);
  const placeholders = studentIds.map(() => "?").join(",");

  // Semua submission tugas sekaligus
  const allSubs = allAssignments.length
    ? await q(
        `SELECT assignment_id, siswa_user_id, nilai, feedback
         FROM assignment_submissions
         WHERE assignment_id IN (${allAssignments.map(() => "?").join(",")})
           AND siswa_user_id IN (${placeholders})`,
        [...allAssignments.map((a) => a.id), ...studentIds]
      )
    : [];

  // Semua jawaban ujian sekaligus
  const allAnswers = allExams.length
    ? await q(
        `SELECT exam_id, siswa_user_id, SUM(nilai) AS total
         FROM exam_answers
         WHERE exam_id IN (${allExams.map(() => "?").join(",")})
           AND siswa_user_id IN (${placeholders})
         GROUP BY exam_id, siswa_user_id`,
        [...allExams.map((e) => e.id), ...studentIds]
      )
    : [];

  // Grade ranges untuk capaian
  const gradeRanges = await q(
    "SELECT kategori, min_nilai AS minNilai, max_nilai AS maxNilai FROM grade_ranges ORDER BY min_nilai DESC"
  );
  function getCapaian(score) {
    if (score === null || score === undefined) return "-";
    const range = gradeRanges.find((r) => score >= r.minNilai && score <= r.maxNilai);
    return range ? range.kategori : (score >= 75 ? "Baik" : "Perlu Bimbingan");
  }

  const result = students.map((student) => {
    // Tugas: tampilkan saat type=assignments atau final
    const nilaiTugas = (type === "assignments" || type === "final")
      ? allAssignments.map((a) => {
          const sub = allSubs.find(
            (s) => s.assignment_id === a.id && s.siswa_user_id === student.siswaId
          );
          return { id: a.id, judul: a.judul, nilai: sub?.nilai ?? null };
        })
      : [];

    // Ujian: sesuai type yang relevan
    const nilaiUjian = (type !== "assignments")
      ? relevantExams.map((e) => {
          const ans = allAnswers.find(
            (a) => a.exam_id === e.id && a.siswa_user_id === student.siswaId
          );
          return { id: e.id, judul: e.judul, tipeUjian: e.tipeUjian, nilai: ans?.total ?? null };
        })
      : [];

    // Hitung rata-rata hanya dari nilai yang sudah diisi
    const scores = [];
    nilaiTugas.forEach((t) => { if (t.nilai !== null) scores.push(Number(t.nilai)); });
    nilaiUjian.forEach((u) => { if (u.nilai !== null) scores.push(Number(u.nilai)); });

    const nilaiAkhir = scores.length
      ? Number((scores.reduce((a, b) => a + b, 0) / scores.length).toFixed(2))
      : null;

    return {
      siswaId: student.siswaId,
      nis: student.nis,
      namaSiswa: student.namaSiswa,
      nilaiTugas,
      nilaiUjian,
      nilaiAkhir,
      capaian: getCapaian(nilaiAkhir),
    };
  });

  res.json({ data: result, total: result.length });
}));

app.get("/api/staff-curriculum", auth, requireRole("admin"), asyncHandler(async (_req, res) => {
  const rows = await q(
    `SELECT u.id, u.nama, u.email, u.no_telp AS noTelp, sc.assigned_at AS assignedAt
     FROM staff_curriculum sc JOIN users u ON u.id = sc.user_id
     ORDER BY sc.assigned_at DESC`
  );
  res.json({ data: rows, total: rows.length });
}));

app.get("/api/staff-curriculum/candidates", auth, requireRole("admin"), asyncHandler(async (_req, res) => {
  const rows = await q(
    `SELECT u.id, u.nama, u.email
     FROM users u
     WHERE u.role IN ('guru', 'staff') AND u.deleted_at IS NULL
       AND u.id NOT IN (SELECT user_id FROM staff_curriculum)
     ORDER BY u.nama`
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/staff-curriculum", auth, requireRole("admin"), asyncHandler(async (req, res) => {
  await q("INSERT IGNORE INTO staff_curriculum (user_id) VALUES (?)", [
    req.body.userId,
  ]);
  await q("UPDATE users SET role = 'staff' WHERE id = ?", [req.body.userId]);
  await logActivity(req.user.id, "Tambah staff kurikulum", "staff_curriculum", req.body.userId);
  res.status(201).json({ ok: true });
}));

app.delete("/api/staff-curriculum/:id", auth, requireRole("admin"), asyncHandler(async (req, res) => {
  await q("DELETE FROM staff_curriculum WHERE user_id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus staff kurikulum", "staff_curriculum", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/activity-logs", auth, requireRole("admin"), asyncHandler(async (req, res) => {
  const { search } = normalizePage(req);
  const params = [];
  const filters = [];
  if (search) {
    filters.push("(l.aksi LIKE ? OR l.entitas LIKE ? OR l.detail LIKE ? OR u.nama LIKE ?)");
    params.push(`%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`);
  }
  const where = filters.length ? `WHERE ${filters.join(" AND ")}` : "";
  const result = await paged(
    req,
    `SELECT l.id, l.aksi, l.entitas, l.entitas_id AS entitasId, l.detail, l.created_at AS createdAt, u.nama
     FROM activity_logs l LEFT JOIN users u ON u.id = l.user_id
     ${where} ORDER BY l.created_at DESC`,
    `SELECT COUNT(*) AS total FROM activity_logs l LEFT JOIN users u ON u.id = l.user_id ${where}`,
    params
  );
  res.json(result);
}));

app.get("/api/grade-ranges", auth, asyncHandler(async (_req, res) => {
  const rows = await q(
    "SELECT id, kategori, min_nilai AS minNilai, max_nilai AS maxNilai, deskripsi FROM grade_ranges ORDER BY min_nilai"
  );
  res.json({ data: rows, total: rows.length });
}));

app.post("/api/grade-ranges", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  const result = await q(
    "INSERT INTO grade_ranges (kategori, min_nilai, max_nilai, deskripsi) VALUES (?, ?, ?, ?)",
    [req.body.kategori, req.body.minNilai, req.body.maxNilai, req.body.deskripsi]
  );
  await logActivity(req.user.id, "Tambah range nilai", "grade_ranges", result.insertId);
  res.status(201).json({ id: result.insertId });
}));

app.put("/api/grade-ranges/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q(
    "UPDATE grade_ranges SET kategori = ?, min_nilai = ?, max_nilai = ?, deskripsi = ? WHERE id = ?",
    [req.body.kategori, req.body.minNilai, req.body.maxNilai, req.body.deskripsi, req.params.id]
  );
  await logActivity(req.user.id, "Ubah range nilai", "grade_ranges", req.params.id);
  res.json({ ok: true });
}));

app.delete("/api/grade-ranges/:id", auth, requireRole("admin", "staff"), asyncHandler(async (req, res) => {
  await q("DELETE FROM grade_ranges WHERE id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus range nilai", "grade_ranges", req.params.id);
  res.json({ ok: true });
}));

// ==========================================================================
// Dashboard Guru + Analitik
// ==========================================================================
app.get("/api/guru/dashboard", auth, requireRole("guru"), asyncHandler(async (req, res) => {
  const gid = req.user.id;

  const [
    countKelas,
    countSiswa,
    countTugasAktif,
    avgNilai,
    countUjian,
    gradeDistribution,
    perClass,
    atRisk,
    upcomingAssignments,
    upcomingExams,
    needGrading,
    trend,
  ] = await Promise.all([
    one("SELECT COUNT(DISTINCT class_id) AS total FROM class_subjects WHERE guru_user_id = ?", [gid]),
    one(
      `SELECT COUNT(DISTINCT sp.user_id) AS total FROM siswa_profiles sp
       WHERE sp.kelas_id IN (SELECT class_id FROM class_subjects WHERE guru_user_id = ?)`,
      [gid]
    ),
    one(
      `SELECT COUNT(*) AS total FROM assignments a
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       WHERE cs.guru_user_id = ? AND a.deleted_at IS NULL
         AND (a.deadline IS NULL OR a.deadline >= NOW())`,
      [gid]
    ),
    one(
      `SELECT ROUND(AVG(s.nilai), 1) AS rata FROM assignment_submissions s
       JOIN assignments a ON a.id = s.assignment_id
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       WHERE cs.guru_user_id = ? AND s.nilai IS NOT NULL`,
      [gid]
    ),
    one(
      `SELECT COUNT(*) AS total FROM exams e
       JOIN class_subjects cs ON cs.id = e.class_subject_id
       WHERE cs.guru_user_id = ? AND e.deleted_at IS NULL AND e.tanggal_ujian >= CURDATE()`,
      [gid]
    ),
    q(
      `SELECT gr.kategori, gr.min_nilai AS minNilai, gr.max_nilai AS maxNilai,
        (SELECT COUNT(*) FROM assignment_submissions s
           JOIN assignments a ON a.id = s.assignment_id
           JOIN class_subjects cs ON cs.id = a.class_subject_id
         WHERE cs.guru_user_id = ? AND s.nilai IS NOT NULL
           AND s.nilai >= gr.min_nilai AND s.nilai <= gr.max_nilai) AS jumlah
       FROM grade_ranges gr ORDER BY gr.min_nilai`,
      [gid]
    ),
    q(
      `SELECT cs.id AS classSubjectId, c.nama_kelas AS namaKelas, sub.judul_mapel AS judulMapel,
        (SELECT COUNT(*) FROM siswa_profiles sp WHERE sp.kelas_id = cs.class_id) AS totalSiswa,
        (SELECT COUNT(*) FROM assignments a WHERE a.class_subject_id = cs.id AND a.deleted_at IS NULL) AS totalTugas,
        (SELECT ROUND(AVG(s.nilai), 1) FROM assignment_submissions s
           JOIN assignments a ON a.id = s.assignment_id
         WHERE a.class_subject_id = cs.id AND s.nilai IS NOT NULL) AS rataNilai,
        (SELECT COUNT(*) FROM assignment_submissions s
           JOIN assignments a ON a.id = s.assignment_id
         WHERE a.class_subject_id = cs.id) AS totalSubmit
       FROM class_subjects cs
       JOIN classes c ON c.id = cs.class_id
       JOIN subjects sub ON sub.id = cs.subject_id
       WHERE cs.guru_user_id = ?
       ORDER BY c.nama_kelas, sub.judul_mapel`,
      [gid]
    ),
    q(
      `SELECT u.id, u.nama, c.nama_kelas AS namaKelas,
              ROUND(AVG(s.nilai), 1) AS rataNilai, COUNT(s.id) AS totalDinilai
       FROM assignment_submissions s
       JOIN assignments a ON a.id = s.assignment_id
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN users u ON u.id = s.siswa_user_id
       WHERE cs.guru_user_id = ? AND s.nilai IS NOT NULL
       GROUP BY u.id, c.nama_kelas
       HAVING AVG(s.nilai) < 75
       ORDER BY rataNilai ASC LIMIT 8`,
      [gid]
    ),
    q(
      `SELECT a.id, a.judul, a.deadline, c.nama_kelas AS namaKelas, sub.judul_mapel AS judulMapel,
        (SELECT COUNT(*) FROM assignment_submissions s WHERE s.assignment_id = a.id) AS totalSubmit,
        (SELECT COUNT(*) FROM siswa_profiles sp WHERE sp.kelas_id = cs.class_id) AS totalSiswa
       FROM assignments a
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN subjects sub ON sub.id = cs.subject_id
       WHERE cs.guru_user_id = ? AND a.deleted_at IS NULL AND a.deadline >= NOW()
       ORDER BY a.deadline ASC LIMIT 6`,
      [gid]
    ),
    q(
      `SELECT e.id, e.judul, e.tipe_ujian AS tipeUjian, e.tanggal_ujian AS tanggalUjian,
              e.jam_mulai AS jamMulai, c.nama_kelas AS namaKelas, sub.judul_mapel AS judulMapel
       FROM exams e
       JOIN class_subjects cs ON cs.id = e.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN subjects sub ON sub.id = cs.subject_id
       WHERE cs.guru_user_id = ? AND e.deleted_at IS NULL AND e.tanggal_ujian >= CURDATE()
       ORDER BY e.tanggal_ujian ASC LIMIT 6`,
      [gid]
    ),
    q(
      `SELECT s.id, u.nama AS siswa, a.judul AS tugas, c.nama_kelas AS namaKelas,
              s.submitted_at AS submittedAt
       FROM assignment_submissions s
       JOIN assignments a ON a.id = s.assignment_id
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN users u ON u.id = s.siswa_user_id
       WHERE cs.guru_user_id = ? AND s.status = 'Terkirim'
       ORDER BY s.submitted_at DESC LIMIT 8`,
      [gid]
    ),
    q(
      `SELECT DATE_FORMAT(s.updated_at, '%Y-%m') AS bulan, ROUND(AVG(s.nilai), 1) AS rataNilai
       FROM assignment_submissions s
       JOIN assignments a ON a.id = s.assignment_id
       JOIN class_subjects cs ON cs.id = a.class_subject_id
       WHERE cs.guru_user_id = ? AND s.nilai IS NOT NULL
       GROUP BY DATE_FORMAT(s.updated_at, '%Y-%m')
       ORDER BY bulan DESC LIMIT 6`,
      [gid]
    ),
  ]);

  res.json({
    counts: {
      kelas: Number(countKelas?.total || 0),
      siswa: Number(countSiswa?.total || 0),
      tugasAktif: Number(countTugasAktif?.total || 0),
      ujianMendatang: Number(countUjian?.total || 0),
      rataNilai: avgNilai?.rata !== null && avgNilai?.rata !== undefined ? Number(avgNilai.rata) : null,
    },
    gradeDistribution: gradeDistribution.map((r) => ({
      kategori: r.kategori,
      jumlah: Number(r.jumlah || 0),
    })),
    perClass,
    atRisk,
    upcomingAssignments,
    upcomingExams,
    needGrading,
    trend: [...trend].reverse(),
  });
}));

// ==========================================================================
// Pengumuman & Notifikasi
// ==========================================================================
async function fanoutAnnouncement(announcementId, classSubjectId, judul, authorNama) {
  const students = await q(
    `SELECT sp.user_id FROM siswa_profiles sp
     JOIN class_subjects cs ON cs.class_id = sp.kelas_id
     WHERE cs.id = ?`,
    [classSubjectId]
  );
  if (!students.length) return 0;
  const placeholders = students.map(() => "(?, ?, ?, ?, ?, ?)").join(", ");
  const params = [];
  for (const s of students) {
    params.push(
      s.user_id,
      "announcement",
      `Pengumuman: ${judul}`,
      `${authorNama} membagikan pengumuman baru.`,
      "/main/pengumumanSiswa",
      announcementId
    );
  }
  await q(
    `INSERT INTO notifications (user_id, tipe, judul, isi, link, ref_id) VALUES ${placeholders}`,
    params
  );
  return students.length;
}

app.get("/api/announcements", auth, asyncHandler(async (req, res) => {
  if (req.user.role === "guru") {
    const rows = await q(
      `SELECT an.id, an.judul, an.isi, an.prioritas, an.pinned, an.class_subject_id AS classSubjectId,
              an.created_at AS createdAt, c.nama_kelas AS namaKelas, sub.judul_mapel AS judulMapel
       FROM announcements an
       JOIN class_subjects cs ON cs.id = an.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN subjects sub ON sub.id = cs.subject_id
       WHERE an.author_user_id = ? AND an.deleted_at IS NULL
       ORDER BY an.pinned DESC, an.created_at DESC`,
      [req.user.id]
    );
    res.json({ data: rows });
    return;
  }
  if (req.user.role === "siswa") {
    const rows = await q(
      `SELECT an.id, an.judul, an.isi, an.prioritas, an.pinned, an.created_at AS createdAt,
              u.nama AS pengirim, c.nama_kelas AS namaKelas, sub.judul_mapel AS judulMapel
       FROM announcements an
       JOIN class_subjects cs ON cs.id = an.class_subject_id
       JOIN classes c ON c.id = cs.class_id
       JOIN subjects sub ON sub.id = cs.subject_id
       JOIN users u ON u.id = an.author_user_id
       WHERE an.deleted_at IS NULL
         AND cs.class_id = (SELECT kelas_id FROM siswa_profiles WHERE user_id = ?)
       ORDER BY an.pinned DESC, an.created_at DESC`,
      [req.user.id]
    );
    res.json({ data: rows });
    return;
  }
  res.json({ data: [] });
}));

app.post("/api/announcements", auth, requireRole("guru"), asyncHandler(async (req, res) => {
  const { classSubjectId, judul, isi, prioritas = "Normal", pinned = 0 } = req.body;
  if (!classSubjectId || !judul || !isi) {
    return res.status(400).json({ message: "Kelas, judul, dan isi wajib diisi" });
  }
  const owns = await one(
    "SELECT id FROM class_subjects WHERE id = ? AND guru_user_id = ?",
    [classSubjectId, req.user.id]
  );
  if (!owns) {
    return res.status(403).json({ message: "Kelas bukan milik Anda" });
  }
  const result = await q(
    `INSERT INTO announcements (author_user_id, class_subject_id, judul, isi, prioritas, pinned)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [req.user.id, classSubjectId, judul, isi, prioritas, pinned ? 1 : 0]
  );
  const penerima = await fanoutAnnouncement(result.insertId, classSubjectId, judul, req.user.nama);
  await logActivity(req.user.id, "Buat pengumuman", "announcements", result.insertId, judul);
  res.status(201).json({ id: result.insertId, penerima });
}));

app.delete("/api/announcements/:id", auth, requireRole("guru"), asyncHandler(async (req, res) => {
  await q(
    "UPDATE announcements SET deleted_at = NOW() WHERE id = ? AND author_user_id = ?",
    [req.params.id, req.user.id]
  );
  await q("DELETE FROM notifications WHERE tipe = 'announcement' AND ref_id = ?", [req.params.id]);
  await logActivity(req.user.id, "Hapus pengumuman", "announcements", req.params.id);
  res.json({ ok: true });
}));

app.get("/api/notifications", auth, asyncHandler(async (req, res) => {
  const [rows, unread] = await Promise.all([
    q(
      `SELECT id, tipe, judul, isi, link, ref_id AS refId, is_read AS isRead, created_at AS createdAt
       FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20`,
      [req.user.id]
    ),
    one("SELECT COUNT(*) AS total FROM notifications WHERE user_id = ? AND is_read = 0", [req.user.id]),
  ]);
  res.json({
    data: rows.map((r) => ({ ...r, isRead: Number(r.isRead) })),
    unread: Number(unread?.total || 0),
  });
}));

app.post("/api/notifications/read", auth, asyncHandler(async (req, res) => {
  const ids = splitIds(req.body?.ids);
  if (ids.length) {
    const placeholders = ids.map(() => "?").join(",");
    await q(
      `UPDATE notifications SET is_read = 1 WHERE user_id = ? AND id IN (${placeholders})`,
      [req.user.id, ...ids]
    );
  } else {
    await q("UPDATE notifications SET is_read = 1 WHERE user_id = ?", [req.user.id]);
  }
  res.json({ ok: true });
}));

// SPA fallback: rute non-API dikembalikan ke index.html agar React Router bekerja.
if (serveClient) {
  app.get("*", (req, res, next) => {
    if (req.path.startsWith("/api") || req.path.startsWith("/uploads")) {
      return next();
    }
    res.sendFile(path.join(distDir, "index.html"));
  });
}

app.use((error, _req, res, _next) => {
  console.error(error);
  const status = error?.code === "ER_NO_SUCH_TABLE" ? 503 : 500;
  res.status(status).json({
    message:
      status === 503
        ? "Database belum siap. Import database/elearning_sma.sql terlebih dahulu."
        : "Terjadi kesalahan server",
    detail: process.env.NODE_ENV === "production" ? undefined : error.message,
  });
});

async function ensureSchema() {
  await q(`CREATE TABLE IF NOT EXISTS announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_user_id INT NOT NULL,
    class_subject_id INT NOT NULL,
    judul VARCHAR(180) NOT NULL,
    isi MEDIUMTEXT NOT NULL,
    prioritas ENUM('Normal', 'Penting', 'Mendesak') NOT NULL DEFAULT 'Normal',
    pinned TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (author_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (class_subject_id) REFERENCES class_subjects(id) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`);

  await q(`CREATE TABLE IF NOT EXISTS notifications (
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
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`);
}

// Import skema + seed dari database/elearning_sma.sql saat startup.
// File ini idempoten (CREATE TABLE IF NOT EXISTS + INSERT IGNORE), jadi aman
// dijalankan tiap boot. Cocok untuk deploy Dockerfile-only + managed database:
// database sudah dibuat oleh penyedia, jadi statement CREATE DATABASE / USE
// (butuh hak server-level) dibuang agar tidak "Access denied" pada user terbatas.
// Nonaktifkan dengan AUTO_MIGRATE=false bila skema dikelola manual.
async function autoMigrate() {
  if (process.env.AUTO_MIGRATE === "false") return;
  const sqlPath = path.join(rootDir, "database", "elearning_sma.sql");
  if (!fs.existsSync(sqlPath)) {
    console.warn("AUTO_MIGRATE dilewati: database/elearning_sma.sql tidak ditemukan.");
    return;
  }
  const sql = fs
    .readFileSync(sqlPath, "utf8")
    .replace(/CREATE\s+DATABASE[\s\S]*?;/i, "")
    .replace(/USE\s+`?[\w-]+`?\s*;/i, "")
    .trim();
  if (!sql) return;

  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || "127.0.0.1",
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "elearning_sma",
    multipleStatements: true,
  });
  try {
    await conn.query(sql);
    console.log("AUTO_MIGRATE: skema & seed database dipastikan ada.");
  } finally {
    await conn.end();
  }
}

const host = process.env.HOST || "127.0.0.1";

autoMigrate()
  .then(() => ensureSchema())
  .then(() => {
    app.listen(port, host, () => {
      console.log(`E-learning SMA API running on http://${host}:${port}`);
    });
  })
  .catch((error) => {
    console.error("Gagal menyiapkan skema database:", error.message);
    process.exit(1);
  });
