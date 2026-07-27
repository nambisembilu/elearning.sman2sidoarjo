import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/guru/kelas_guru_riverpod.dart';
import 'materi/konten_materi_widget.dart';
import 'siswa/konten_daftar_siswa.dart';
import 'tugas/widget/konten_tugas_widget.dart';
import 'ujian/konten_ujian.dart';

class DetailKelasScreen extends ConsumerStatefulWidget {
  const DetailKelasScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailKelasScreenState();
}

class _DetailKelasScreenState extends ConsumerState<DetailKelasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(kelasGuruNotifierProvider.notifier).setSelectedKmp();
      setState(
        () {},
      ); // 🔥 Tambahkan ini biar widget rebuild setelah selectedKmp berubah
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildKontenKelas(String konten) {
    final selectedKelas = ref
        .watch(kelasGuruNotifierProvider.notifier)
        .selectedKmp;

    if (selectedKelas == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (konten == 'Materi') {
        return SingleChildScrollView(
          child: KontenMateriWidget(
            namaKelas: selectedKelas.namaKelas,
            kelasMapelId: selectedKelas.kelasMapelId,
            // addAction: () {},
          ),
        );
      } else if (konten == 'Tugas') {
        return SingleChildScrollView(
          child: KontenTugasWidget(
            namaKelas: selectedKelas.namaKelas,
            kelasMapelId: selectedKelas.kelasMapelId,
            // addAction: () {},
          ),
        );
      } else if (konten == 'Ujian') {
        return SingleChildScrollView(
          child: KontenUjianKelasMapelWidget(
            namaKelas: selectedKelas.namaKelas,
            kelasMapelId: selectedKelas.kelasMapelId,
          ),
        );
      } else if (konten == 'Siswa') {
        return SingleChildScrollView(
          child: KontenSiswaKelasMapelWidget(
            namaKelas: selectedKelas.namaKelas,
            kelasMapelId: selectedKelas.kelasMapelId,
          ),
        );
      }
      // else if (konten == 'Kelompok') {
      //   return SingleChildScrollView(
      //     child: KontenKelompokWidget(
      //       namaKelas: selectedKelas.namaKelas,
      //       kelasMapelId: selectedKelas.kelasMapelId,
      //     ),
      //   );
      // }
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final selectedKelas = ref
        .watch(kelasGuruNotifierProvider.notifier)
        .selectedKmp;

    if (selectedKelas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xff016EB3),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade700,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(child: Text("Materi")),
                  Tab(child: Text("Tugas")),
                  Tab(child: Text("Ujian")),
                  Tab(child: Text("Siswa")),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildKontenKelas('Materi'),
                  _buildKontenKelas('Tugas'),
                  _buildKontenKelas('Ujian'),
                  _buildKontenKelas('Siswa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
