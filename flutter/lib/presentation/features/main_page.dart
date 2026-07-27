import 'package:elearning_sman2sidoarjo/core/helper/shared_pref_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/role_user_enum.dart';
import '../../core/routes/routes_name.dart';
import 'auth/cubit/auth_cubit.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UserRole? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final roleString = await SharedPrefHelper.getRole();

    if (roleString != null) {
      setState(() {
        role = roleString.toUserRole();
      });
    }
  }

  Future<bool> _showExitDialog() async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: const Text("Apakah ingin logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Tidak"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = kIsWeb && MediaQuery.of(context).size.width > 900;

    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: isDesktop ? null : AppBar(title: const Text("E-Learning")),

        drawer: isDesktop ? null : Drawer(child: _buildSidebar()),

        body: Row(
          children: [
            if (isDesktop)
              Container(
                width: 250,
                color: Colors.white,
                child: _buildSidebar(),
              ),

            Expanded(child: widget.child),
          ],
        ),
      ),
    );
  }

  /// =======================
  /// SIDEBAR
  /// =======================
  Widget _buildSidebar() {
    final menus = _getMenusByRole(role!);

    return ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(role!.name.toUpperCase()),
          accountEmail: const Text("user@email.com"),
          currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
        ),

        ...menus.map((menu) {
          return ListTile(
            leading: Icon(menu.icon),
            title: Text(menu.title),
            onTap: () => context.go(menu.route),
          );
        }),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout"),
          onTap: () async {
            context.read<AuthCubit>().logout();
            context.go(RoutesNames.landing);
          },
        ),
      ],
    );
  }

  List<_Menu> _getMenusByRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          _Menu(
            "Daftar Staff Kurikulum",
            Icons.person_2,
            RoutesNames.daftarStaff,
          ),
          _Menu("Log Aktivitas", Icons.timelapse, RoutesNames.logAktivitas),
        ];

      case UserRole.staff:
        return [
          _Menu("Data Guru", Icons.person, RoutesNames.dataGuru),
          _Menu("Data Siswa", Icons.person_2, RoutesNames.dataSiswa),
          _Menu("Kelas", Icons.class_, RoutesNames.kelas),
          _Menu("Mata Pelajaran", Icons.subject, RoutesNames.mataPelajaran),
          _Menu(
            "Jadwal Akademik",
            Icons.calendar_month,
            RoutesNames.jadwalAkademik,
          ),
          _Menu(
            "Jadwal Pelajaran",
            Icons.schedule,
            RoutesNames.jadwalPelajaran,
          ),
          _Menu(
            "Rubrik Mata Pelajaran",
            Icons.table_chart,
            RoutesNames.rubrikMapelStaff,
          ),
          _Menu("Tahun Ajaran", Icons.book, RoutesNames.tahunAjaran),
          _Menu("Nilai Latihan Soal", Icons.score, RoutesNames.nilaiLatsol),
          _Menu("Nilai Tugas", Icons.score, RoutesNames.nilaiTugas),
          _Menu(
            "Sumatif Lingkup Materi",
            Icons.score,
            RoutesNames.sumatifLingkupMateri,
          ),
          _Menu(
            "Nilai Ujian Sumatif",
            Icons.score,
            RoutesNames.nilaiUjianSumatif,
          ),
          _Menu("Nilai Akhir", Icons.score, RoutesNames.nilaiAkhir),
        ];

      case UserRole.guru:
        return [
          _Menu("Kelas", Icons.calendar_month, RoutesNames.kelasGuru),
          _Menu("Jadwal Mengajar", Icons.schedule, RoutesNames.jadwalMengajar),
          _Menu(
            "Rubrik Mata Pelajaran",
            Icons.schedule,
            RoutesNames.rubrikMapelKelas,
          ),
          _Menu("Nilai Akhir", Icons.schedule, RoutesNames.nilaiAkhir),
        ];

      case UserRole.siswa:
        return [
          _Menu("Kelas", Icons.class_, RoutesNames.kelasSiswa),
          _Menu("Jadwal Pelajaran", Icons.book, RoutesNames.jadwalSiswa),
        ];
    }
  }
}

class _Menu {
  final String title;
  final IconData icon;
  final String route;

  _Menu(this.title, this.icon, this.route);
}
