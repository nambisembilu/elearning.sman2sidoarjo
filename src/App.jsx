import {
  AlertTriangle,
  BarChart3,
  Bell,
  BookOpen,
  CalendarDays,
  Check,
  CheckCheck,
  ClipboardList,
  Clock,
  Download,
  Edit3,
  FileText,
  GraduationCap,
  Home,
  Key,
  Layers3,
  LibraryBig,
  ListChecks,
  LogOut,
  Megaphone,
  Menu,
  MessageSquare,
  Pin,
  Plus,
  Power,
  RefreshCw,
  Save,
  School,
  Search,
  ShieldCheck,
  Sparkles,
  TrendingUp,
  Trash2,
  Upload,
  UserCog,
  Users,
  X,
} from "lucide-react";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import {
  Link,
  Navigate,
  Outlet,
  Route,
  Routes,
  useLocation,
  useNavigate,
  useParams,
} from "react-router-dom";
import {
  apiFetch,
  clearSession,
  getStoredSession,
  storeSession,
  withQuery,
} from "./lib/api";
import { cn, formatDate, formatDateTime, toFormData } from "./lib/utils";
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Dialog,
  Input,
  Label,
  LoadingBlock,
  Pagination,
  SearchableSelect,
  Select,
  Table,
  Tabs,
  Textarea,
  Toast,
} from "./components/ui";

const AuthContext = createContext(null);

const roleLabels = {
  admin: "Admin",
  staff: "Staff Kurikulum",
  guru: "Guru",
  siswa: "Siswa",
};

const firstRouteByRole = {
  admin: "/main/daftarStaff",
  staff: "/main/dataGuru",
  guru: "/main/kelasGuru",
  siswa: "/main/kelasSiswa",
};

const menuByRole = {
  admin: [
    ["Daftar Staff", ShieldCheck, "/main/daftarStaff"],
    ["Log Aktivitas", ClipboardList, "/main/logAktivitas"],
    ["Data Siswa", Users, "/main/dataSiswa"],
    ["Manajemen User", UserCog, "/main/manajemenUser"],
  ],
  staff: [
    ["Data Guru", Users, "/main/dataGuru"],
    ["Data Siswa", Users, "/main/dataSiswa"],
    ["Kelas", School, "/main/kelas"],
    ["Mata Pelajaran", BookOpen, "/main/mataPelajaran"],
    ["Jadwal Akademik", CalendarDays, "/main/jadwalAkademik"],
    ["Jadwal Pelajaran", ListChecks, "/main/jadwalPelajaran"],
    ["Rubrik Mapel", Layers3, "/main/rubrikMapel"],
    ["Tahun Ajaran", LibraryBig, "/main/tahunAjaran"],
    ["Range Nilai", Check, "/main/rangeNilaiKategori"],
    ["Nilai Latihan Soal", ClipboardList, "/main/nilaiLatsol"],
    ["Nilai Tugas", ClipboardList, "/main/nilaiTugas"],
    ["Sumatif LM", ClipboardList, "/main/sumatifLingkupMateri"],
    ["Nilai Ujian Sumatif", ClipboardList, "/main/nilaiUjianSumatif"],
    ["Nilai Akhir", GraduationCap, "/main/nilaiAkhir"],
    ["Manajemen User", UserCog, "/main/manajemenUser"],
  ],
  guru: [
    ["Kelas", School, "/main/kelasGuru"],
    ["Rubrik Mapel", Layers3, "/main/rubrikMapelKelas"],
    ["Jadwal Pelajaran", CalendarDays, "/main/jadwalMengajar"],
    ["Jadwal Akademik", LibraryBig, "/main/jadwalAkademikGuru"],
    ["Nilai Tugas", ClipboardList, "/main/nilaiTugas"],
    ["Sumatif LM", ClipboardList, "/main/sumatifLingkupMateri"],
    ["Nilai Ujian Sumatif", ClipboardList, "/main/nilaiUjianSumatif"],
    ["Nilai Akhir", GraduationCap, "/main/nilaiAkhirKelas"],
  ],
  siswa: [
    ["Kelas", School, "/main/kelasSiswa"],
    ["Jadwal Pelajaran", CalendarDays, "/main/jadwalSiswa"],
    ["Pengumuman", Megaphone, "/main/pengumumanSiswa"],
  ],
};

