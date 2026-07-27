import 'package:elearning_sman2sidoarjo/core/enums/role_user_enum.dart';
import 'package:elearning_sman2sidoarjo/models/siswa/kelas_siswa_model.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/admin/log_aktivitas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/admin/staff_kurikulum_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/jadwal_mengajar/jadwal_mengajar_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/detail_kelas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/kelas_guru_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/materi/edit_materi_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/materi/pratinjau_materi_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/materi/tambah_materi_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/tugas/beri_nilai_tugas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/tugas/detail_tugas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/tugas/edit_tugas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/tugas/tambah_tugas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/ujian/kelola_ujian_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/ujian/konten_daftar_pengerjaan_ujian.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/ujian/lihat_jawaban_ujian.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/nilai_siswa/nilai_akhir_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/guru/rubrik_mapel/rubrik_mapel_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/jadwal_pelajaran/jadwal_mengajar_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/detail_kelas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/kelas_siswa_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/tugas/pengumpulan_tugas.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/ujian/detail_ujian_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/ujian/lihat_jawaban_ujian_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/siswa/kelas/ujian/soal_ujian_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/data_guru/data_guru_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/data_siswa/data_siswa_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/jadwal_akademik/jadwal_akademik_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/jadwal_pelajaran/jadwal_pelajaran_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/kelas/kelas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/mata_pelajaran/mata_pelajaran_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/nilai_siswa/nilai_akhir_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/nilai_siswa/nilai_latsol_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/nilai_siswa/nilai_tugas_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/nilai_siswa/nilai_ujian_sumatif.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/nilai_siswa/sumatif_lingkup_materi.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/rubrik_mapel/rubrik_mapel_screen.dart';
import 'package:elearning_sman2sidoarjo/presentation/features/staff/tahun_ajaran/tahun_ajaran_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/auth/screen/login_screen.dart';
import '../../presentation/features/init/splash_screen.dart';
import '../../presentation/features/landing_page/screens/landing_page.dart';
import '../../presentation/features/main_page.dart';
import '../../presentation/features/siswa/kelas/materi/detail_materi.dart';
import '../../presentation/features/siswa/kelas/tugas/detail_tugas.dart';
import '../../presentation/features/siswa/kelas/tugas/edit_pengumpulan_tugas.dart';
import '../helper/shared_pref_helper.dart';
import 'routes_name.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: _getInitialRoute(),

    /// =======================
    /// GLOBAL REDIRECT
    /// =======================
    redirect: (context, state) async {
      final roleString = await SharedPrefHelper.getRole();
      final role = roleString != null ? roleString.toUserRole() : null;

      final isLoggedIn = role != null;
      final isLoginPage = state.matchedLocation == RoutesNames.login;
      final isProtectedRoute = state.matchedLocation.startsWith('/main');

      /// ❌ Belum login tapi akses /main
      if (!isLoggedIn && isProtectedRoute) {
        return RoutesNames.landing;
      }

      /// ✅ Sudah login tapi masih di login page
      if (isLoggedIn && isLoginPage) {
        return RoutesNames.main;
      }

      return null;
    },

    routes: [
      /// =======================
      /// PUBLIC ROUTES
      /// =======================
      GoRoute(
        path: RoutesNames.landing,
        builder: (context, state) => const ElearningLandingPage(),
      ),
      GoRoute(
        path: RoutesNames.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutesNames.login,
        builder: (context, state) {
          final roleUser = state.extra as UserRole;
          return LoginScreen(roleUser: roleUser);
        },
      ),

      /// =======================
      /// MAIN (PROTECTED)
      /// =======================
      ShellRoute(
        builder: (context, state, child) {
          return MainPage(child: child);
        },
        routes: [
          /// 🔥 HANDLE /main BIAR GAK KOSONG
          GoRoute(
            path: RoutesNames.main,
            redirect: (context, state) async {
              final roleString = await SharedPrefHelper.getRole();
              final role = roleString != null ? roleString.toUserRole() : null;

              if (role == UserRole.staff) return RoutesNames.dataGuru;
              if (role == UserRole.admin) return RoutesNames.dataSiswa;
              if (role == UserRole.guru) return RoutesNames.kelasGuru;
              if (role == UserRole.siswa) return RoutesNames.kelasSiswa;

              return RoutesNames.landing;
            },
          ),

          /// =======================
          /// STAFF
          /// =======================
          GoRoute(
            path: RoutesNames.dataGuru,
            builder: (context, state) => const DataGuruScreen(),
          ),
          GoRoute(
            path: RoutesNames.dataSiswa,
            builder: (context, state) => const DataSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.jadwalAkademik,
            builder: (context, state) => const JadwalAkademikScreen(),
          ),
          GoRoute(
            path: RoutesNames.jadwalPelajaran,
            builder: (context, state) => const JadwalPelajaranScreen(),
          ),
          GoRoute(
            path: RoutesNames.kelas,
            builder: (context, state) => const KelasScreen(),
          ),
          GoRoute(
            path: RoutesNames.mataPelajaran,
            builder: (context, state) => const MataPelajaranScreen(),
          ),
          GoRoute(
            path: RoutesNames.rubrikMapelStaff,
            builder: (context, state) => const RubrikMapelStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailRubrikMapelStaff,
            builder: (context, state) => const RubrikMapelStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.tahunAjaran,
            builder: (context, state) => const TahunAjaranStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.nilaiLatsol,
            builder: (context, state) => const NilaiLatsolStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.nilaiTugas,
            builder: (context, state) => const NilaiTugasStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.sumatifLingkupMateri,
            builder: (context, state) => const NilaiSumatifLMStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.nilaiUjianSumatif,
            builder: (context, state) => const NilaiUjianSumatifStaffScreen(),
          ),
          GoRoute(
            path: RoutesNames.nilaiAkhir,
            builder: (context, state) => const NilaiAkhirStaffScreen(),
          ),

          /// =======================
          /// GURU
          /// =======================
          GoRoute(
            path: RoutesNames.kelasGuru,
            builder: (context, state) => const KelasGuruScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailKelas,
            builder: (context, state) => const DetailKelasScreen(),
          ),
          GoRoute(
            path: RoutesNames.tambahMateri,
            builder: (context, state) => const TambahMateriScreen(),
          ),
          GoRoute(
            path: RoutesNames.pratinjauMateri,
            builder: (context, state) => const PratinjauMateriScreen(),
          ),
          GoRoute(
            path: RoutesNames.editMateri,
            builder: (context, state) => const EditMateriScreen(),
          ),
          GoRoute(
            path: RoutesNames.tambahTugas,
            builder: (context, state) => const TambahTugasScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailTugas,
            builder: (context, state) => const DetailTugasScreen(),
          ),
          GoRoute(
            path: RoutesNames.editTugas,
            builder: (context, state) => const EditTugasScreen(),
          ),
          GoRoute(
            path: RoutesNames.penilaianTugas,
            builder: (context, state) => const BeriNilaiTugasScreen(),
          ),
          GoRoute(
            path: RoutesNames.kelolaUjian,
            builder: (context, state) => const KelolaUjianScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailPengerjaanUjian,
            builder: (context, state) => const LihatJawabanUjianScreen(),
          ),
          GoRoute(
            path: RoutesNames.listPengerjaanUjian,
            builder: (context, state) => const KontenDaftarPengerjaanUjian(),
          ),

          GoRoute(
            path: RoutesNames.jadwalMengajar,
            builder: (context, state) => const JadwalMengajarScreen(),
          ),
          GoRoute(
            path: RoutesNames.rubrikMapelKelas,
            builder: (context, state) => const RubrikMapelGuruScreen(),
          ),
          GoRoute(
            path: RoutesNames.nilaiAkhirKelas,
            builder: (context, state) => const NilaiAkhirKelasScreen(),
          ),

          /// =======================
          /// SISWA
          /// =======================
          GoRoute(
            path: RoutesNames.kelasSiswa,
            builder: (context, state) => const KelasSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.jadwalSiswa,
            builder: (context, state) => const JadwalPelajaranSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailKelasSiswa,
            builder: (context, state) => const DetailKelasSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailMateriSiswa,
            builder: (context, state) => const DetailMateriSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailTugasSiswa,
            builder: (context, state) => const DetailTugasSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.editTugasSiswa,
            builder: (context, state) =>
                const EditPengumpulanTugasSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.pengumpulanTugasSiswa,
            builder: (context, state) => const PengumpulanTugasSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.detailUjianSiswa,
            builder: (context, state) => const DetailUjianSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.soalUjianSiswa,
            builder: (context, state) => const SoalUjianSiswaScreen(),
          ),
          GoRoute(
            path: RoutesNames.jawabanUjianSiswa,
            builder: (context, state) => const LihatJawabanUjianSiswaScreen(),
          ),

          /// =======================
          /// ADMIN
          /// =======================
          GoRoute(
            path: RoutesNames.daftarStaff,
            builder: (context, state) => const StaffKurikulumScreen(),
          ),
          GoRoute(
            path: RoutesNames.logAktivitas,
            builder: (context, state) => const LogAktivitasScreen(),
          ),
        ],
      ),
    ],
  );

  static String _getInitialRoute() {
    if (kIsWeb) {
      return '/';
    } else {
      return RoutesNames.splashScreen;
    }
  }
}