function AuthProvider({ children }) {
  const [session, setSession] = useState(() => getStoredSession());

  const login = async (identifier, password) => {
    const nextSession = await apiFetch("/auth/login", {
      method: "POST",
      body: { identifier, password },
    });
    storeSession(nextSession);
    setSession(nextSession);
    return nextSession;
  };

  const logout = () => {
    clearSession();
    setSession(null);
  };

  return (
    <AuthContext.Provider value={{ session, user: session?.user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

function useAuth() {
  return useContext(AuthContext);
}

function useToast() {
  const [toast, setToast] = useState(null);
  const show = (message, type = "success") => setToast({ message, type });
  const node = (
    <Toast
      message={toast?.message}
      type={toast?.type}
      onClose={() => setToast(null)}
    />
  );
  return { show, node };
}

function parseCsv(text) {
  const rows = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const cells = [];
      let current = "";
      let quoted = false;
      for (let i = 0; i < line.length; i += 1) {
        const char = line[i];
        if (char === '"' && line[i + 1] === '"') {
          current += '"';
          i += 1;
        } else if (char === '"') {
          quoted = !quoted;
        } else if (char === "," && !quoted) {
          cells.push(current.trim());
          current = "";
        } else {
          current += char;
        }
      }
      cells.push(current.trim());
      return cells;
    });
  const [header = [], ...body] = rows;
  return body.map((cells) =>
    header.reduce((record, key, index) => {
      record[key.trim()] = cells[index] || "";
      return record;
    }, {}),
  );
}

function useOptions() {
  const [options, setOptions] = useState({
    academicYears: [],
    semesters: [],
    classes: [],
    subjects: [],
    teachers: [],
    students: [],
    classSubjects: [],
    waliCandidates: [],
  });

  const refresh = useCallback(async () => {
    const data = await apiFetch("/options");
    setOptions(data);
  }, []);

  useEffect(() => {
    refresh().catch(() => {});
  }, [refresh]);

  return { options, refreshOptions: refresh };
}

function ProtectedRoute({ children }) {
  const { session } = useAuth();
  const location = useLocation();
  if (!session?.token) {
    return <Navigate to="/" state={{ from: location }} replace />;
  }
  return children;
}

function RoleRedirect() {
  const { user } = useAuth();
  return <Navigate to={firstRouteByRole[user?.role] || "/"} replace />;
}

// Pembatas akses per-route: role yang tidak diizinkan dilempar ke halaman awalnya.
function RoleGate({ allow, children }) {
  const { user } = useAuth();
  if (!allow.includes(user?.role)) return <RoleRedirect />;
  return children;
}

function LandingPage() {
  const { session } = useAuth();
  if (session?.user) return <Navigate to={firstRouteByRole[session.user.role]} />;

  return (
    <main className="min-h-screen bg-background">
      <section className="relative min-h-[86vh] overflow-hidden">
        <img
          src="/images/elearning-hero.png"
          alt="Siswa dan guru menggunakan e-learning"
          className="absolute inset-0 h-full w-full object-cover"
        />
        <div className="absolute inset-0 bg-slate-950/30" />
        <div className="absolute inset-0 bg-gradient-to-r from-slate-950/95 via-slate-950/80 to-slate-950/30" />
        <div className="relative z-10 mx-auto flex min-h-[86vh] max-w-7xl flex-col justify-between px-5 py-6 md:px-8">
          <nav className="flex items-center justify-between text-white">
            <Link to="/" className="flex items-center gap-3 font-semibold">
              <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-white/14 backdrop-blur">
                <School className="h-5 w-5" />
              </span>
              <span>E-Learning SMAN 2 Sidoarjo</span>
            </Link>
            <Link to="/login">
              <Button className="bg-white text-slate-950 hover:bg-white/90">
                Masuk
              </Button>
            </Link>
          </nav>

          <div className="max-w-2xl pb-14 text-white">
            <h1 className="max-w-xl text-3xl font-semibold leading-tight tracking-normal drop-shadow md:text-6xl">
              E-Learning SMAN 2 Sidoarjo
            </h1>
            <p className="mt-5 max-w-xl text-base leading-7 text-white/90 drop-shadow md:text-lg">
              Sistem pembelajaran sekolah untuk staff kurikulum, guru, siswa,
              dan admin: kelas, materi, tugas, ujian, nilai, rubrik, jadwal, dan
              data akademik dalam satu tempat.
            </p>
            <div className="mt-7 flex flex-wrap gap-3">
              <Link to="/login">
                <Button>
                  <LogOut className="h-4 w-4 rotate-180" />
                  Mulai Login
                </Button>
              </Link>
              <a href="#fitur">
                <Button variant="secondary">Lihat Fitur</Button>
              </a>
            </div>
          </div>
        </div>
      </section>

      <section
        id="fitur"
        className="mx-auto grid max-w-7xl gap-4 px-5 py-10 md:grid-cols-4 md:px-8"
      >
        {[
          ["Kurikulum", "Data guru, siswa, kelas, mapel, jadwal, dan tahun ajaran."],
          ["Pembelajaran", "Materi, komentar, tugas, file, kelompok belajar, dan rubrik."],
          ["Evaluasi", "Ujian pilihan ganda/esai, pengumpulan jawaban, dan penilaian."],
          ["Role Lengkap", "Admin, staff, guru, dan siswa memakai dashboard sesuai akses."],
        ].map(([title, text]) => (
          <Card key={title}>
            <CardHeader>
              <CardTitle>{title}</CardTitle>
              <CardDescription>{text}</CardDescription>
            </CardHeader>
          </Card>
        ))}
      </section>
    </main>
  );
}

function LoginPage() {
  const { login, session } = useAuth();
  const navigate = useNavigate();
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { show, node } = useToast();

  if (session?.user) return <Navigate to={firstRouteByRole[session.user.role]} />;

  const submit = async (event) => {
    event.preventDefault();
    setLoading(true);
    try {
      const result = await login(identifier, password);
      navigate(firstRouteByRole[result.user.role] || "/main");
    } catch (error) {
      show(error.message, "error");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="grid min-h-screen bg-slate-100 lg:grid-cols-[minmax(0,1fr)_520px]">
      {node}
      <section className="hidden min-h-screen overflow-hidden bg-[linear-gradient(135deg,#042f2e_0%,#0f172a_54%,#1f2937_100%)] p-8 text-white lg:flex">
        <div className="flex w-full flex-col justify-between rounded-xl border border-white/10 bg-white/[0.03] p-8 shadow-2xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-teal-400 text-slate-950">
                <School className="h-6 w-6" />
              </div>
              <div>
                <div className="font-semibold">E-Learning SMA</div>
                <div className="text-xs text-white/58">SMAN 2 Sidoarjo</div>
              </div>
            </div>
            <Badge className="border-white/10 bg-white/10 text-white">Online</Badge>
          </div>

          <div className="max-w-2xl">
            <Badge className="mb-5 border-amber-300/30 bg-amber-300 text-slate-950">
              Portal Akademik
            </Badge>
            <h1 className="text-4xl font-semibold leading-tight tracking-normal xl:text-5xl">
              Satu akses untuk pembelajaran, jadwal, tugas, dan nilai.
            </h1>
            <p className="mt-5 max-w-xl text-sm leading-6 text-white/68">
              Dashboard role-based untuk admin, staff kurikulum, guru, dan siswa
              dengan alur kerja yang ringkas.
            </p>
          </div>

          <div className="grid gap-3 xl:grid-cols-3">
            {[
              ["Kelas aktif", "18", School],
              ["Materi", "126", BookOpen],
              ["Tugas dinilai", "84%", Check],
            ].map(([label, value, Icon]) => (
              <div
                key={label}
                className="rounded-xl border border-white/10 bg-white/[0.07] p-4"
              >
                <Icon className="h-5 w-5 text-teal-300" />
                <div className="mt-4 text-2xl font-semibold">{value}</div>
                <div className="text-xs text-white/58">{label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>
      <section className="flex min-h-screen items-center justify-center p-5">
        <div className="w-full max-w-md space-y-5">
          <div className="flex items-center gap-3 lg:hidden">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-primary-foreground">
              <School className="h-5 w-5" />
            </div>
            <div>
              <div className="font-semibold">E-Learning SMA</div>
              <div className="text-xs text-muted-foreground">SMAN 2 Sidoarjo</div>
            </div>
          </div>

          <Card className="border-slate-200 bg-white shadow-soft">
            <CardHeader className="pb-4">
              <Badge className="mb-2 w-fit bg-teal-50 text-teal-700">
                Masuk Sistem
              </Badge>
              <CardTitle className="text-2xl">Selamat datang kembali</CardTitle>
              <CardDescription>
                Login menggunakan NIP/NUPTK/NISN atau identifier akun.
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form className="space-y-4" onSubmit={submit}>
                <Field label="Identifier">
                  <Input
                    value={identifier}
                    onChange={(event) => setIdentifier(event.target.value)}
                    placeholder="2000"
                  />
                </Field>
                <Field label="Password">
                  <Input
                    type="password"
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                  />
                </Field>
                <Button className="w-full" disabled={loading}>
                  {loading ? "Memproses..." : "Masuk"}
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>
      </section>
    </main>
  );
}

function AppShell() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const menus = menuByRole[user?.role] || [];

  const doLogout = () => {
    logout();
    navigate("/");
  };

  const initials = user?.nama
    ? user.nama
        .split(" ")
        .slice(0, 2)
        .map((w) => w[0])
        .join("")
        .toUpperCase()
    : "?";

  const navLink = (to, label, Icon, exact = false) => {
    const active = exact
      ? location.pathname === to
      : location.pathname.startsWith(to);
    return (
      <Link
        key={to}
        to={to}
        onClick={() => setOpen(false)}
        className={cn(
          "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all",
          active
            ? "bg-primary/10 text-primary"
            : "text-muted-foreground hover:bg-muted hover:text-foreground",
        )}
      >
        <Icon className="h-4 w-4 shrink-0" />
        {label}
      </Link>
    );
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Sidebar */}
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-40 flex w-64 flex-col border-r bg-card transition-transform lg:translate-x-0",
          open ? "translate-x-0" : "-translate-x-full",
        )}
      >
        {/* Brand */}
        <div className="flex h-16 items-center gap-3 border-b px-5">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-sm">
            <School className="h-5 w-5" />
          </div>
          <div className="min-w-0">
            <div className="truncate text-sm font-semibold">E-Learning SMA</div>
            <div className="text-xs text-muted-foreground">
              {roleLabels[user?.role]}
            </div>
          </div>
        </div>

        {/* Nav */}
        <nav className="flex-1 space-y-0.5 overflow-y-auto p-3 app-scrollbar">
          {navLink("/main", "Beranda", Home, true)}
          {menus.map(([label, Icon, route]) =>
            navLink(route, label, Icon),
          )}
        </nav>

        {/* User footer */}
        <div className="border-t p-3">
          <div className="flex items-center gap-3 rounded-lg px-3 py-2.5 bg-muted/50">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary/15 text-xs font-bold text-primary">
              {initials}
            </div>
            <div className="min-w-0 flex-1">
              <div className="truncate text-sm font-medium">{user?.nama}</div>
              <div className="text-xs text-muted-foreground">
                {roleLabels[user?.role]}
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Overlay mobile */}
      {open ? (
        <button
          className="fixed inset-0 z-30 bg-slate-950/30 lg:hidden"
          onClick={() => setOpen(false)}
          aria-label="Tutup menu"
        />
      ) : null}

      {/* Main content */}
      <div className="lg:pl-64">
        <header className="sticky top-0 z-20 flex h-16 items-center justify-between border-b bg-card/95 px-4 backdrop-blur md:px-6 shadow-soft">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              className="lg:hidden"
              onClick={() => setOpen(true)}
            >
              <Menu className="h-5 w-5" />
            </Button>
            <div>
              <div className="text-xs text-muted-foreground">Selamat bekerja</div>
              <div className="text-sm font-semibold">{user?.nama}</div>
            </div>
          </div>
          <div className="flex items-center gap-3">
            <NotificationBell />
            <Button variant="outline" onClick={doLogout}>
              <LogOut className="h-4 w-4" />
              Keluar
            </Button>
          </div>
        </header>
        <main className="mx-auto max-w-7xl p-4 md:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

function Field({ label, children, hint }) {
  return (
    <div className="space-y-2">
      <Label>{label}</Label>
      {children}
      {hint ? <p className="text-xs text-muted-foreground">{hint}</p> : null}
    </div>
  );
}

function PageHeader({ title, description, action }) {
  return (
    <div className="mb-6 flex flex-col justify-between gap-3 md:flex-row md:items-end">
      <div>
        <h1 className="text-2xl font-semibold tracking-normal">{title}</h1>
        {description ? (
          <p className="mt-1 max-w-3xl text-sm text-muted-foreground">
            {description}
          </p>
        ) : null}
      </div>
      {action}
    </div>
  );
}

const statColors = [
  { icon: "text-blue-500", bg: "bg-blue-50" },
  { icon: "text-violet-500", bg: "bg-violet-50" },
  { icon: "text-teal-500", bg: "bg-teal-50" },
  { icon: "text-amber-500", bg: "bg-amber-50" },
];

function DashboardPage() {
  const { user } = useAuth();
  if (user?.role === "guru") return <TeacherDashboard />;
  return <StaffDashboard user={user} />;
}

function StaffDashboard({ user }) {
  const [data, setData] = useState(null);

  useEffect(() => {
    apiFetch("/overview").then(setData).catch(() => setData({}));
  }, []);

  if (!data) return <LoadingBlock />;

  const stats = [
    ["Guru", data.counts?.guru || 0, Users],
    ["Siswa", data.counts?.siswa || 0, Users],
    ["Kelas Mapel", data.counts?.kelasMapel || 0, School],
    ["Tugas", data.counts?.tugas || 0, FileText],
  ];

  return (
    <div>
      <PageHeader
        title={`Dashboard ${roleLabels[user?.role] || ""}`}
        description="Ringkasan aktivitas akademik, jadwal, tugas, dan ujian terbaru."
      />
      <div className="grid gap-4 md:grid-cols-4">
        {stats.map(([label, value, Icon], idx) => {
          const color = statColors[idx % statColors.length];
          return (
            <Card key={label}>
              <CardContent className="flex items-center gap-4 pt-5">
                <div
                  className={cn(
                    "flex h-12 w-12 shrink-0 items-center justify-center rounded-xl",
                    color.bg,
                  )}
                >
                  <Icon className={cn("h-5 w-5", color.icon)} />
                </div>
                <div>
                  <div className="text-2xl font-bold">{value}</div>
                  <div className="text-sm text-muted-foreground">{label}</div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>
      <div className="mt-5 grid gap-4 lg:grid-cols-2">
        <MiniList
          title="Jadwal Akademik"
          items={(data.events || []).map((item) => ({
            title: item.namaKegiatan,
            meta: `${formatDate(item.tanggalMulai)} - ${formatDate(item.tanggalSelesai)}`,
          }))}
        />
        <MiniList
          title="Aktivitas Terbaru"
          items={(data.recentLogs || []).map((item) => ({
            title: item.aksi,
            meta: `${item.nama || "System"} - ${formatDateTime(item.createdAt)}`,
          }))}
        />
      </div>
    </div>
  );
}

function MiniList({ title, items }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2">
        {items.length ? (
          items.map((item, index) => (
            <div key={index} className="rounded-lg border bg-muted/20 p-3">
              <div className="font-medium text-sm">{item.title}</div>
              <div className="text-xs text-muted-foreground mt-0.5">{item.meta}</div>
            </div>
          ))
        ) : (
          <p className="text-sm text-muted-foreground">Belum ada data.</p>
        )}
      </CardContent>
    </Card>
  );
}

// ==========================================================================
// Dashboard Guru + Analitik
// ==========================================================================
function greeting() {
  const h = new Date().getHours();
  if (h < 11) return "Selamat pagi";
  if (h < 15) return "Selamat siang";
  if (h < 18) return "Selamat sore";
  return "Selamat malam";
}

const gradeChartTones = {
  "Perlu Bimbingan": { bar: "bg-rose-500", text: "text-rose-600", soft: "bg-rose-50" },
  Cukup: { bar: "bg-amber-500", text: "text-amber-600", soft: "bg-amber-50" },
  Baik: { bar: "bg-blue-500", text: "text-blue-600", soft: "bg-blue-50" },
  "Sangat Baik": { bar: "bg-teal-500", text: "text-teal-600", soft: "bg-teal-50" },
};

function TeacherDashboard() {
  const { user } = useAuth();
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    apiFetch("/guru/dashboard").then(setData).catch((e) => setError(e.message));
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  if (error) {
    return (
      <div className="rounded-xl border border-dashed p-8 text-center text-sm text-muted-foreground">
        Gagal memuat analitik: {error}
      </div>
    );
  }
  if (!data) return <LoadingBlock label="Menyiapkan analitik kelas" />;

  const c = data.counts || {};
  const stats = [
    ["Kelas Diampu", c.kelas ?? 0, School, statColors[0]],
    ["Total Siswa", c.siswa ?? 0, Users, statColors[1]],
    ["Tugas Aktif", c.tugasAktif ?? 0, FileText, statColors[2]],
    ["Ujian Mendatang", c.ujianMendatang ?? 0, ClipboardList, statColors[3]],
  ];
  const totalGraded = (data.gradeDistribution || []).reduce((a, g) => a + g.jumlah, 0);

  return (
    <div className="space-y-5">
      {/* Hero */}
      <div className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-primary via-primary to-indigo-600 p-6 text-white shadow-soft">
        <div className="absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/10" />
        <div className="absolute -bottom-10 right-24 h-28 w-28 rounded-full bg-white/5" />
        <div className="relative flex flex-wrap items-end justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 text-sm font-medium text-white/80">
              <Sparkles className="h-4 w-4" />
              {greeting()}, Bapak/Ibu Guru
            </div>
            <h1 className="mt-1 text-2xl font-semibold">{user?.nama}</h1>
            <p className="mt-1 max-w-xl text-sm text-white/80">
              Ringkasan performa kelas, siswa yang perlu perhatian, dan agenda terdekat Anda.
            </p>
          </div>
          <div className="rounded-xl bg-white/15 px-5 py-3 text-center backdrop-blur">
            <div className="text-3xl font-bold leading-none">
              {c.rataNilai !== null && c.rataNilai !== undefined ? c.rataNilai : "-"}
            </div>
            <div className="mt-1 text-xs text-white/80">Rata-rata Nilai</div>
          </div>
        </div>
      </div>

      {/* Stat tiles */}
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        {stats.map(([label, value, Icon, color]) => (
          <Card key={label}>
            <CardContent className="flex items-center gap-4 pt-5">
              <div className={cn("flex h-12 w-12 shrink-0 items-center justify-center rounded-xl", color.bg)}>
                <Icon className={cn("h-5 w-5", color.icon)} />
              </div>
              <div>
                <div className="text-2xl font-bold">{value}</div>
                <div className="text-sm text-muted-foreground">{label}</div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        {/* Distribusi nilai */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BarChart3 className="h-4 w-4 text-primary" />
              Distribusi Capaian Nilai
            </CardTitle>
            <CardDescription>
              Sebaran {totalGraded} nilai tugas siswa berdasarkan kategori capaian.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <DistributionChart items={data.gradeDistribution} total={totalGraded} />
          </CardContent>
        </Card>

        {/* Tren */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-primary" />
              Tren Rata-rata
            </CardTitle>
            <CardDescription>6 bulan terakhir</CardDescription>
          </CardHeader>
          <CardContent>
            <TrendSparkline points={data.trend} />
          </CardContent>
        </Card>
      </div>

      {/* Per kelas */}
      <Card>
        <CardHeader>
          <CardTitle>Ringkasan per Kelas</CardTitle>
          <CardDescription>Rata-rata nilai dan tingkat pengumpulan tugas tiap kelas mapel.</CardDescription>
        </CardHeader>
        <CardContent>
          {(data.perClass || []).length ? (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b text-left text-xs uppercase text-muted-foreground">
                    <th className="pb-2 pr-3 font-medium">Kelas</th>
                    <th className="pb-2 pr-3 font-medium">Mapel</th>
                    <th className="pb-2 pr-3 text-center font-medium">Siswa</th>
                    <th className="pb-2 pr-3 text-center font-medium">Tugas</th>
                    <th className="pb-2 pr-3 text-center font-medium">Rata Nilai</th>
                    <th className="pb-2 font-medium">Pengumpulan</th>
                  </tr>
                </thead>
                <tbody>
                  {data.perClass.map((row) => {
                    const kapasitas = row.totalSiswa * row.totalTugas;
                    const rate = kapasitas ? Math.round((row.totalSubmit / kapasitas) * 100) : 0;
                    return (
                      <tr key={row.classSubjectId} className="border-b last:border-0">
                        <td className="py-2.5 pr-3 font-medium">{row.namaKelas}</td>
                        <td className="py-2.5 pr-3 text-muted-foreground">{row.judulMapel}</td>
                        <td className="py-2.5 pr-3 text-center">{row.totalSiswa}</td>
                        <td className="py-2.5 pr-3 text-center">{row.totalTugas}</td>
                        <td className="py-2.5 pr-3 text-center">
                          <span className={cn("font-semibold", (row.rataNilai ?? 100) < 75 ? "text-rose-600" : "text-teal-600")}>
                            {row.rataNilai ?? "-"}
                          </span>
                        </td>
                        <td className="py-2.5">
                          <div className="flex items-center gap-2">
                            <div className="h-2 w-24 overflow-hidden rounded-full bg-muted">
                              <div className="h-full rounded-full bg-primary" style={{ width: `${rate}%` }} />
                            </div>
                            <span className="text-xs text-muted-foreground">{rate}%</span>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">Belum ada kelas yang diampu.</p>
          )}
        </CardContent>
      </Card>

      <div className="grid gap-4 lg:grid-cols-2">
        {/* Siswa berisiko */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-4 w-4 text-amber-500" />
              Siswa Perlu Perhatian
            </CardTitle>
            <CardDescription>Rata-rata nilai di bawah 75.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            {(data.atRisk || []).length ? (
              data.atRisk.map((s) => (
                <div key={s.id} className="flex items-center justify-between rounded-lg border bg-muted/20 p-3">
                  <div>
                    <div className="text-sm font-medium">{s.nama}</div>
                    <div className="text-xs text-muted-foreground">
                      {s.namaKelas} · {s.totalDinilai} nilai
                    </div>
                  </div>
                  <span className="rounded-full bg-rose-50 px-2.5 py-1 text-sm font-bold text-rose-600">
                    {s.rataNilai}
                  </span>
                </div>
              ))
            ) : (
              <p className="text-sm text-muted-foreground">🎉 Tidak ada siswa berisiko saat ini.</p>
            )}
          </CardContent>
        </Card>

        {/* Perlu dinilai */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Edit3 className="h-4 w-4 text-primary" />
              Tugas Menunggu Penilaian
            </CardTitle>
            <CardDescription>Pengumpulan terbaru yang belum dinilai.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            {(data.needGrading || []).length ? (
              data.needGrading.map((s) => (
                <div key={s.id} className="rounded-lg border bg-muted/20 p-3">
                  <div className="text-sm font-medium">{s.siswa}</div>
                  <div className="text-xs text-muted-foreground">
                    {s.tugas} · {s.namaKelas} · {formatDateTime(s.submittedAt)}
                  </div>
                </div>
              ))
            ) : (
              <p className="text-sm text-muted-foreground">Semua pengumpulan sudah dinilai.</p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Agenda terdekat */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Clock className="h-4 w-4 text-primary" />
            Agenda Terdekat
          </CardTitle>
          <CardDescription>Deadline tugas dan jadwal ujian yang akan datang.</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-2">
              <div className="text-xs font-semibold uppercase text-muted-foreground">Tugas</div>
              {(data.upcomingAssignments || []).length ? (
                data.upcomingAssignments.map((a) => (
                  <div key={a.id} className="rounded-lg border-l-4 border-blue-400 bg-muted/20 p-3">
                    <div className="text-sm font-medium">{a.judul}</div>
                    <div className="text-xs text-muted-foreground">
                      {a.namaKelas} · {a.judulMapel} · {formatDateTime(a.deadline)}
                    </div>
                    <div className="mt-1 text-xs text-muted-foreground">
                      Terkumpul {a.totalSubmit}/{a.totalSiswa}
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">Tidak ada tugas mendatang.</p>
              )}
            </div>
            <div className="space-y-2">
              <div className="text-xs font-semibold uppercase text-muted-foreground">Ujian</div>
              {(data.upcomingExams || []).length ? (
                data.upcomingExams.map((e) => (
                  <div key={e.id} className="rounded-lg border-l-4 border-violet-400 bg-muted/20 p-3">
                    <div className="text-sm font-medium">{e.judul}</div>
                    <div className="text-xs text-muted-foreground">
                      {e.tipeUjian} · {e.namaKelas} · {formatDate(e.tanggalUjian)}
                      {e.jamMulai ? ` · ${String(e.jamMulai).slice(0, 5)}` : ""}
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-muted-foreground">Tidak ada ujian mendatang.</p>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

function DistributionChart({ items = [], total = 0 }) {
  if (!total) {
    return <p className="py-6 text-center text-sm text-muted-foreground">Belum ada nilai yang tercatat.</p>;
  }
  const max = Math.max(...items.map((i) => i.jumlah), 1);
  return (
    <div className="space-y-3">
      {items.map((item) => {
        const tone = gradeChartTones[item.kategori] || { bar: "bg-primary", text: "text-primary" };
        const pct = Math.round((item.jumlah / total) * 100);
        return (
          <div key={item.kategori}>
            <div className="mb-1 flex items-center justify-between text-sm">
              <span className="font-medium">{item.kategori}</span>
              <span className={cn("font-semibold", tone.text)}>
                {item.jumlah} <span className="text-xs text-muted-foreground">({pct}%)</span>
              </span>
            </div>
            <div className="h-3 overflow-hidden rounded-full bg-muted">
              <div
                className={cn("h-full rounded-full transition-all", tone.bar)}
                style={{ width: `${Math.max((item.jumlah / max) * 100, item.jumlah ? 6 : 0)}%` }}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

function TrendSparkline({ points = [] }) {
  const valid = points.filter((p) => p.rataNilai !== null && p.rataNilai !== undefined);
  if (valid.length < 2) {
    return (
      <div className="flex h-32 items-center justify-center text-center text-sm text-muted-foreground">
        Data tren belum cukup.
      </div>
    );
  }
  const w = 260;
  const h = 96;
  const values = valid.map((p) => Number(p.rataNilai));
  const min = Math.min(...values) - 5;
  const max = Math.max(...values) + 5;
  const span = max - min || 1;
  const stepX = w / (valid.length - 1);
  const coords = values.map((v, i) => [i * stepX, h - ((v - min) / span) * h]);
  const line = coords.map(([x, y], i) => `${i ? "L" : "M"}${x.toFixed(1)},${y.toFixed(1)}`).join(" ");
  const area = `${line} L${w},${h} L0,${h} Z`;
  return (
    <div>
      <svg viewBox={`0 0 ${w} ${h}`} className="h-24 w-full" preserveAspectRatio="none">
        <path d={area} fill="hsl(var(--primary))" opacity="0.12" />
        <path d={line} fill="none" stroke="hsl(var(--primary))" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
        {coords.map(([x, y], i) => (
          <circle key={i} cx={x} cy={y} r="3" fill="hsl(var(--primary))" />
        ))}
      </svg>
      <div className="mt-2 flex justify-between text-[10px] text-muted-foreground">
        {valid.map((p) => (
          <span key={p.bulan}>{String(p.bulan).slice(5)}</span>
        ))}
      </div>
    </div>
  );
}

// ==========================================================================
// Notifikasi (lonceng di header)
// ==========================================================================
function NotificationBell() {
  const [open, setOpen] = useState(false);
  const [items, setItems] = useState([]);
  const [unread, setUnread] = useState(0);
  const navigate = useNavigate();
  const boxRef = useRef(null);

  const load = useCallback(() => {
    apiFetch("/notifications")
      .then((res) => {
        setItems(res.data || []);
        setUnread(res.unread || 0);
      })
      .catch(() => {});
  }, []);

  useEffect(() => {
    load();
    const timer = setInterval(load, 30000);
    return () => clearInterval(timer);
  }, [load]);

  useEffect(() => {
    if (!open) return undefined;
    const onClick = (e) => {
      if (boxRef.current && !boxRef.current.contains(e.target)) setOpen(false);
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, [open]);

  const markAll = async () => {
    await apiFetch("/notifications/read", { method: "POST", body: {} }).catch(() => {});
    setUnread(0);
    setItems((prev) => prev.map((n) => ({ ...n, isRead: 1 })));
  };

  const openItem = async (n) => {
    if (!n.isRead) {
      await apiFetch("/notifications/read", { method: "POST", body: { ids: [n.id] } }).catch(() => {});
      setUnread((u) => Math.max(0, u - 1));
      setItems((prev) => prev.map((x) => (x.id === n.id ? { ...x, isRead: 1 } : x)));
    }
    setOpen(false);
    if (n.link) navigate(n.link);
  };

  return (
    <div className="relative" ref={boxRef}>
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="relative flex h-9 w-9 items-center justify-center rounded-lg border bg-background text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
        aria-label="Notifikasi"
      >
        <Bell className="h-5 w-5" />
        {unread > 0 ? (
          <span className="absolute -right-1 -top-1 flex h-5 min-w-5 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-bold text-white">
            {unread > 9 ? "9+" : unread}
          </span>
        ) : null}
      </button>
      {open ? (
        <div className="absolute right-0 z-50 mt-2 w-80 overflow-hidden rounded-xl border bg-card shadow-lg">
          <div className="flex items-center justify-between border-b px-4 py-3">
            <span className="text-sm font-semibold">Notifikasi</span>
            {unread > 0 ? (
              <button onClick={markAll} className="flex items-center gap-1 text-xs text-primary hover:underline">
                <CheckCheck className="h-3.5 w-3.5" />
                Tandai dibaca
              </button>
            ) : null}
          </div>
          <div className="max-h-96 overflow-y-auto app-scrollbar">
            {items.length ? (
              items.map((n) => (
                <button
                  key={n.id}
                  onClick={() => openItem(n)}
                  className={cn(
                    "flex w-full gap-3 border-b px-4 py-3 text-left transition-colors hover:bg-muted/50 last:border-0",
                    n.isRead ? "" : "bg-primary/5",
                  )}
                >
                  <div className={cn("mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full", n.isRead ? "bg-muted" : "bg-primary/15")}>
                    <Megaphone className={cn("h-4 w-4", n.isRead ? "text-muted-foreground" : "text-primary")} />
                  </div>
                  <div className="min-w-0">
                    <div className="truncate text-sm font-medium">{n.judul}</div>
                    {n.isi ? <div className="truncate text-xs text-muted-foreground">{n.isi}</div> : null}
                    <div className="mt-0.5 text-[10px] text-muted-foreground">{formatDateTime(n.createdAt)}</div>
                  </div>
                  {!n.isRead ? <span className="mt-1 h-2 w-2 shrink-0 rounded-full bg-primary" /> : null}
                </button>
              ))
            ) : (
              <div className="px-4 py-10 text-center text-sm text-muted-foreground">Belum ada notifikasi.</div>
            )}
          </div>
        </div>
      ) : null}
    </div>
  );
}

// ==========================================================================
// Pengumuman
// ==========================================================================
const priorityTones = {
  Normal: "bg-slate-100 text-slate-600",
  Penting: "bg-amber-100 text-amber-700",
  Mendesak: "bg-rose-100 text-rose-700",
};

function AnnouncementsPage({ role }) {
  const isGuru = role === "guru";
  const { options } = useOptions();
  const { show, node } = useToast();
  const [items, setItems] = useState(null);
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState({
    classSubjectId: "",
    judul: "",
    isi: "",
    prioritas: "Normal",
    pinned: false,
  });

  const load = useCallback(() => {
    apiFetch("/announcements").then((res) => setItems(res.data || [])).catch(() => setItems([]));
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const submit = async () => {
    if (!form.classSubjectId || !form.judul.trim() || !form.isi.trim()) {
      show("Kelas, judul, dan isi wajib diisi", "error");
      return;
    }
    setSaving(true);
    try {
      const res = await apiFetch("/announcements", {
        method: "POST",
        body: { ...form, pinned: form.pinned ? 1 : 0 },
      });
      show(`Pengumuman terkirim ke ${res.penerima} siswa`);
      setOpen(false);
      setForm({ classSubjectId: "", judul: "", isi: "", prioritas: "Normal", pinned: false });
      load();
    } catch (e) {
      show(e.message, "error");
    } finally {
      setSaving(false);
    }
  };

  const remove = async (id) => {
    if (!window.confirm("Hapus pengumuman ini?")) return;
    try {
      await apiFetch(`/announcements/${id}`, { method: "DELETE" });
      show("Pengumuman dihapus");
      load();
    } catch (e) {
      show(e.message, "error");
    }
  };

  const classOptions = (options.classSubjects || []).map((cs) => ({
    value: String(cs.id),
    label: cs.label || `${cs.namaKelas} - ${cs.judulMapel}`,
  }));

  return (
    <div>
      {node}
      <PageHeader
        title="Pengumuman"
        description={
          isGuru
            ? "Bagikan informasi ke kelas Anda. Siswa akan menerima notifikasi otomatis."
            : "Informasi terbaru dari guru pengampu kelas Anda."
        }
        action={
          isGuru ? (
            <Button onClick={() => setOpen(true)}>
              <Plus className="h-4 w-4" />
              Buat Pengumuman
            </Button>
          ) : null
        }
      />

      {items === null ? (
        <LoadingBlock />
      ) : items.length === 0 ? (
        <div className="rounded-xl border border-dashed p-12 text-center">
          <Megaphone className="mx-auto h-10 w-10 text-muted-foreground/50" />
          <p className="mt-3 text-sm text-muted-foreground">Belum ada pengumuman.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {items.map((a) => (
            <Card key={a.id} className={cn(a.pinned ? "border-primary/40" : "")}>
              <CardContent className="pt-5">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <div className="flex flex-wrap items-center gap-2">
                      {a.pinned ? <Pin className="h-4 w-4 text-primary" /> : null}
                      <h3 className="font-semibold">{a.judul}</h3>
                      <span className={cn("rounded-full px-2 py-0.5 text-[11px] font-medium", priorityTones[a.prioritas] || priorityTones.Normal)}>
                        {a.prioritas}
                      </span>
                    </div>
                    <div className="mt-1 text-xs text-muted-foreground">
                      {a.namaKelas} · {a.judulMapel}
                      {a.pengirim ? ` · ${a.pengirim}` : ""} · {formatDateTime(a.createdAt)}
                    </div>
                    <p className="mt-3 whitespace-pre-wrap text-sm text-foreground/90">{a.isi}</p>
                  </div>
                  {isGuru ? (
                    <Button variant="ghost" size="icon" onClick={() => remove(a.id)} aria-label="Hapus">
                      <Trash2 className="h-4 w-4 text-rose-500" />
                    </Button>
                  ) : null}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <Dialog
        open={open}
        title="Buat Pengumuman"
        onClose={() => setOpen(false)}
        footer={
          <>
            <Button variant="outline" onClick={() => setOpen(false)}>
              Batal
            </Button>
            <Button onClick={submit} disabled={saving}>
              <Megaphone className="h-4 w-4" />
              {saving ? "Mengirim..." : "Kirim"}
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <Field label="Kelas & Mapel">
            <SearchableSelect
              value={form.classSubjectId}
              onChange={(v) => setForm((f) => ({ ...f, classSubjectId: v }))}
              options={classOptions}
              placeholder="Pilih kelas mapel..."
            />
          </Field>
          <Field label="Judul">
            <Input
              value={form.judul}
              onChange={(e) => setForm((f) => ({ ...f, judul: e.target.value }))}
              placeholder="Contoh: Perubahan jadwal ulangan"
            />
          </Field>
          <Field label="Isi Pengumuman">
            <Textarea
              rows={5}
              value={form.isi}
              onChange={(e) => setForm((f) => ({ ...f, isi: e.target.value }))}
              placeholder="Tulis informasi lengkap di sini..."
            />
          </Field>
          <div className="grid gap-4 md:grid-cols-2">
            <Field label="Prioritas">
              <Select
                value={form.prioritas}
                onChange={(e) => setForm((f) => ({ ...f, prioritas: e.target.value }))}
              >
                <option value="Normal">Normal</option>
                <option value="Penting">Penting</option>
                <option value="Mendesak">Mendesak</option>
              </Select>
            </Field>
            <Field label="Sematkan">
              <label className="flex h-10 items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={form.pinned}
                  onChange={(e) => setForm((f) => ({ ...f, pinned: e.target.checked }))}
                  className="h-4 w-4 rounded border-input"
                />
                Tampilkan di paling atas
              </label>
            </Field>
          </div>
        </div>
      </Dialog>
    </div>
  );
}

function FormDialog({
  open,
  title,
  fields,
  value,
  options,
  onChange,
  onClose,
  onSubmit,
  loading,
  submitLabel = "Simpan",
  extra,
}) {
  return (
    <Dialog
      open={open}
      title={title}
      onClose={onClose}
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Batal
          </Button>
          <Button onClick={onSubmit} disabled={loading}>
            <Save className="h-4 w-4" />
            {loading ? "Menyimpan..." : submitLabel}
          </Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        {fields.map((field) => (
          <Field key={field.name} label={field.label} hint={field.hint}>
            <FieldInput
              field={field}
              value={value[field.name] ?? ""}
              formValue={value}
              options={options}
              onChange={(nextValue) =>
                onChange({ ...value, [field.name]: nextValue })
              }
            />
          </Field>
        ))}
      </div>
      {extra}
    </Dialog>
  );
}

function FieldInput({ field, value, formValue, options, onChange }) {
  if (field.type === "textarea") {
    return (
      <Textarea
        value={value}
        onChange={(event) => onChange(event.target.value)}
      />
    );
  }
  if (field.type === "select") {
    const items =
      typeof field.options === "function"
        ? field.options(options, formValue)
        : field.options || [];
    return (
      <SearchableSelect
        value={String(value ?? "")}
        onChange={onChange}
        options={items.map((item) => ({
          value: String(item.value),
          label: item.label,
        }))}
      />
    );
  }
  if (field.type === "multi") {
    const items =
      typeof field.options === "function"
        ? field.options(options, formValue)
        : field.options || [];
    const selected = Array.isArray(value) ? value.map(Number) : [];
    return (
      <div className="max-h-40 space-y-2 overflow-y-auto rounded-lg border p-3 app-scrollbar">
        {items.map((item) => (
          <label key={item.value} className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={selected.includes(Number(item.value))}
              onChange={(event) => {
                const next = event.target.checked
                  ? [...selected, Number(item.value)]
                  : selected.filter((id) => id !== Number(item.value));
                onChange(next);
              }}
            />
            {item.label}
          </label>
        ))}
      </div>
    );
  }
  return (
    <Input
      type={field.type || "text"}
      value={value}
      onChange={(event) => onChange(event.target.value)}
      placeholder={field.placeholder}
    />
  );
}

const optionMappers = {
  years: (options) =>
    options.academicYears.map((item) => ({
      value: item.id,
      label: item.tahunAjaran,
    })),
  classes: (options) =>
    options.classes.map((item) => ({ value: item.id, label: item.namaKelas })),
  teachers: (options) =>
    options.teachers.map((item) => ({ value: item.id, label: item.nama })),
  subjects: (options) =>
    options.subjects.map((item) => ({
      value: item.id,
      label: `${item.judulMapel} (${item.jenjang} ${item.jurusan})`,
    })),
  classSubjects: (options) =>
    options.classSubjects.map((item) => ({
      value: item.id,
      label: `${item.namaKelas} - ${item.judulMapel} (${item.guruPengampu})`,
    })),
};

const resourceConfigs = {
  teachers: {
    title: "Data Guru",
    description: "Kelola guru, NIP/NUPTK, kontak, dan mata pelajaran yang diampu.",
    endpoint: "teachers",
    createLabel: "Tambah Guru",
    fields: [
      { name: "nama", label: "Nama Guru" },
      { name: "nipNuptk", label: "NIP/NUPTK" },
      { name: "email", label: "Email", type: "email" },
      { name: "noTelp", label: "Nomor Telepon" },
      { name: "alamat", label: "Alamat", type: "textarea" },
      {
        name: "subjectIds",
        label: "Mata Pelajaran",
        type: "multi",
        options: optionMappers.subjects,
      },
    ],
    columns: [
      ["nama", "Nama"],
      ["nipNuptk", "NIP/NUPTK"],
      ["email", "Email"],
      ["mapel", "Mapel"],
      ["noTelp", "Telepon"],
    ],
  },
  students: {
    title: "Data Siswa",
    description: "Kelola biodata siswa, kelas aktif, dan informasi wali murid.",
    endpoint: "students",
    createLabel: "Tambah Siswa",
    importable: true,
    fields: [
      { name: "nama", label: "Nama Siswa" },
      { name: "nis", label: "NIS" },
      { name: "nisn", label: "NISN" },
      { name: "email", label: "Email", type: "email" },
      { name: "noTelp", label: "Nomor Telepon" },
      {
        name: "kelasId",
        label: "Kelas",
        type: "select",
        options: optionMappers.classes,
      },
      {
        name: "jenisKelamin",
        label: "Jenis Kelamin",
        type: "select",
        options: [
          { value: "Laki-laki", label: "Laki-laki" },
          { value: "Perempuan", label: "Perempuan" },
        ],
      },
      { name: "agama", label: "Agama" },
      { name: "alamat", label: "Alamat", type: "textarea" },
      { name: "namaWaliMurid", label: "Nama Wali" },
      { name: "statusWaliMurid", label: "Status Wali" },
      { name: "noTelpWaliMurid", label: "Telepon Wali" },
      { name: "alamatWaliMurid", label: "Alamat Wali", type: "textarea" },
    ],
    columns: [
      ["nama", "Nama"],
      ["nis", "NIS"],
      ["nisn", "NISN"],
      ["namaKelas", "Kelas"],
      ["email", "Email"],
    ],
  },
  classes: {
    title: "Kelas",
    description: "Kelola kelas, jurusan, ruang, dan wali kelas per tahun ajaran.",
    endpoint: "classes",
    createLabel: "Tambah Kelas",
    fields: [
      {
        name: "academicYearId",
        label: "Tahun Ajaran",
        type: "select",
        options: optionMappers.years,
      },
      {
        name: "jenjang",
        label: "Jenjang",
        type: "select",
        options: [
          { value: "X", label: "X" },
          { value: "XI", label: "XI" },
          { value: "XII", label: "XII" },
        ],
      },
      { name: "jurusan", label: "Jurusan" },
      { name: "namaKelas", label: "Nama Kelas" },
      { name: "ruangKelas", label: "Ruang Kelas" },
      {
        name: "waliKelasUserId",
        label: "Wali Kelas",
        type: "select",
        options: optionMappers.teachers,
      },
    ],
    columns: [
      ["namaKelas", "Kelas"],
      ["tahunAjaran", "Tahun Ajaran"],
      ["jenjang", "Jenjang"],
      ["jurusan", "Jurusan"],
      ["waliKelas", "Wali Kelas"],
      ["jumlahSiswa", "Siswa"],
    ],
  },
  subjects: {
    title: "Mata Pelajaran",
    description: "Kelola mapel, cakupan jenjang/jurusan, dan koordinator mapel.",
    endpoint: "subjects",
    createLabel: "Tambah Mapel",
    fields: [
      { name: "judulMapel", label: "Judul Mapel" },
      {
        name: "jenjang",
        label: "Jenjang",
        type: "select",
        options: [
          { value: "X", label: "X" },
          { value: "XI", label: "XI" },
          { value: "XII", label: "XII" },
        ],
      },
      { name: "jurusan", label: "Jurusan" },
      {
        name: "koordinatorUserId",
        label: "Koordinator",
        type: "select",
        options: optionMappers.teachers,
      },
    ],
    columns: [
      ["judulMapel", "Mapel"],
      ["jenjang", "Jenjang"],
      ["jurusan", "Jurusan"],
      ["koordinator", "Koordinator"],
    ],
  },
  years: {
    title: "Tahun Ajaran",
    description: "Kelola tahun ajaran dan semester aktif.",
    endpoint: "academic-years",
    createLabel: "Tambah Tahun Ajaran",
    fields: [
      {
        name: "tahunAjaran",
        label: "Tahun Ajaran",
        placeholder: "2026/2027",
      },
      {
        name: "tanggalMulaiSmtGanjil",
        label: "Mulai Semester Ganjil",
        type: "date",
      },
      {
        name: "tanggalMulaiSmtGenap",
        label: "Mulai Semester Genap",
        type: "date",
      },
      {
        name: "isActive",
        label: "Aktif",
        type: "select",
        options: [
          { value: 1, label: "Ya" },
          { value: 0, label: "Tidak" },
        ],
      },
    ],
    columns: [
      ["tahunAjaran", "Tahun Ajaran"],
      ["isActive", "Status"],
      ["semester", "Semester"],
    ],
    render: {
      isActive: (row) => (
        <Badge tone={row.isActive ? "success" : "muted"}>
          {row.isActive ? "Aktif" : "Nonaktif"}
        </Badge>
      ),
      semester: (row) =>
        (row.semester || []).map((item) => item.judulSemester).join(", "),
    },
  },
  events: {
    title: "Jadwal Akademik",
    description: "Kelola agenda akademik sekolah berdasarkan tahun ajaran.",
    readOnlyDescription:
      "Agenda akademik sekolah berdasarkan tahun ajaran (hanya lihat).",
    endpoint: "academic-events",
    createLabel: "Tambah Kegiatan",
    fields: [
      {
        name: "academicYearId",
        label: "Tahun Ajaran",
        type: "select",
        options: optionMappers.years,
      },
      { name: "namaKegiatan", label: "Nama Kegiatan" },
      { name: "tanggalMulai", label: "Tanggal Mulai", type: "date" },
      { name: "tanggalSelesai", label: "Tanggal Selesai", type: "date" },
    ],
    columns: [
      ["namaKegiatan", "Kegiatan"],
      ["tahunAjaran", "Tahun Ajaran"],
      ["tanggalMulai", "Mulai"],
      ["tanggalSelesai", "Selesai"],
    ],
    render: {
      tanggalMulai: (row) => formatDate(row.tanggalMulai),
      tanggalSelesai: (row) => formatDate(row.tanggalSelesai),
    },
  },
  schedules: {
    title: "Jadwal Pelajaran",
    description: "Kelola jadwal mapel, guru pengampu, hari, waktu, dan ruang.",
    endpoint: "lesson-schedules",
    createLabel: "Tambah Jadwal",
    fields: [
      {
        name: "classSubjectId",
        label: "Kelas Mapel",
        type: "select",
        options: optionMappers.classSubjects,
      },
      {
        name: "hari",
        label: "Hari",
        type: "select",
        options: ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"].map(
          (day) => ({ value: day, label: day }),
        ),
      },
      { name: "waktu", label: "Waktu", placeholder: "07:00 - 08:30" },
      { name: "ruangKelas", label: "Ruang Kelas" },
    ],
    columns: [
      ["hari", "Hari"],
      ["waktu", "Waktu"],
      ["namaKelas", "Kelas"],
      ["judulMapel", "Mapel"],
      ["guruPengampu", "Guru"],
      ["ruangKelas", "Ruang"],
    ],
  },
  gradeRanges: {
    title: "Range Nilai Kategori",
    description: "Kelola kategori capaian nilai untuk laporan akademik.",
    endpoint: "grade-ranges",
    createLabel: "Tambah Kategori",
    fields: [
      { name: "kategori", label: "Kategori" },
      { name: "minNilai", label: "Nilai Minimum", type: "number" },
      { name: "maxNilai", label: "Nilai Maksimum", type: "number" },
      { name: "deskripsi", label: "Deskripsi", type: "textarea" },
    ],
    columns: [
      ["kategori", "Kategori"],
      ["minNilai", "Minimum"],
      ["maxNilai", "Maksimum"],
      ["deskripsi", "Deskripsi"],
    ],
  },
};

function ResourcePage({ config, readOnly = false }) {
  const { options, refreshOptions } = useOptions();
  const { show, node } = useToast();
  const [rows, setRows] = useState([]);
  const [meta, setMeta] = useState({ total: 0, totalPage: 1, page: 1 });
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({});
  const [dialogOpen, setDialogOpen] = useState(false);
  const fileRef = useRef(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch(
        withQuery(`/${config.endpoint}`, { search, page, limit: pageSize }),
      );
      setRows(data.data || []);
      setMeta(data);
    } catch (error) {
      show(error.message, "error");
    } finally {
      setLoading(false);
    }
  }, [config.endpoint, search, page, pageSize]);

  useEffect(() => {
    load();
  }, [load]);

  const openForm = (row = null) => {
    setEditing(row);
    setForm(row || {});
    setDialogOpen(true);
  };

  const closeForm = () => {
    setEditing(null);
    setForm({});
    setDialogOpen(false);
  };

  const save = async () => {
    setSaving(true);
    try {
      const method = editing ? "PUT" : "POST";
      const path = editing
        ? `/${config.endpoint}/${editing.id}`
        : `/${config.endpoint}`;
      await apiFetch(path, { method, body: form });
      show("Data berhasil disimpan");
      closeForm();
      await Promise.all([load(), refreshOptions()]);
    } catch (error) {
      show(error.message, "error");
    } finally {
      setSaving(false);
    }
  };

  const remove = async (row) => {
    if (!confirm("Hapus data ini?")) return;
    try {
      await apiFetch(`/${config.endpoint}/${row.id}`, { method: "DELETE" });
      show("Data berhasil dihapus");
      await Promise.all([load(), refreshOptions()]);
    } catch (error) {
      show(error.message, "error");
    }
  };

  const importStudents = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    try {
      if (!file.name.toLowerCase().endsWith(".csv")) {
        throw new Error(
          "Impor siswa memakai CSV dengan header nis, nisn, nama, email, kelas.",
        );
      }
      const rawRows = parseCsv(await file.text());
      const rows = rawRows.map((row) => ({
        nis: row.nis || row.NIS,
        nisn: row.nisn || row.NISN,
        nama: row.nama || row.Nama,
        email: row.email || row.Email,
        noTelp: row.no_telp || row.noTelp || row.Telepon,
        namaKelas: row.nama_kelas || row.kelas || row.Kelas,
        jenisKelamin: row.jenis_kelamin || row.JK,
        agama: row.agama || row.Agama,
        alamat: row.alamat || row.Alamat,
      }));
      const result = await apiFetch("/students/bulk", {
        method: "POST",
        body: { rows },
      });
      show(`${result.inserted} siswa berhasil diimpor`);
      await load();
    } catch (error) {
      show(error.message, "error");
    } finally {
      event.target.value = "";
    }
  };

  const baseColumns = config.columns.map(([key, header]) => ({
    key,
    header,
    render: config.render?.[key],
  }));

  const columns = readOnly
    ? baseColumns
    : [
        ...baseColumns,
        {
          key: "actions",
          header: "",
          render: (row) => (
            <div className="flex justify-end gap-2">
              <Button variant="outline" size="sm" onClick={() => openForm(row)}>
                <Edit3 className="h-3.5 w-3.5" />
              </Button>
              <Button variant="destructive" size="sm" onClick={() => remove(row)}>
                <Trash2 className="h-3.5 w-3.5" />
              </Button>
            </div>
          ),
        },
      ];

  return (
    <div>
      {node}
      <PageHeader
        title={config.title}
        description={
          readOnly
            ? config.readOnlyDescription || config.description
            : config.description
        }
        action={
          readOnly ? null : (
          <div className="flex flex-wrap gap-2">
            {config.importable ? (
              <>
                <input
                  ref={fileRef}
                  type="file"
                  className="hidden"
                  accept=".csv"
                  onChange={importStudents}
                />
                <Button
                  variant="outline"
                  onClick={() => fileRef.current?.click()}
                >
                  <Upload className="h-4 w-4" />
                  Impor
                </Button>
              </>
            ) : null}
            <Button onClick={() => openForm()}>
              <Plus className="h-4 w-4" />
              {config.createLabel}
            </Button>
          </div>
          )
        }
      />
      <div className="mb-4 flex flex-col gap-3 md:flex-row md:items-center">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            className="pl-9"
            placeholder="Cari data..."
            value={search}
            onChange={(event) => { setSearch(event.target.value); setPage(1); }}
          />
        </div>
        <Button variant="outline" onClick={load}>
          <RefreshCw className="h-4 w-4" />
          Refresh
        </Button>
      </div>
      {loading ? <LoadingBlock /> : <Table columns={columns} rows={rows} />}
      <Pagination
        page={meta.page || page}
        totalPages={meta.totalPage || Math.ceil((meta.total || rows.length) / pageSize) || 1}
        total={meta.total ?? rows.length}
        pageSize={pageSize}
        onPageChange={setPage}
        onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
      />
      <FormDialog
        open={dialogOpen && !readOnly}
        title={editing ? `Ubah ${config.title}` : config.createLabel}
        fields={config.fields}
        value={form}
        options={options}
        onChange={setForm}
        onClose={closeForm}
        onSubmit={save}
        loading={saving}
      />
    </div>
  );
}

function SchedulePage({ mode }) {
  const title = "Jadwal Pelajaran";
  const description =
    mode === "guru"
      ? "Daftar jadwal pelajaran sesuai kelas dan mata pelajaran yang diampu."
      : "Daftar jadwal pelajaran berdasarkan kelas siswa.";
  return (
    <div>
      <PageHeader title={title} description={description} />
      <SimpleData
        endpoint="/lesson-schedules"
        columns={[
          ["hari", "Hari"],
          ["waktu", "Waktu"],
          ["namaKelas", "Kelas"],
          ["judulMapel", "Mata Pelajaran"],
          ["guruPengampu", "Guru"],
          ["ruangKelas", "Ruang"],
        ]}
      />
    </div>
  );
}

function SimpleData({ endpoint, columns }) {
  const [allRows, setAllRows] = useState(null);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);

  useEffect(() => {
    apiFetch(endpoint)
      .then((data) => setAllRows(data.data || []))
      .catch(() => setAllRows([]));
  }, [endpoint]);

  if (!allRows) return <LoadingBlock />;

  const total = allRows.length;
  const totalPages = Math.ceil(total / pageSize) || 1;
  const pageRows = allRows.slice((page - 1) * pageSize, page * pageSize);

  return (
    <div>
      <Table
        columns={columns.map(([key, header]) => ({ key, header }))}
        rows={pageRows}
      />
      <Pagination
        page={page}
        totalPages={totalPages}
        total={total}
        pageSize={pageSize}
        onPageChange={setPage}
        onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
      />
    </div>
  );
}

function ClassesPage({ role }) {
  const [rows, setRows] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    apiFetch("/class-subjects")
      .then((data) => setRows(data.data || []))
      .catch(() => setRows([]));
  }, []);

  if (!rows) return <LoadingBlock />;

  const target =
    role === "siswa" ? "/main/kelasSiswa/detail" : "/main/kelasGuru/detail";

  return (
    <div>
      <PageHeader
        title="Kelas"
        description={
          role === "siswa"
            ? "Daftar kelas dan mata pelajaran yang Anda ikuti."
            : "Daftar kelas dan mata pelajaran yang Anda ampu."
        }
      />
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {rows.map((row) => (
          <Card key={row.id} className="overflow-hidden">
            <CardHeader>
              <div className="flex items-start justify-between gap-3">
                <div>
                  <CardTitle>{row.judulMapel}</CardTitle>
                  <CardDescription>
                    {row.namaKelas} - {row.guruPengampu}
                  </CardDescription>
                </div>
                <Badge>
                  {row.jenjang} {row.jurusan}
                </Badge>
              </div>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-4 gap-2 text-center text-sm">
                <Metric label="Materi" value={row.jumlahMateri} />
                <Metric label="Tugas" value={row.jumlahTugas} />
                <Metric label="Ujian" value={row.jumlahUjian} />
                <Metric label="Latsol" value={row.jumlahLatihanSoal} />
              </div>
              <Button
                className="mt-5 w-full"
                onClick={() => navigate(`${target}/${row.id}`)}
              >
                Buka Kelas
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}

function Metric({ label, value }) {
  return (
    <div className="rounded-lg border bg-muted/30 p-2">
      <div className="text-lg font-semibold">{value || 0}</div>
      <div className="text-xs text-muted-foreground">{label}</div>
    </div>
  );
}

function ClassDetailPage({ role }) {
  const { id } = useParams();
  const { options } = useOptions();
  const [tab, setTab] = useState("materi");
  const classSubject = options.classSubjects.find(
    (item) => Number(item.id) === Number(id),
  );
  const isStudent = role === "siswa";

  const tabs = [
    {
      value: "materi",
      label: "Materi",
      content: (
        <MaterialsPanel classSubjectId={id} isStudent={isStudent} />
      ),
    },
    {
      value: "tugas",
      label: "Tugas",
      content: (
        <AssignmentsPanel classSubjectId={id} isStudent={isStudent} />
      ),
    },
    {
      value: "ujian",
      label: "Ujian",
      content: <ExamsPanel classSubjectId={id} isStudent={isStudent} />,
    },
    ...(isStudent
      ? []
      : [
          {
            value: "siswa",
            label: "Daftar Siswa",
            content: <StudentsPanel classSubjectId={id} />,
          },
          {
            value: "kelompok",
            label: "Kelompok",
            content: <GroupsPanel classSubjectId={id} />,
          },
        ]),
    {
      value: "rubrik",
      label: "Rubrik",
      content: <RubricsPage classSubjectId={id} compact />,
    },
    {
      value: "nilai",
      label: "Nilai",
      content: <GradesPage classSubjectId={id} compact />,
    },
  ];

  return (
    <div>
      <PageHeader
        title={
          classSubject
            ? `${classSubject.namaKelas} - ${classSubject.judulMapel}`
            : "Detail Kelas"
        }
        description={
          classSubject
            ? `Guru pengampu: ${classSubject.guruPengampu}`
            : "Konten pembelajaran kelas."
        }
      />
      <Tabs value={tab} onValueChange={setTab} items={tabs} />
    </div>
  );
}

function FileLinks({ files }) {
  if (!files?.length)
    return (
      <span className="text-sm text-muted-foreground">Tidak ada file</span>
    );
  return (
    <div className="flex flex-wrap gap-2">
      {files.map((file) => (
        <a
          key={file.id || file.fileUrl}
          href={file.fileUrl}
          target="_blank"
          rel="noreferrer"
        >
          <Button variant="outline" size="sm">
            <Download className="h-3.5 w-3.5" />
            {file.fileName}
          </Button>
        </a>
      ))}
    </div>
  );
}

function MaterialsPanel({ classSubjectId, isStudent }) {
  const { show, node } = useToast();
  const [rows, setRows] = useState(null);
  const [form, setForm] = useState(null);
  const [files, setFiles] = useState([]);
  const [commentsFor, setCommentsFor] = useState(null);
  const [comments, setComments] = useState([]);
  const [commentText, setCommentText] = useState("");

  const load = useCallback(async () => {
    const data = await apiFetch(withQuery("/materials", { classSubjectId }));
    setRows(data.data || []);
  }, [classSubjectId]);

  useEffect(() => {
    load().catch(() => setRows([]));
  }, [load]);

  const save = async () => {
    try {
      const body = toFormData({ ...form, classSubjectId }, files);
      await apiFetch(form.id ? `/materials/${form.id}` : "/materials", {
        method: form.id ? "PUT" : "POST",
        body,
      });
      show("Materi berhasil disimpan");
      setForm(null);
      setFiles([]);
      await load();
    } catch (error) {
      show(error.message, "error");
    }
  };

  const remove = async (item) => {
    if (!confirm("Hapus materi?")) return;
    await apiFetch(`/materials/${item.id}`, { method: "DELETE" });
    await load();
  };

  const openComments = async (item) => {
    setCommentsFor(item);
    const data = await apiFetch(`/materials/${item.id}/comments`);
    setComments(data.data || []);
  };

  const sendComment = async () => {
    if (!commentText.trim()) return;
    await apiFetch(`/materials/${commentsFor.id}/comments`, {
      method: "POST",
      body: { komentar: commentText },
    });
    setCommentText("");
    await openComments(commentsFor);
  };

  if (!rows) return <LoadingBlock />;

  const statusOpts = ["Draft", "Visible", "Hidden"].map((v) => ({
    value: v,
    label: v,
  }));

  return (
    <div>
      {node}
      <SectionToolbar
        title="Materi Kelas"
        action={
          !isStudent && (
            <Button onClick={() => setForm({ status: "Draft" })}>
              <Plus className="h-4 w-4" />
              Tambah Materi
            </Button>
          )
        }
      />
      <div className="grid gap-4">
        {rows.map((item) => (
          <Card key={item.id}>
            <CardHeader>
              <div className="flex flex-col justify-between gap-3 md:flex-row">
                <div>
                  <CardTitle>{item.judul}</CardTitle>
                  <CardDescription>
                    {item.lingkupMateri || "Tanpa lingkup materi"} -{" "}
                    {formatDateTime(item.createdAt)}
                  </CardDescription>
                </div>
                <Badge tone={item.status === "Visible" ? "success" : "muted"}>
                  {item.status}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm leading-6">{item.deskripsi}</p>
              <FileLinks files={item.files} />
              <div className="flex flex-wrap gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => openComments(item)}
                >
                  <MessageSquare className="h-3.5 w-3.5" />
                  Komentar ({item.jumlahKomentar || 0})
                </Button>
                {!isStudent ? (
                  <>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setForm(item)}
                    >
                      <Edit3 className="h-3.5 w-3.5" />
                      Ubah
                    </Button>
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => remove(item)}
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                      Hapus
                    </Button>
                  </>
                ) : null}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      <Dialog
        open={Boolean(form)}
        title={form?.id ? "Ubah Materi" : "Tambah Materi"}
        onClose={() => setForm(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setForm(null)}>
              Batal
            </Button>
            <Button onClick={save}>
              <Save className="h-4 w-4" />
              Simpan
            </Button>
          </>
        }
      >
        <div className="grid gap-4 md:grid-cols-2">
          <Field label="Judul">
            <Input
              value={form?.judul || ""}
              onChange={(e) => setForm({ ...form, judul: e.target.value })}
            />
          </Field>
          <Field label="Status">
            <SearchableSelect
              value={form?.status || "Draft"}
              onChange={(v) => setForm({ ...form, status: v })}
              options={statusOpts}
              allowEmpty={false}
            />
          </Field>
          <Field label="Lingkup Materi">
            <RubricScopeSelect
              classSubjectId={classSubjectId}
              value={form?.rubricScopeId || ""}
              onChange={(value) =>
                setForm({ ...form, rubricScopeId: value })
              }
            />
          </Field>
          <Field label="File Materi">
            <Input
              type="file"
              multiple
              onChange={(event) => setFiles(event.target.files)}
            />
          </Field>
          <div className="md:col-span-2">
            <Field label="Deskripsi">
              <Textarea
                value={form?.deskripsi || ""}
                onChange={(e) =>
                  setForm({ ...form, deskripsi: e.target.value })
                }
              />
            </Field>
          </div>
        </div>
      </Dialog>
      <Dialog
        open={Boolean(commentsFor)}
        title={`Komentar - ${commentsFor?.judul || ""}`}
        onClose={() => setCommentsFor(null)}
        footer={
          <>
            <Input
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Tulis komentar..."
            />
            <Button onClick={sendComment}>Kirim</Button>
          </>
        }
      >
        <div className="space-y-3">
          {comments.map((comment) => (
            <div key={comment.komentarId} className="rounded-lg border p-3">
              <div className="flex items-center justify-between">
                <div className="font-medium">{comment.username}</div>
                <Badge tone="muted">{comment.roleUser}</Badge>
              </div>
              <p className="mt-2 text-sm">{comment.komentar}</p>
              <p className="mt-1 text-xs text-muted-foreground">
                {formatDateTime(comment.waktuKomentar)}
              </p>
            </div>
          ))}
        </div>
      </Dialog>
    </div>
  );
}

function SectionToolbar({ title, action }) {
  return (
    <div className="mb-4 flex items-center justify-between gap-3">
      <h2 className="text-lg font-semibold">{title}</h2>
      {action}
    </div>
  );
}

function RubricScopeSelect({ classSubjectId, value, onChange }) {
  const [items, setItems] = useState([]);
  useEffect(() => {
    apiFetch(withQuery("/rubrics", { classSubjectId }))
      .then((data) => setItems(data.data || []))
      .catch(() => setItems([]));
  }, [classSubjectId]);
  return (
    <SearchableSelect
      value={String(value || "")}
      onChange={onChange}
      options={items.map((item) => ({
        value: String(item.lingkupMateriId),
        label: item.lingkupMateri,
      }))}
      placeholder="Pilih lingkup materi..."
    />
  );
}

function ObjectiveSelect({ classSubjectId, value, onChange }) {
  const [items, setItems] = useState([]);
  useEffect(() => {
    apiFetch(withQuery("/rubrics", { classSubjectId }))
      .then((data) =>
        setItems(
          (data.data || []).flatMap((scope) =>
            (scope.tujuanPembelajaran || []).map((tp) => ({
              ...tp,
              label: `${scope.lingkupMateri} - ${tp.deskripsi}`,
            })),
          ),
        ),
      )
      .catch(() => setItems([]));
  }, [classSubjectId]);
  return (
    <SearchableSelect
      value={String(value || "")}
      onChange={onChange}
      options={items.map((item) => ({
        value: String(item.id),
        label: item.label,
      }))}
      placeholder="Pilih tujuan pembelajaran..."
    />
  );
}

function AssignmentsPanel({ classSubjectId, isStudent }) {
  const { show, node } = useToast();
  const [rows, setRows] = useState(null);
  const [form, setForm] = useState(null);
  const [files, setFiles] = useState([]);
  const [submitFor, setSubmitFor] = useState(null);
  const [submissionFiles, setSubmissionFiles] = useState([]);
  const [submissionsFor, setSubmissionsFor] = useState(null);
  const [submissions, setSubmissions] = useState([]);
  const [grade, setGrade] = useState({});

  const load = useCallback(async () => {
    const data = await apiFetch(
      withQuery("/assignments", { classSubjectId }),
    );
    setRows(data.data || []);
  }, [classSubjectId]);

  useEffect(() => {
    load().catch(() => setRows([]));
  }, [load]);

  const save = async () => {
    try {
      await apiFetch(
        form.id ? `/assignments/${form.id}` : "/assignments",
        {
          method: form.id ? "PUT" : "POST",
          body: toFormData({ ...form, classSubjectId }, files),
        },
      );
      show("Tugas berhasil disimpan");
      setForm(null);
      setFiles([]);
      await load();
    } catch (error) {
      show(error.message, "error");
    }
  };

  const submitAssignment = async () => {
    try {
      await apiFetch(`/assignments/${submitFor.id}/submissions`, {
        method: "POST",
        body: toFormData({}, submissionFiles),
      });
      show("Pengumpulan tugas berhasil dikirim");
      setSubmitFor(null);
      await load();
    } catch (error) {
      show(error.message, "error");
    }
  };

  const loadSubmissions = async (item) => {
    setSubmissionsFor(item);
    const data = await apiFetch(`/assignments/${item.id}/submissions`);
    setSubmissions(data.data || []);
  };

  const saveGrade = async (submissionId) => {
    await apiFetch(`/submissions/${submissionId}/grade`, {
      method: "PUT",
      body: grade[submissionId],
    });
    show("Nilai tugas berhasil disimpan");
    await loadSubmissions(submissionsFor);
  };

  if (!rows) return <LoadingBlock />;

  const statusOpts = ["Draft", "Visible", "Hidden"].map((v) => ({
    value: v,
    label: v,
  }));

  return (
    <div>
      {node}
      <SectionToolbar
        title="Tugas Kelas"
        action={
          !isStudent && (
            <Button onClick={() => setForm({ status: "Draft" })}>
              <Plus className="h-4 w-4" />
              Tambah Tugas
            </Button>
          )
        }
      />
      <div className="grid gap-4">
        {rows.map((item) => (
          <Card key={item.id}>
            <CardHeader>
              <div className="flex flex-col justify-between gap-3 md:flex-row">
                <div>
                  <CardTitle>{item.judul}</CardTitle>
                  <CardDescription>
                    Deadline {formatDateTime(item.deadline)} -{" "}
                    {item.tujuanPembelajaran || "TP belum dipilih"}
                  </CardDescription>
                </div>
                <Badge tone={item.status === "Visible" ? "success" : "muted"}>
                  {item.status}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm leading-6">{item.deskripsi}</p>
              <FileLinks files={item.files} />
              {isStudent ? (
                <div className="flex flex-wrap items-center gap-2">
                  <Badge
                    tone={item.pengumpulanId ? "success" : "warning"}
                  >
                    {item.pengumpulanId
                      ? item.statusPengumpulan
                      : "Belum mengumpulkan"}
                  </Badge>
                  {item.nilai ? <Badge>Nilai {item.nilai}</Badge> : null}
                  <Button size="sm" onClick={() => setSubmitFor(item)}>
                    <Upload className="h-3.5 w-3.5" />
                    {item.pengumpulanId ? "Ubah Pengumpulan" : "Kumpulkan"}
                  </Button>
                </div>
              ) : (
                <div className="flex flex-wrap gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => loadSubmissions(item)}
                  >
                    Pengumpulan ({item.jumlahPengumpulan || 0})
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setForm(item)}
                  >
                    <Edit3 className="h-3.5 w-3.5" />
                    Ubah
                  </Button>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={async () => {
                      if (confirm("Hapus tugas?")) {
                        await apiFetch(`/assignments/${item.id}`, {
                          method: "DELETE",
                        });
                        await load();
                      }
                    }}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    Hapus
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
      <Dialog
        open={Boolean(form)}
        title={form?.id ? "Ubah Tugas" : "Tambah Tugas"}
        onClose={() => setForm(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setForm(null)}>
              Batal
            </Button>
            <Button onClick={save}>Simpan</Button>
          </>
        }
      >
        <div className="grid gap-4 md:grid-cols-2">
          <Field label="Judul">
            <Input
              value={form?.judul || ""}
              onChange={(e) => setForm({ ...form, judul: e.target.value })}
            />
          </Field>
          <Field label="Status">
            <SearchableSelect
              value={form?.status || "Draft"}
              onChange={(v) => setForm({ ...form, status: v })}
              options={statusOpts}
              allowEmpty={false}
            />
          </Field>
          <Field label="Tujuan Pembelajaran">
            <ObjectiveSelect
              classSubjectId={classSubjectId}
              value={form?.learningObjectiveId || ""}
              onChange={(value) =>
                setForm({ ...form, learningObjectiveId: value })
              }
            />
          </Field>
          <Field label="Deadline">
            <Input
              type="datetime-local"
              value={form?.deadline?.slice(0, 16) || ""}
              onChange={(e) =>
                setForm({ ...form, deadline: e.target.value })
              }
            />
          </Field>
          <Field label="File Tugas">
            <Input
              type="file"
              multiple
              onChange={(event) => setFiles(event.target.files)}
            />
          </Field>
          <div className="md:col-span-2">
            <Field label="Deskripsi">
              <Textarea
                value={form?.deskripsi || ""}
                onChange={(e) =>
                  setForm({ ...form, deskripsi: e.target.value })
                }
              />
            </Field>
          </div>
        </div>
      </Dialog>
      <Dialog
        open={Boolean(submitFor)}
        title={`Pengumpulan - ${submitFor?.judul || ""}`}
        onClose={() => setSubmitFor(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setSubmitFor(null)}>
              Batal
            </Button>
            <Button onClick={submitAssignment}>Kirim</Button>
          </>
        }
      >
        <Field label="File Pengumpulan">
          <Input
            type="file"
            multiple
            onChange={(event) => setSubmissionFiles(event.target.files)}
          />
        </Field>
      </Dialog>
      <Dialog
        open={Boolean(submissionsFor)}
        title={`Pengumpulan - ${submissionsFor?.judul || ""}`}
        onClose={() => setSubmissionsFor(null)}
      >
        <div className="space-y-3">
          {submissions.map((submission) => (
            <Card key={submission.id}>
              <CardContent className="space-y-3 pt-5">
                <div className="flex flex-col justify-between gap-2 md:flex-row">
                  <div>
                    <div className="font-medium">{submission.namaSiswa}</div>
                    <div className="text-sm text-muted-foreground">
                      {submission.nis} -{" "}
                      {formatDateTime(submission.submittedAt)}
                    </div>
                  </div>
                  <Badge
                    tone={submission.nilai ? "success" : "warning"}
                  >
                    {submission.nilai
                      ? `Nilai ${submission.nilai}`
                      : submission.status}
                  </Badge>
                </div>
                <FileLinks files={submission.files} />
                <div className="grid gap-2 md:grid-cols-[120px_1fr_auto]">
                  <Input
                    placeholder="Nilai"
                    type="number"
                    value={
                      grade[submission.id]?.nilai ??
                      submission.nilai ??
                      ""
                    }
                    onChange={(e) =>
                      setGrade({
                        ...grade,
                        [submission.id]: {
                          ...grade[submission.id],
                          nilai: e.target.value,
                        },
                      })
                    }
                  />
                  <Input
                    placeholder="Feedback"
                    value={
                      grade[submission.id]?.feedback ??
                      submission.feedback ??
                      ""
                    }
                    onChange={(e) =>
                      setGrade({
                        ...grade,
                        [submission.id]: {
                          ...grade[submission.id],
                          feedback: e.target.value,
                        },
                      })
                    }
                  />
                  <Button onClick={() => saveGrade(submission.id)}>
                    Nilai
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </Dialog>
    </div>
  );
}

function ExamsPanel({ classSubjectId, isStudent }) {
  const { show, node } = useToast();
  const [rows, setRows] = useState(null);
  const [form, setForm] = useState(null);
  const [answerFor, setAnswerFor] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [attemptsFor, setAttemptsFor] = useState(null);
  const [attempts, setAttempts] = useState([]);
  const [answerReview, setAnswerReview] = useState(null);
  const [reviewRows, setReviewRows] = useState([]);

  const load = useCallback(async () => {
    const data = await apiFetch(withQuery("/exams", { classSubjectId }));
    setRows(data.data || []);
  }, [classSubjectId]);

  useEffect(() => {
    load().catch(() => setRows([]));
  }, [load]);

  const saveExam = async () => {
    try {
      await apiFetch(form.id ? `/exams/${form.id}` : "/exams", {
        method: form.id ? "PUT" : "POST",
        body: {
          ...form,
          classSubjectId,
          questions: form.questions || [],
        },
      });
      show("Ujian berhasil disimpan");
      setForm(null);
      await load();
    } catch (error) {
      show(error.message, "error");
    }
  };

  const startAnswer = async (exam) => {
    setAnswerFor(exam);
    const data = await apiFetch(`/exams/${exam.id}/questions`);
    setQuestions(data.data || []);
    setAnswers({});
  };

  const submitAnswers = async () => {
    await apiFetch(`/exams/${answerFor.id}/answers`, {
      method: "POST",
      body: {
        answers: Object.entries(answers).map(([questionId, value]) => ({
          questionId,
          ...value,
        })),
      },
    });
    show("Jawaban ujian berhasil dikirim");
    setAnswerFor(null);
    await load();
  };

  const loadAttempts = async (exam) => {
    setAttemptsFor(exam);
    const data = await apiFetch(`/exams/${exam.id}/attempts`);
    setAttempts(data.data || []);
  };

  const loadReview = async (student) => {
    const data = await apiFetch(
      `/exams/${attemptsFor.id}/answers/${student.siswaUserId}`,
    );
    setAnswerReview(student);
    setReviewRows(data.data || []);
  };

  if (!rows) return <LoadingBlock />;

  return (
    <div>
      {node}
      <SectionToolbar
        title="Ujian Kelas"
        action={
          !isStudent && (
            <Button
              onClick={() =>
                setForm({
                  tipeUjian: "Sumatif Lingkup Materi",
                  statusNilai: "Draft",
                  statusUjian: "Draft",
                  questions: [emptyQuestion()],
                })
              }
            >
              <Plus className="h-4 w-4" />
              Tambah Ujian
            </Button>
          )
        }
      />
      <div className="grid gap-4">
        {rows.map((exam) => (
          <Card key={exam.id}>
            <CardHeader>
              <div className="flex flex-col justify-between gap-3 md:flex-row">
                <div>
                  <CardTitle>{exam.judul}</CardTitle>
                  <CardDescription>
                    {exam.tipeUjian} - {formatDate(exam.tanggalUjian)}{" "}
                    {exam.jamMulai?.slice(0, 5)}-{exam.jamSelesai?.slice(0, 5)}
                  </CardDescription>
                </div>
                <div className="flex gap-2">
                  <Badge
                    tone={
                      exam.statusUjian === "Visible" ? "success" : "muted"
                    }
                  >
                    {exam.statusUjian}
                  </Badge>
                  <Badge tone="muted">{exam.jumlahSoal} soal</Badge>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <p className="text-sm">{exam.deskripsi}</p>
              {isStudent ? (
                <div className="flex flex-wrap gap-2">
                  {exam.nilaiSiswa ? (
                    <Badge>Nilai {exam.nilaiSiswa}</Badge>
                  ) : null}
                  <Button size="sm" onClick={() => startAnswer(exam)}>
                    Kerjakan / Lihat Soal
                  </Button>
                </div>
              ) : (
                <div className="flex flex-wrap gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => loadAttempts(exam)}
                  >
                    Pengerjaan ({exam.jumlahPengerjaan || 0})
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={async () => {
                      const qData = await apiFetch(
                        `/exams/${exam.id}/questions`,
                      );
                      setForm({ ...exam, questions: qData.data || [] });
                    }}
                  >
                    <Edit3 className="h-3.5 w-3.5" />
                    Ubah
                  </Button>
                  <Button
                    variant="destructive"
                    size="sm"
                    onClick={async () => {
                      if (confirm("Hapus ujian?")) {
                        await apiFetch(`/exams/${exam.id}`, {
                          method: "DELETE",
                        });
                        await load();
                      }
                    }}
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                    Hapus
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
      <ExamFormDialog
        form={form}
        setForm={setForm}
        classSubjectId={classSubjectId}
        onSave={saveExam}
      />
      <Dialog
        open={Boolean(answerFor)}
        title={answerFor?.judul || "Ujian"}
        onClose={() => setAnswerFor(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setAnswerFor(null)}>
              Tutup
            </Button>
            <Button onClick={submitAnswers}>Kirim Jawaban</Button>
          </>
        }
      >
        <div className="space-y-4">
          {questions.map((question, index) => (
            <Card key={question.id}>
              <CardContent className="space-y-3 pt-5">
                <div className="font-medium">
                  {index + 1}. {question.pertanyaan}
                </div>
                {question.tipeSoal === "Pilihan Ganda" ? (
                  <div className="grid gap-2">
                    {["A", "B", "C", "D"].map((key) => (
                      <label
                        key={key}
                        className="flex items-center gap-2 rounded-lg border p-2 text-sm cursor-pointer hover:bg-muted/50"
                      >
                        <input
                          type="radio"
                          name={`q-${question.id}`}
                          checked={
                            answers[question.id]?.jawabanPilgan === key
                          }
                          onChange={() =>
                            setAnswers({
                              ...answers,
                              [question.id]: { jawabanPilgan: key },
                            })
                          }
                        />
                        {key}. {question[`opsi${key}`]}
                      </label>
                    ))}
                  </div>
                ) : (
                  <Textarea
                    value={answers[question.id]?.jawabanEsai || ""}
                    onChange={(e) =>
                      setAnswers({
                        ...answers,
                        [question.id]: { jawabanEsai: e.target.value },
                      })
                    }
                  />
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      </Dialog>
      <Dialog
        open={Boolean(attemptsFor)}
        title={`Pengerjaan - ${attemptsFor?.judul || ""}`}
        onClose={() => setAttemptsFor(null)}
      >
        <Table
          rows={attempts}
          columns={[
            { key: "namaSiswa", header: "Siswa" },
            { key: "nis", header: "NIS" },
            { key: "jumlahJawaban", header: "Jawaban" },
            { key: "nilaiTotal", header: "Nilai" },
            {
              key: "actions",
              header: "",
              render: (row) => (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={() => loadReview(row)}
                >
                  Lihat
                </Button>
              ),
            },
          ]}
        />
      </Dialog>
      <Dialog
        open={Boolean(answerReview)}
        title={`Jawaban - ${answerReview?.namaSiswa || ""}`}
        onClose={() => setAnswerReview(null)}
      >
        <div className="space-y-3">
          {reviewRows.map((row) => (
            <Card key={row.jawabanUjianId}>
              <CardContent className="space-y-3 pt-5">
                <div className="font-medium">{row.pertanyaan}</div>
                <p className="text-sm text-muted-foreground">
                  Jawaban:{" "}
                  {row.jawabanPilgan || row.jawabanEsai || "-"}
                </p>
                <div className="flex gap-2">
                  <Input
                    type="number"
                    defaultValue={row.nilaiJawaban || ""}
                    onChange={(e) => (row.nextNilai = e.target.value)}
                    className="max-w-32"
                  />
                  <Button
                    onClick={async () => {
                      await apiFetch(
                        `/exam-answers/${row.jawabanUjianId}/grade`,
                        {
                          method: "PUT",
                          body: {
                            nilai:
                              row.nextNilai ?? row.nilaiJawaban ?? 0,
                          },
                        },
                      );
                      show("Nilai jawaban tersimpan");
                      await loadReview(answerReview);
                    }}
                  >
                    Simpan
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </Dialog>
    </div>
  );
}

function emptyQuestion() {
  return {
    tipeSoal: "Pilihan Ganda",
    pertanyaan: "",
    opsiA: "",
    opsiB: "",
    opsiC: "",
    opsiD: "",
    jawabanBenar: "A",
    bobot: 1,
  };
}

function ExamFormDialog({ form, setForm, classSubjectId, onSave }) {
  if (!form) return null;
  const questions = form.questions || [];
  const updateQuestion = (index, patch) => {
    const next = questions.map((item, idx) =>
      idx === index ? { ...item, ...patch } : item,
    );
    setForm({ ...form, questions: next });
  };

  const tipeUjianOpts = [
    "Latihan Soal",
    "Sumatif Lingkup Materi",
    "STS",
    "SAS",
  ].map((v) => ({ value: v, label: v }));

  const statusOpts = ["Draft", "Visible", "Hidden"].map((v) => ({
    value: v,
    label: v,
  }));

  const tipeSoalOpts = ["Pilihan Ganda", "Esai"].map((v) => ({
    value: v,
    label: v,
  }));

  const jawabanBenarOpts = ["A", "B", "C", "D"].map((v) => ({
    value: v,
    label: v,
  }));

  return (
    <Dialog
      open={Boolean(form)}
      title={form.id ? "Ubah Ujian" : "Tambah Ujian"}
      onClose={() => setForm(null)}
      footer={
        <>
          <Button variant="outline" onClick={() => setForm(null)}>
            Batal
          </Button>
          <Button onClick={onSave}>Simpan</Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Field label="Judul">
          <Input
            value={form.judul || ""}
            onChange={(e) => setForm({ ...form, judul: e.target.value })}
          />
        </Field>
        <Field label="Tipe Ujian">
          <SearchableSelect
            value={form.tipeUjian || "Sumatif Lingkup Materi"}
            onChange={(v) => setForm({ ...form, tipeUjian: v })}
            options={tipeUjianOpts}
            allowEmpty={false}
          />
        </Field>
        <Field label="Tujuan Pembelajaran">
          <ObjectiveSelect
            classSubjectId={classSubjectId}
            value={form.learningObjectiveId || ""}
            onChange={(value) =>
              setForm({ ...form, learningObjectiveId: value })
            }
          />
        </Field>
        <Field label="Tanggal Ujian">
          <Input
            type="date"
            value={form.tanggalUjian || ""}
            onChange={(e) =>
              setForm({ ...form, tanggalUjian: e.target.value })
            }
          />
        </Field>
        <Field label="Jam Mulai">
          <Input
            type="time"
            value={form.jamMulai?.slice(0, 5) || ""}
            onChange={(e) => setForm({ ...form, jamMulai: e.target.value })}
          />
        </Field>
        <Field label="Jam Selesai">
          <Input
            type="time"
            value={form.jamSelesai?.slice(0, 5) || ""}
            onChange={(e) =>
              setForm({ ...form, jamSelesai: e.target.value })
            }
          />
        </Field>
        <Field label="Status Ujian">
          <SearchableSelect
            value={form.statusUjian || "Draft"}
            onChange={(v) => setForm({ ...form, statusUjian: v })}
            options={statusOpts}
            allowEmpty={false}
          />
        </Field>
        <Field label="Status Nilai">
          <SearchableSelect
            value={form.statusNilai || "Draft"}
            onChange={(v) => setForm({ ...form, statusNilai: v })}
            options={statusOpts}
            allowEmpty={false}
          />
        </Field>
        <div className="md:col-span-2">
          <Field label="Deskripsi">
            <Textarea
              value={form.deskripsi || ""}
              onChange={(e) =>
                setForm({ ...form, deskripsi: e.target.value })
              }
            />
          </Field>
        </div>
      </div>
      <div className="mt-6 space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-semibold">Soal Ujian</h3>
          <Button
            variant="outline"
            size="sm"
            onClick={() =>
              setForm({
                ...form,
                questions: [...questions, emptyQuestion()],
              })
            }
          >
            <Plus className="h-3.5 w-3.5" />
            Soal
          </Button>
        </div>
        {questions.map((question, index) => (
          <Card key={index}>
            <CardContent className="grid gap-3 pt-5 md:grid-cols-2">
              <Field label={`Pertanyaan ${index + 1}`}>
                <Textarea
                  value={question.pertanyaan || ""}
                  onChange={(e) =>
                    updateQuestion(index, { pertanyaan: e.target.value })
                  }
                />
              </Field>
              <div className="grid gap-3">
                <Field label="Tipe Soal">
                  <SearchableSelect
                    value={question.tipeSoal || "Pilihan Ganda"}
                    onChange={(v) => updateQuestion(index, { tipeSoal: v })}
                    options={tipeSoalOpts}
                    allowEmpty={false}
                  />
                </Field>
                <Field label="Bobot">
                  <Input
                    type="number"
                    value={question.bobot || 1}
                    onChange={(e) =>
                      updateQuestion(index, { bobot: e.target.value })
                    }
                  />
                </Field>
              </div>
              {question.tipeSoal !== "Esai" ? (
                <>
                  {["A", "B", "C", "D"].map((key) => (
                    <Field key={key} label={`Opsi ${key}`}>
                      <Input
                        value={question[`opsi${key}`] || ""}
                        onChange={(e) =>
                          updateQuestion(index, {
                            [`opsi${key}`]: e.target.value,
                          })
                        }
                      />
                    </Field>
                  ))}
                  <Field label="Jawaban Benar">
                    <SearchableSelect
                      value={question.jawabanBenar || "A"}
                      onChange={(v) =>
                        updateQuestion(index, { jawabanBenar: v })
                      }
                      options={jawabanBenarOpts}
                      allowEmpty={false}
                    />
                  </Field>
                </>
              ) : null}
            </CardContent>
          </Card>
        ))}
      </div>
    </Dialog>
  );
}

function StudentsPanel({ classSubjectId }) {
  const [allRows, setAllRows] = useState(null);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);

  useEffect(() => {
    apiFetch(`/class-subjects/${classSubjectId}/students`)
      .then((data) => setAllRows(data.data || []))
      .catch(() => setAllRows([]));
  }, [classSubjectId]);

  if (!allRows) return <LoadingBlock />;

  const total = allRows.length;
  const totalPages = Math.ceil(total / pageSize) || 1;
  const pageRows = allRows.slice((page - 1) * pageSize, page * pageSize);

  return (
    <div>
      <Table
        rows={pageRows}
        columns={[
          { key: "namaSiswa", header: "Nama" },
          { key: "nis", header: "NIS" },
          { key: "nisn", header: "NISN" },
          { key: "emailSiswa", header: "Email" },
          { key: "noTelpSiswa", header: "Telepon" },
        ]}
      />
      <Pagination
        page={page}
        totalPages={totalPages}
        total={total}
        pageSize={pageSize}
        onPageChange={setPage}
        onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
      />
    </div>
  );
}

function GroupsPanel({ classSubjectId }) {
  const { show, node } = useToast();
  const [groups, setGroups] = useState(null);
  const [students, setStudents] = useState([]);
  const [form, setForm] = useState(null);

  const load = useCallback(async () => {
    const [groupData, studentData] = await Promise.all([
      apiFetch(`/class-subjects/${classSubjectId}/groups`),
      apiFetch(`/class-subjects/${classSubjectId}/students`),
    ]);
    setGroups(groupData.data || []);
    setStudents(studentData.data || []);
  }, [classSubjectId]);

  useEffect(() => {
    load().catch(() => setGroups([]));
  }, [load]);

  const save = async () => {
    await apiFetch(
      form.id
        ? `/groups/${form.id}`
        : `/class-subjects/${classSubjectId}/groups`,
      {
        method: form.id ? "PUT" : "POST",
        body: form,
      },
    );
    show("Kelompok berhasil disimpan");
    setForm(null);
    await load();
  };

  if (!groups) return <LoadingBlock />;

  return (
    <div>
      {node}
      <SectionToolbar
        title="Kelompok Belajar"
        action={
          <Button onClick={() => setForm({ memberIds: [] })}>
            <Plus className="h-4 w-4" />
            Tambah Kelompok
          </Button>
        }
      />
      <div className="grid gap-4 md:grid-cols-2">
        {groups.map((group) => (
          <Card key={group.id}>
            <CardHeader>
              <CardTitle>{group.namaKelompok}</CardTitle>
              <CardDescription>{group.jumlahAnggota} anggota</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2 text-sm">
                {(group.anggotaKelompok || []).map((member) => (
                  <div key={member.id} className="rounded-lg border p-2">
                    {member.nama} - {member.nis}
                  </div>
                ))}
              </div>
              <div className="mt-4 flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setForm({
                      ...group,
                      memberIds: group.anggotaKelompok.map(
                        (item) => item.id,
                      ),
                    })
                  }
                >
                  Ubah
                </Button>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={async () => {
                    if (confirm("Hapus kelompok?")) {
                      await apiFetch(`/groups/${group.id}`, {
                        method: "DELETE",
                      });
                      await load();
                    }
                  }}
                >
                  Hapus
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      <Dialog
        open={Boolean(form)}
        title="Kelompok Belajar"
        onClose={() => setForm(null)}
        footer={
          <>
            <Button variant="outline" onClick={() => setForm(null)}>
              Batal
            </Button>
            <Button onClick={save}>Simpan</Button>
          </>
        }
      >
        <Field label="Nama Kelompok">
          <Input
            value={form?.namaKelompok || ""}
            onChange={(e) =>
              setForm({ ...form, namaKelompok: e.target.value })
            }
          />
        </Field>
        <div className="mt-4 max-h-64 space-y-2 overflow-y-auto rounded-lg border p-3 app-scrollbar">
          {students.map((student) => (
            <label
              key={student.userIdSiswa}
              className="flex items-center gap-2 text-sm cursor-pointer"
            >
              <input
                type="checkbox"
                checked={(form?.memberIds || [])
                  .map(Number)
                  .includes(Number(student.userIdSiswa))}
                onChange={(e) => {
                  const current = (form?.memberIds || []).map(Number);
                  const next = e.target.checked
                    ? [...current, Number(student.userIdSiswa)]
                    : current.filter(
                        (id) => id !== Number(student.userIdSiswa),
                      );
                  setForm({ ...form, memberIds: next });
                }}
              />
              {student.namaSiswa} - {student.nis}
            </label>
          ))}
        </div>
      </Dialog>
    </div>
  );
}

function RubricsPage({ classSubjectId, compact = false }) {
  const { options } = useOptions();
  const { show, node } = useToast();
  const [rows, setRows] = useState(null);
  const [form, setForm] = useState(null);
  const targetClassSubjectId = classSubjectId;
  const subjectFromClass = options.classSubjects.find(
    (item) => Number(item.id) === Number(targetClassSubjectId),
  )?.subjectId;

  const load = useCallback(async () => {
    const data = await apiFetch(
      withQuery("/rubrics", { classSubjectId: targetClassSubjectId }),
    );
    setRows(data.data || []);
  }, [targetClassSubjectId]);

  useEffect(() => {
    load().catch(() => setRows([]));
  }, [load]);

  const save = async () => {
    await apiFetch(
      form.lingkupMateriId ? `/rubrics/${form.lingkupMateriId}` : "/rubrics",
      {
        method: form.lingkupMateriId ? "PUT" : "POST",
        body: {
          ...form,
          subjectId: form.subjectId || subjectFromClass,
          objectives: form.tujuanPembelajaran || [],
        },
      },
    );
    show("Rubrik berhasil disimpan");
    setForm(null);
    await load();
  };

  if (!rows) return <LoadingBlock />;

  return (
    <div>
      {node}
      {!compact ? (
        <PageHeader
          title="Rubrik Mapel"
          description="Kelola lingkup materi dan tujuan pembelajaran beserta kriteria capaian."
        />
      ) : null}
      <SectionToolbar
        title={compact ? "Rubrik Mapel" : "Daftar Rubrik"}
        action={
          <Button
            onClick={() =>
              setForm({
                subjectId: subjectFromClass,
                statusKunci: 0,
                tujuanPembelajaran: [emptyObjective()],
              })
            }
          >
            <Plus className="h-4 w-4" />
            Tambah Rubrik
          </Button>
        }
      />
      <div className="grid gap-4">
        {rows.map((scope) => (
          <Card key={scope.lingkupMateriId}>
            <CardHeader>
              <div className="flex justify-between gap-3">
                <div>
                  <CardTitle>{scope.lingkupMateri}</CardTitle>
                  <CardDescription>
                    {scope.judulMapel} - {scope.jumlahTP} tujuan pembelajaran
                  </CardDescription>
                </div>
                <Badge tone={scope.statusKunci ? "success" : "muted"}>
                  {scope.statusKunci ? "Terkunci" : "Draft"}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              {(scope.tujuanPembelajaran || []).map((tp) => (
                <div
                  key={tp.id}
                  className="rounded-lg border bg-muted/20 p-3 text-sm"
                >
                  <div className="font-medium">{tp.deskripsi}</div>
                  <div className="mt-2 grid gap-2 text-muted-foreground md:grid-cols-4">
                    <span>PB: {tp.perluBimbingan || "-"}</span>
                    <span>C: {tp.cukup || "-"}</span>
                    <span>B: {tp.baik || "-"}</span>
                    <span>SB: {tp.sangatBaik || "-"}</span>
                  </div>
                </div>
              ))}
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setForm(scope)}
                >
                  Ubah
                </Button>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={async () => {
                    if (confirm("Hapus rubrik?")) {
                      await apiFetch(
                        `/rubrics/${scope.lingkupMateriId}`,
                        { method: "DELETE" },
                      );
                      await load();
                    }
                  }}
                >
                  Hapus
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
      <RubricDialog
        form={form}
        setForm={setForm}
        options={options}
        onSave={save}
      />
    </div>
  );
}

function emptyObjective() {
  return {
    deskripsi: "",
    perluBimbingan: "",
    cukup: "",
    baik: "",
    sangatBaik: "",
  };
}

function RubricDialog({ form, setForm, options, onSave }) {
  if (!form) return null;
  const objectives = form.tujuanPembelajaran || [];
  const updateObjective = (index, patch) => {
    const next = objectives.map((item, idx) =>
      idx === index ? { ...item, ...patch } : item,
    );
    setForm({ ...form, tujuanPembelajaran: next });
  };

  const subjectOpts = optionMappers.subjects(options).map((item) => ({
    value: String(item.value),
    label: item.label,
  }));

  const semesterOpts = options.semesters.map((item) => ({
    value: String(item.id),
    label: item.judulSemester,
  }));

  const statusKunciOpts = [
    { value: "0", label: "Draft" },
    { value: "1", label: "Terkunci" },
  ];

  return (
    <Dialog
      open={Boolean(form)}
      title="Rubrik Mapel"
      onClose={() => setForm(null)}
      footer={
        <>
          <Button variant="outline" onClick={() => setForm(null)}>
            Batal
          </Button>
          <Button onClick={onSave}>Simpan</Button>
        </>
      }
    >
      <div className="grid gap-4 md:grid-cols-2">
        <Field label="Mata Pelajaran">
          <SearchableSelect
            value={String(form.subjectId || "")}
            onChange={(v) => setForm({ ...form, subjectId: v })}
            options={subjectOpts}
          />
        </Field>
        <Field label="Semester">
          <SearchableSelect
            value={String(form.semesterId || "")}
            onChange={(v) => setForm({ ...form, semesterId: v })}
            options={semesterOpts}
          />
        </Field>
        <Field label="Lingkup Materi">
          <Input
            value={form.lingkupMateri || ""}
            onChange={(e) =>
              setForm({ ...form, lingkupMateri: e.target.value })
            }
          />
        </Field>
        <Field label="Status Kunci">
          <SearchableSelect
            value={String(form.statusKunci ? 1 : 0)}
            onChange={(v) =>
              setForm({ ...form, statusKunci: Number(v) })
            }
            options={statusKunciOpts}
            allowEmpty={false}
          />
        </Field>
      </div>
      <div className="mt-5 space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="font-semibold">Tujuan Pembelajaran</h3>
          <Button
            variant="outline"
            size="sm"
            onClick={() =>
              setForm({
                ...form,
                tujuanPembelajaran: [...objectives, emptyObjective()],
              })
            }
          >
            Tambah TP
          </Button>
        </div>
        {objectives.map((objective, index) => (
          <Card key={index}>
            <CardContent className="grid gap-3 pt-5 md:grid-cols-2">
              <div className="md:col-span-2">
                <Field label="Deskripsi">
                  <Textarea
                    value={objective.deskripsi || ""}
                    onChange={(e) =>
                      updateObjective(index, { deskripsi: e.target.value })
                    }
                  />
                </Field>
              </div>
              {[
                ["perluBimbingan", "Perlu Bimbingan"],
                ["cukup", "Cukup"],
                ["baik", "Baik"],
                ["sangatBaik", "Sangat Baik"],
              ].map(([key, label]) => (
                <Field key={key} label={label}>
                  <Input
                    value={objective[key] || ""}
                    onChange={(e) =>
                      updateObjective(index, { [key]: e.target.value })
                    }
                  />
                </Field>
              ))}
            </CardContent>
          </Card>
        ))}
      </div>
    </Dialog>
  );
}

function GradeCell({ studentId, itemId, itemType, currentValue, onSaved, readOnly }) {
  const [editing, setEditing] = useState(false);
  const [val, setVal] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState(null);

  if (readOnly) {
    return (
      <span className={currentValue === null ? "text-xs text-muted-foreground" : "font-medium"}>
        {currentValue ?? "—"}
      </span>
    );
  }

  const handleSave = async () => {
    const trimmed = val.trim();
    if (trimmed === "" || trimmed === String(currentValue ?? "")) {
      setEditing(false);
      setError(null);
      return;
    }
    const num = Number(trimmed);
    if (isNaN(num) || num < 0 || num > 100) {
      setError("0–100");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      const endpoint =
        itemType === "assignment"
          ? `/assignments/${itemId}/grade-student`
          : `/exams/${itemId}/grade-student`;
      await apiFetch(endpoint, { method: "PUT", body: { studentId, nilai: num } });
      await onSaved();
    } catch (err) {
      setError(err.message || "Gagal simpan");
    } finally {
      setSaving(false);
      setEditing(false);
    }
  };

  if (saving) {
    return (
      <span className="inline-flex items-center gap-1 text-xs text-muted-foreground italic">
        <span className="h-3 w-3 animate-spin rounded-full border-2 border-muted border-t-primary" />
        Menyimpan…
      </span>
    );
  }

  if (editing) {
    return (
      <div className="flex flex-col gap-1">
        <input
          autoFocus
          type="number"
          min="0"
          max="100"
          step="0.5"
          value={val}
          onChange={(e) => { setVal(e.target.value); setError(null); }}
          onBlur={handleSave}
          onKeyDown={(e) => {
            if (e.key === "Enter") { e.preventDefault(); handleSave(); }
            if (e.key === "Escape") { setEditing(false); setError(null); }
          }}
          className="w-20 rounded-md border-2 border-primary bg-white px-2 py-1 text-sm font-medium outline-none"
        />
        {error ? (
          <span className="text-xs text-red-500">{error}</span>
        ) : (
          <span className="text-xs text-muted-foreground">Enter simpan</span>
        )}
      </div>
    );
  }

  const hasValue = currentValue !== null && currentValue !== undefined;

  return (
    <button
      type="button"
      title="Klik untuk input/ubah nilai"
      onClick={() => { setEditing(true); setVal(String(currentValue ?? "")); setError(null); }}
      className={cn(
        "flex cursor-pointer items-center gap-1.5 rounded-md border px-2 py-1 text-sm transition-all",
        hasValue
          ? "border-transparent bg-muted/50 font-medium hover:border-primary/40 hover:bg-primary/10"
          : "border-dashed border-border text-muted-foreground hover:border-primary/50 hover:bg-muted",
      )}
    >
      {hasValue ? (
        <>
          <span>{currentValue}</span>
          <Edit3 className="h-3.5 w-3.5 text-muted-foreground/60" />
        </>
      ) : (
        <>
          <Edit3 className="h-3.5 w-3.5" />
          <span className="text-xs">Isi nilai</span>
        </>
      )}
    </button>
  );
}

const gradeTypeMeta = {
  practice:    { label: "Nilai Latihan Soal",      desc: "Rekap nilai latihan soal per siswa." },
  assignments: { label: "Nilai Tugas",             desc: "Rekap nilai tugas yang dikumpulkan per siswa." },
  sumative:    { label: "Sumatif Lingkup Materi",  desc: "Rekap nilai sumatif per lingkup materi." },
  exam:        { label: "Nilai Ujian Sumatif",     desc: "Rekap nilai ujian sumatif tengah/akhir semester." },
  final:       { label: "Nilai Akhir",             desc: "Rekap nilai akhir gabungan tugas dan ujian beserta capaian." },
};

const guruGradeTypes = ["assignments", "sumative", "exam", "final"];

function GradesPage({ classSubjectId, compact = false, type = "final" }) {
  const { user } = useAuth();
  const { options } = useOptions();
  const { show, node: toastNode } = useToast();
  const [selected, setSelected] = useState(classSubjectId || "");
  const [gradeType, setGradeType] = useState(type);
  const [selectedClassId, setSelectedClassId] = useState("");
  const [selectedSubjectId, setSelectedSubjectId] = useState("");
  const [selectedSemesterId, setSelectedSemesterId] = useState("");
  const [allRows, setAllRows] = useState(null);
  const [loading, setLoading] = useState(false);
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(25);

  // Sync prop → state saat route berganti (backup selain key prop)
  useEffect(() => {
    setGradeType(type);
    setPage(1);
  }, [type]);

  const load = useCallback(async () => {
    if (!selected) { setAllRows([]); return; }
    setLoading(true);
    try {
      const data = await apiFetch(withQuery("/grades", {
        classSubjectId: selected,
        type: gradeType,
        semesterId: user?.role === "guru" && !classSubjectId ? selectedSemesterId : "",
      }));
      setAllRows(data.data || []);
      setPage(1);
    } catch (err) {
      show(err.message || "Gagal memuat data nilai", "error");
      setAllRows([]);
    } finally {
      setLoading(false);
    }
  }, [classSubjectId, selected, gradeType, selectedSemesterId, user?.role]);

  useEffect(() => { load(); }, [load]);

  const isGuru = user?.role === "guru";
  // Guru hanya berwenang atas penilaian tugas, sumatif LM, ujian sumatif, dan nilai akhir.
  const gradeTypeOpts = Object.entries(gradeTypeMeta)
    .filter(([value]) => !isGuru || guruGradeTypes.includes(value))
    .map(([value, { label }]) => ({ value, label }));
  const meta = gradeTypeMeta[gradeType] || gradeTypeMeta.final;

  const academicYearById = useMemo(
    () => new Map((options.academicYears || []).map((year) => [String(year.id), year])),
    [options.academicYears],
  );

  const teacherAcademicYearIds = useMemo(
    () => new Set((options.classSubjects || []).map((item) => String(item.academicYearId))),
    [options.classSubjects],
  );

  const semesterOptions = useMemo(
    () => (options.semesters || [])
      .filter((semester) => !isGuru || teacherAcademicYearIds.has(String(semester.academicYearId)))
      .map((semester) => {
        const year = academicYearById.get(String(semester.academicYearId));
        return {
          value: String(semester.id),
          label: `${semester.judulSemester} / ${year?.tahunAjaran || "Tahun ajaran tidak tersedia"}`,
        };
      }),
    [academicYearById, isGuru, options.semesters, teacherAcademicYearIds],
  );

  const selectedSemester = (options.semesters || []).find(
    (semester) => String(semester.id) === String(selectedSemesterId),
  );
  const selectedAcademicYearId = selectedSemester?.academicYearId;

  const teacherClassSubjects = useMemo(
    () => (options.classSubjects || []).filter(
      (item) => !selectedAcademicYearId
        || String(item.academicYearId) === String(selectedAcademicYearId),
    ),
    [options.classSubjects, selectedAcademicYearId],
  );

  const teacherClassOptions = useMemo(() => {
    const unique = new Map();
    teacherClassSubjects.forEach((item) => {
      unique.set(String(item.classId), {
        value: String(item.classId),
        label: item.namaKelas,
      });
    });
    return Array.from(unique.values());
  }, [teacherClassSubjects]);

  const teacherSubjectOptions = useMemo(() => {
    const unique = new Map();
    teacherClassSubjects
      .filter((item) => !selectedClassId || String(item.classId) === String(selectedClassId))
      .forEach((item) => {
        unique.set(String(item.subjectId), {
          value: String(item.subjectId),
          label: item.judulMapel,
        });
      });
    return Array.from(unique.values());
  }, [teacherClassSubjects, selectedClassId]);

  useEffect(() => {
    if (!isGuru || classSubjectId || selectedSemesterId || !semesterOptions.length) return;
    const activeSemester = options.semesters.find(
      (semester) => Number(semester.isActive)
        && teacherAcademicYearIds.has(String(semester.academicYearId)),
    );
    setSelectedSemesterId(String(activeSemester?.id || semesterOptions[0].value));
  }, [
    classSubjectId,
    isGuru,
    options.semesters,
    selectedSemesterId,
    semesterOptions,
    teacherAcademicYearIds,
  ]);

  useEffect(() => {
    if (!isGuru || classSubjectId) return;
    if (!selectedClassId || !selectedSubjectId || !selectedSemesterId) {
      setSelected("");
      return;
    }
    const match = teacherClassSubjects.find(
      (item) => String(item.classId) === String(selectedClassId)
        && String(item.subjectId) === String(selectedSubjectId),
    );
    setSelected(match ? String(match.id) : "");
  }, [
    classSubjectId,
    isGuru,
    selectedClassId,
    selectedSemesterId,
    selectedSubjectId,
    teacherClassSubjects,
  ]);

  const total = allRows?.length ?? 0;
  const totalPages = Math.ceil(total / pageSize) || 1;
  const pageRows = allRows ? allRows.slice((page - 1) * pageSize, page * pageSize) : [];

  const isFinal = gradeType === "final";

  // Kolom dinamis — satu kolom per tugas/ujian
  const gradeColumns = useMemo(() => {
    const base = [
      { key: "namaSiswa", header: "Siswa" },
      { key: "nis", header: "NIS" },
    ];

    if (!allRows?.length) {
      return [
        ...base,
        { key: "nilaiAkhir", header: isFinal ? "Nilai Akhir" : "Rata-rata" },
        ...(isFinal ? [{ key: "capaian", header: "Capaian" }] : []),
      ];
    }

    const firstRow = allRows[0];
    const cols = [...base];

    // Kolom per tugas
    if (gradeType === "assignments" || gradeType === "final") {
      (firstRow.nilaiTugas || []).forEach((tugas) => {
        cols.push({
          key: `t_${tugas.id}`,
          header: tugas.judul,
          render: (row) => {
            const item = row.nilaiTugas?.find((t) => t.id === tugas.id);
            return (
              <GradeCell
                studentId={row.siswaId}
                itemId={tugas.id}
                itemType="assignment"
                currentValue={item?.nilai ?? null}
                onSaved={load}
                readOnly={isFinal}
              />
            );
          },
        });
      });
      if (!firstRow.nilaiTugas?.length) {
        cols.push({ key: "noTugas", header: "Tugas", render: () => <span className="text-xs text-muted-foreground">Belum ada tugas</span> });
      }
    }

    // Kolom per ujian
    if (gradeType !== "assignments") {
      (firstRow.nilaiUjian || []).forEach((ujian) => {
        cols.push({
          key: `u_${ujian.id}`,
          header: ujian.judul,
          render: (row) => {
            const item = row.nilaiUjian?.find((u) => u.id === ujian.id);
            return (
              <GradeCell
                studentId={row.siswaId}
                itemId={ujian.id}
                itemType="exam"
                currentValue={item?.nilai ?? null}
                onSaved={load}
                readOnly={isFinal}
              />
            );
          },
        });
      });
      if (!firstRow.nilaiUjian?.length) {
        cols.push({ key: "noUjian", header: "Ujian", render: () => <span className="text-xs text-muted-foreground">Belum ada ujian</span> });
      }
    }

    cols.push({
      key: "nilaiAkhir",
      header: isFinal ? "Nilai Akhir" : "Rata-rata",
      render: (row) =>
        row.nilaiAkhir !== null && row.nilaiAkhir !== undefined ? (
          <span className="font-semibold">{row.nilaiAkhir}</span>
        ) : (
          <span className="text-xs text-muted-foreground">—</span>
        ),
    });

    if (isFinal) {
      cols.push({
        key: "capaian",
        header: "Capaian",
        render: (row) =>
          row.capaian && row.capaian !== "-" ? (
            <Badge
              tone={
                row.nilaiAkhir >= 85 ? "success" :
                row.nilaiAkhir >= 75 ? "default" :
                row.nilaiAkhir >= 60 ? "warning" : "danger"
              }
            >
              {row.capaian}
            </Badge>
          ) : <span className="text-xs text-muted-foreground">—</span>,
      });
    }

    return cols;
  }, [allRows, gradeType, load]);

  const needsClassSelect = !classSubjectId;

  return (
    <div>
      {toastNode}
      {!compact ? (
        <PageHeader title={meta.label} description={meta.desc} />
      ) : null}

      {isGuru && needsClassSelect ? (
        <div className="mb-4 grid gap-3 md:grid-cols-3">
          <Field label="Kelas">
            <SearchableSelect
              value={selectedClassId}
              onChange={(value) => {
                setSelected("");
                setSelectedClassId(value);
                setSelectedSubjectId("");
                setPage(1);
              }}
              options={teacherClassOptions}
              placeholder="Pilih kelas..."
            />
          </Field>
          <Field label="Mata Pelajaran">
            <SearchableSelect
              value={selectedSubjectId}
              onChange={(value) => {
                setSelected("");
                setSelectedSubjectId(value);
                setPage(1);
              }}
              options={teacherSubjectOptions}
              placeholder="Pilih mata pelajaran..."
            />
          </Field>
          <Field label="Semester / Tahun Ajaran">
            <SearchableSelect
              value={selectedSemesterId}
              onChange={(value) => {
                setSelected("");
                setSelectedSemesterId(value);
                setSelectedClassId("");
                setSelectedSubjectId("");
                setPage(1);
              }}
              options={semesterOptions}
              placeholder="Pilih semester / tahun ajaran..."
            />
          </Field>
        </div>
      ) : (
        <div className={`mb-4 grid gap-3 ${needsClassSelect ? "md:grid-cols-2" : "max-w-xs md:grid-cols-1"}`}>
          {needsClassSelect ? (
            <SearchableSelect
              value={String(selected)}
              onChange={(v) => { setSelected(v); setPage(1); }}
              options={optionMappers.classSubjects(options).map((item) => ({
                value: String(item.value),
                label: item.label,
              }))}
              placeholder="Pilih kelas mapel..."
            />
          ) : null}
          {!isGuru || classSubjectId ? (
            <SearchableSelect
              value={gradeType}
              onChange={(v) => { setGradeType(v); setPage(1); }}
              options={gradeTypeOpts}
              allowEmpty={false}
            />
          ) : null}
        </div>
      )}

      {selected && !isFinal && allRows !== null && (
        <div className="mb-3 flex items-center gap-2 rounded-lg border bg-blue-50 px-4 py-2.5 text-sm text-blue-800">
          <Edit3 className="h-3.5 w-3.5 shrink-0" />
          Klik sel nilai untuk menginput atau mengubah nilai siswa. Tekan <kbd className="mx-1 rounded bg-blue-100 px-1.5 py-0.5 text-xs font-mono">Enter</kbd> untuk simpan atau <kbd className="mx-1 rounded bg-blue-100 px-1.5 py-0.5 text-xs font-mono">Esc</kbd> untuk batal.
        </div>
      )}

      {!selected ? (
        <div className="flex min-h-48 items-center justify-center rounded-xl border bg-card text-sm text-muted-foreground">
          {isGuru
            ? "Pilih kelas, mata pelajaran, dan semester / tahun ajaran untuk melihat nilai"
            : "Pilih kelas mapel untuk melihat nilai"}
        </div>
      ) : loading ? (
        <LoadingBlock />
      ) : (
        <div>
          <Table rows={pageRows} columns={gradeColumns} />
          <Pagination
            page={page}
            totalPages={totalPages}
            total={total}
            pageSize={pageSize}
            onPageChange={setPage}
            onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
          />
        </div>
      )}
    </div>
  );
}

function StaffCurriculumPage() {
  const { show, node } = useToast();
  const [rows, setRows] = useState(null);
  const [candidates, setCandidates] = useState([]);
  const [selected, setSelected] = useState("");

  const load = useCallback(async () => {
    const [staff, candidateData] = await Promise.all([
      apiFetch("/staff-curriculum"),
      apiFetch("/staff-curriculum/candidates"),
    ]);
    setRows(staff.data || []);
    setCandidates(candidateData.data || []);
  }, []);

  useEffect(() => {
    load().catch(() => setRows([]));
  }, [load]);

  const add = async () => {
    await apiFetch("/staff-curriculum", {
      method: "POST",
      body: { userId: selected },
    });
    show("Staff kurikulum berhasil ditambahkan");
    setSelected("");
    await load();
  };

  return (
    <div>
      {node}
      <PageHeader
        title="Daftar Staff Kurikulum"
        description="Admin mengatur siapa saja yang punya akses staff kurikulum."
      />
      <Card className="mb-4">
        <CardContent className="grid gap-3 pt-5 md:grid-cols-[1fr_auto]">
          <SearchableSelect
            value={selected}
            onChange={setSelected}
            options={candidates.map((item) => ({
              value: String(item.id),
              label: `${item.nama} - ${item.email}`,
            }))}
            placeholder="Pilih guru/staff..."
          />
          <Button onClick={add} disabled={!selected}>
            <Plus className="h-4 w-4" />
            Tambah
          </Button>
        </CardContent>
      </Card>
      {!rows ? (
        <LoadingBlock />
      ) : (
        <Table
          rows={rows}
          columns={[
            { key: "nama", header: "Nama" },
            { key: "email", header: "Email" },
            {
              key: "assignedAt",
              header: "Ditambahkan",
              render: (row) => formatDateTime(row.assignedAt),
            },
            {
              key: "actions",
              header: "",
              render: (row) => (
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={async () => {
                    await apiFetch(`/staff-curriculum/${row.id}`, {
                      method: "DELETE",
                    });
                    await load();
                  }}
                >
                  Hapus
                </Button>
              ),
            },
          ]}
        />
      )}
    </div>
  );
}

function UserManagementPage() {
  const { user: currentUser } = useAuth();
  const { show, node } = useToast();
  const [rows, setRows] = useState([]);
  const [meta, setMeta] = useState({ total: 0, totalPage: 1, page: 1 });
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("active");
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);
  const [loading, setLoading] = useState(true);

  // Password reset dialog
  const [pwDialog, setPwDialog] = useState(null);
  const [newPassword, setNewPassword] = useState("");
  const [pwLoading, setPwLoading] = useState(false);

  // Identifier change dialog
  const [idDialog, setIdDialog] = useState(null);
  const [newIdentifier, setNewIdentifier] = useState("");
  const [idLoading, setIdLoading] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const data = await apiFetch(
        withQuery("/users", {
          search,
          role: roleFilter,
          status: statusFilter,
          page,
          limit: pageSize,
        }),
      );
      setRows(data.data || []);
      setMeta(data);
    } catch (error) {
      show(error.message, "error");
    } finally {
      setLoading(false);
    }
  }, [search, roleFilter, statusFilter, page, pageSize]);

  useEffect(() => {
    load();
  }, [load]);

  const resetPassword = async () => {
    if (!newPassword || newPassword.length < 6) {
      show("Password minimal 6 karakter", "error");
      return;
    }
    setPwLoading(true);
    try {
      await apiFetch(`/users/${pwDialog.id}/password`, {
        method: "PUT",
        body: { newPassword },
      });
      show(`Password ${pwDialog.nama} berhasil diubah`);
      setPwDialog(null);
      setNewPassword("");
    } catch (error) {
      show(error.message, "error");
    } finally {
      setPwLoading(false);
    }
  };

  const resetToDefault = async (user) => {
    if (!confirm(`Reset password ${user.nama} ke "password"?`)) return;
    try {
      await apiFetch(`/users/${user.id}/password`, {
        method: "PUT",
        body: { newPassword: "password" },
      });
      show(`Password ${user.nama} direset ke default`);
    } catch (error) {
      show(error.message, "error");
    }
  };

  const changeIdentifier = async () => {
    if (!newIdentifier.trim()) {
      show("Identifier tidak boleh kosong", "error");
      return;
    }
    setIdLoading(true);
    try {
      await apiFetch(`/users/${idDialog.id}/identifier`, {
        method: "PUT",
        body: { identifier: newIdentifier },
      });
      show(`Identifier ${idDialog.nama} berhasil diubah`);
      setIdDialog(null);
      setNewIdentifier("");
      await load();
    } catch (error) {
      show(error.message, "error");
    } finally {
      setIdLoading(false);
    }
  };

  const toggleStatus = async (user) => {
    const action = user.isActive ? "nonaktifkan" : "aktifkan";
    if (!confirm(`${action.charAt(0).toUpperCase() + action.slice(1)} akun ${user.nama}?`))
      return;
    try {
      await apiFetch(`/users/${user.id}/status`, { method: "PUT" });
      show(`Akun ${user.nama} berhasil di-${action}`);
      await load();
    } catch (error) {
      show(error.message, "error");
    }
  };

  // Admin bisa filter semua role, staff hanya guru & siswa
  const roleOpts = currentUser?.role === "admin"
    ? [
        { value: "", label: "Semua Role" },
        { value: "admin", label: "Admin" },
        { value: "staff", label: "Staff Kurikulum" },
        { value: "guru", label: "Guru" },
        { value: "siswa", label: "Siswa" },
      ]
    : [
        { value: "", label: "Semua Role" },
        { value: "guru", label: "Guru" },
        { value: "siswa", label: "Siswa" },
      ];

  const statusOpts = [
    { value: "active", label: "Aktif" },
    { value: "inactive", label: "Nonaktif" },
  ];

  const columns = [
    { key: "nama", header: "Nama" },
    {
      key: "identifier",
      header: "Identifier (Login)",
      render: (row) => (
        <code className="rounded bg-muted px-1.5 py-0.5 text-xs font-mono">
          {row.identifier}
        </code>
      ),
    },
    {
      key: "role",
      header: "Role",
      render: (row) => {
        const toneMap = { admin: "danger", staff: "warning", guru: "default", siswa: "muted" };
        const labelMap = { admin: "Admin", staff: "Staff", guru: "Guru", siswa: "Siswa" };
        return (
          <Badge tone={toneMap[row.role] || "muted"}>
            {labelMap[row.role] || row.role}
          </Badge>
        );
      },
    },
    { key: "email", header: "Email" },
    {
      key: "isActive",
      header: "Status",
      render: (row) => (
        <Badge tone={row.isActive ? "success" : "danger"}>
          {row.isActive ? "Aktif" : "Nonaktif"}
        </Badge>
      ),
    },
    {
      key: "actions",
      header: "",
      render: (row) => (
        <div className="flex justify-end gap-1.5">
          <Button
            variant="outline"
            size="sm"
            title="Ubah identifier login"
            onClick={() => {
              setIdDialog(row);
              setNewIdentifier(row.identifier);
            }}
          >
            <Edit3 className="h-3.5 w-3.5" />
          </Button>
          <Button
            variant="outline"
            size="sm"
            title="Reset password"
            onClick={() => {
              setPwDialog(row);
              setNewPassword("");
            }}
          >
            <Key className="h-3.5 w-3.5" />
          </Button>
          <Button
            variant={row.isActive ? "destructive" : "outline"}
            size="sm"
            title={
              row.id === currentUser?.id
                ? "Tidak dapat mengubah status akun sendiri"
                : row.isActive ? "Nonaktifkan" : "Aktifkan"
            }
            disabled={row.id === currentUser?.id}
            onClick={() => toggleStatus(row)}
          >
            <Power className="h-3.5 w-3.5" />
          </Button>
        </div>
      ),
    },
  ];

  return (
    <div>
      {node}
      <PageHeader
        title="Manajemen User"
        description="Kelola akun login guru dan siswa — identifier, password, dan status akun."
      />

      {/* Filters */}
      <div className="mb-4 flex flex-col gap-3 md:flex-row md:items-center">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            className="pl-9"
            placeholder="Cari nama, identifier, email..."
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
          />
        </div>
        <div className="flex gap-2">
          <SearchableSelect
            value={roleFilter}
            onChange={(v) => { setRoleFilter(v); setPage(1); }}
            options={roleOpts}
            placeholder="Semua Role"
            className="w-36"
          />
          <SearchableSelect
            value={statusFilter}
            onChange={(v) => { setStatusFilter(v); setPage(1); }}
            options={statusOpts}
            allowEmpty={false}
            className="w-36"
          />
          <Button variant="outline" onClick={load}>
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Info bar */}
      <div className="mb-3 rounded-lg border bg-amber-50 px-4 py-2.5 text-sm text-amber-800">
        <strong>Catatan:</strong> Identifier digunakan sebagai username login. Password default saat user dibuat adalah{" "}
        <code className="rounded bg-amber-100 px-1 font-mono text-xs">password</code>.
      </div>

      {loading ? (
        <LoadingBlock />
      ) : (
        <Table columns={columns} rows={rows} />
      )}

      <Pagination
        page={meta.page || page}
        totalPages={meta.totalPage || 1}
        total={meta.total ?? rows.length}
        pageSize={pageSize}
        onPageChange={setPage}
        onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
      />

      {/* Password Reset Dialog */}
      <Dialog
        open={Boolean(pwDialog)}
        title={`Reset Password — ${pwDialog?.nama || ""}`}
        description="Masukkan password baru. Minimal 6 karakter."
        onClose={() => { setPwDialog(null); setNewPassword(""); }}
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => resetToDefault(pwDialog)}
              disabled={pwLoading}
            >
              Reset ke Default
            </Button>
            <Button variant="outline" onClick={() => { setPwDialog(null); setNewPassword(""); }}>
              Batal
            </Button>
            <Button onClick={resetPassword} disabled={pwLoading}>
              <Key className="h-4 w-4" />
              {pwLoading ? "Menyimpan..." : "Simpan Password"}
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <div className="rounded-lg border bg-muted/30 p-3 text-sm">
            <span className="text-muted-foreground">Identifier login: </span>
            <code className="font-mono font-medium">{pwDialog?.identifier}</code>
          </div>
          <Field label="Password Baru">
            <Input
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Minimal 6 karakter"
              autoFocus
            />
          </Field>
        </div>
      </Dialog>

      {/* Identifier Change Dialog */}
      <Dialog
        open={Boolean(idDialog)}
        title={`Ubah Identifier — ${idDialog?.nama || ""}`}
        description="Identifier digunakan sebagai username login. Harus unik di seluruh sistem."
        onClose={() => { setIdDialog(null); setNewIdentifier(""); }}
        footer={
          <>
            <Button variant="outline" onClick={() => { setIdDialog(null); setNewIdentifier(""); }}>
              Batal
            </Button>
            <Button onClick={changeIdentifier} disabled={idLoading}>
              <Save className="h-4 w-4" />
              {idLoading ? "Menyimpan..." : "Simpan"}
            </Button>
          </>
        }
      >
        <div className="space-y-4">
          <div className="rounded-lg border bg-muted/30 p-3 text-sm">
            <span className="text-muted-foreground">Identifier saat ini: </span>
            <code className="font-mono font-medium">{idDialog?.identifier}</code>
          </div>
          <Field label="Identifier Baru">
            <Input
              value={newIdentifier}
              onChange={(e) => setNewIdentifier(e.target.value)}
              placeholder="Masukkan identifier baru"
              autoFocus
            />
          </Field>
        </div>
      </Dialog>
    </div>
  );
}

function LogsPage() {
  return (
    <div>
      <PageHeader
        title="Log Aktivitas"
        description="Riwayat aktivitas pengguna pada sistem."
      />
      <SimplePaged
        endpoint="/activity-logs"
        columns={[
          {
            key: "createdAt",
            header: "Waktu",
            render: (row) => formatDateTime(row.createdAt),
          },
          { key: "nama", header: "User" },
          { key: "aksi", header: "Aksi" },
          { key: "entitas", header: "Entitas" },
          { key: "detail", header: "Detail" },
        ]}
      />
    </div>
  );
}

function SimplePaged({ endpoint, columns }) {
  const [rows, setRows] = useState(null);
  const [meta, setMeta] = useState({ total: 0, totalPage: 1, page: 1 });
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(10);

  const load = useCallback(async () => {
    setRows(null);
    const data = await apiFetch(withQuery(endpoint, { page, limit: pageSize })).catch(() => ({ data: [], total: 0, totalPage: 1, page: 1 }));
    setRows(data.data || []);
    setMeta(data);
  }, [endpoint, page, pageSize]);

  useEffect(() => {
    load();
  }, [load]);

  if (!rows) return <LoadingBlock />;
  return (
    <div>
      <Table rows={rows} columns={columns} />
      <Pagination
        page={meta.page || page}
        totalPages={meta.totalPage || 1}
        total={meta.total ?? rows.length}
        pageSize={pageSize}
        onPageChange={setPage}
        onPageSizeChange={(s) => { setPageSize(s); setPage(1); }}
      />
    </div>
  );
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/main"
        element={
          <ProtectedRoute>
            <AppShell />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route
          path="dataGuru"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.teachers} />
            </RoleGate>
          }
        />
        <Route
          path="dataSiswa"
          element={
            <RoleGate allow={["admin", "staff"]}>
              <ResourcePage config={resourceConfigs.students} />
            </RoleGate>
          }
        />
        <Route
          path="kelas"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.classes} />
            </RoleGate>
          }
        />
        <Route
          path="mataPelajaran"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.subjects} />
            </RoleGate>
          }
        />
        <Route
          path="jadwalAkademik"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.events} />
            </RoleGate>
          }
        />
        <Route
          path="jadwalAkademikGuru"
          element={
            <RoleGate allow={["guru"]}>
              <ResourcePage config={resourceConfigs.events} readOnly />
            </RoleGate>
          }
        />
        <Route
          path="jadwalPelajaran"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.schedules} />
            </RoleGate>
          }
        />
        <Route
          path="tahunAjaran"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.years} />
            </RoleGate>
          }
        />
        <Route
          path="rangeNilaiKategori"
          element={
            <RoleGate allow={["staff"]}>
              <ResourcePage config={resourceConfigs.gradeRanges} />
            </RoleGate>
          }
        />
        <Route
          path="rubrikMapel"
          element={
            <RoleGate allow={["staff"]}>
              <RubricsPage />
            </RoleGate>
          }
        />
        <Route
          path="rubrikMapelKelas"
          element={
            <RoleGate allow={["guru"]}>
              <RubricsPage />
            </RoleGate>
          }
        />
        <Route
          path="kelasGuru"
          element={
            <RoleGate allow={["guru"]}>
              <ClassesPage role="guru" />
            </RoleGate>
          }
        />
        <Route
          path="kelasGuru/detail/:id"
          element={
            <RoleGate allow={["guru"]}>
              <ClassDetailPage role="guru" />
            </RoleGate>
          }
        />
        <Route
          path="kelasSiswa"
          element={
            <RoleGate allow={["siswa"]}>
              <ClassesPage role="siswa" />
            </RoleGate>
          }
        />
        <Route
          path="kelasSiswa/detail/:id"
          element={
            <RoleGate allow={["siswa"]}>
              <ClassDetailPage role="siswa" />
            </RoleGate>
          }
        />
        <Route
          path="jadwalMengajar"
          element={
            <RoleGate allow={["guru"]}>
              <SchedulePage mode="guru" />
            </RoleGate>
          }
        />
        <Route
          path="jadwalSiswa"
          element={
            <RoleGate allow={["siswa"]}>
              <SchedulePage mode="siswa" />
            </RoleGate>
          }
        />
        <Route
          path="nilaiLatsol"
          element={
            <RoleGate allow={["staff"]}>
              <GradesPage key="practice" type="practice" />
            </RoleGate>
          }
        />
        <Route
          path="nilaiTugas"
          element={
            <RoleGate allow={["staff", "guru"]}>
              <GradesPage key="assignments" type="assignments" />
            </RoleGate>
          }
        />
        <Route
          path="sumatifLingkupMateri"
          element={
            <RoleGate allow={["staff", "guru"]}>
              <GradesPage key="sumative" type="sumative" />
            </RoleGate>
          }
        />
        <Route
          path="nilaiUjianSumatif"
          element={
            <RoleGate allow={["staff", "guru"]}>
              <GradesPage key="exam" type="exam" />
            </RoleGate>
          }
        />
        <Route
          path="nilaiAkhir"
          element={
            <RoleGate allow={["staff"]}>
              <GradesPage key="final-staff" type="final" />
            </RoleGate>
          }
        />
        <Route
          path="nilaiAkhirKelas"
          element={
            <RoleGate allow={["guru"]}>
              <GradesPage key="final-guru" type="final" />
            </RoleGate>
          }
        />
        <Route
          path="pengumumanSiswa"
          element={
            <RoleGate allow={["siswa"]}>
              <AnnouncementsPage role="siswa" />
            </RoleGate>
          }
        />
        <Route
          path="daftarStaff"
          element={
            <RoleGate allow={["admin"]}>
              <StaffCurriculumPage />
            </RoleGate>
          }
        />
        <Route
          path="logAktivitas"
          element={
            <RoleGate allow={["admin"]}>
              <LogsPage />
            </RoleGate>
          }
        />
        <Route
          path="manajemenUser"
          element={
            <RoleGate allow={["admin", "staff"]}>
              <UserManagementPage />
            </RoleGate>
          }
        />
        <Route path="*" element={<RoleRedirect />} />
      </Route>
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}
