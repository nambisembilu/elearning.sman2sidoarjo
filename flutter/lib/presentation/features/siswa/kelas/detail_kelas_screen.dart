import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/siswa/kelas/kelas_siswa_riverpod.dart';
import 'materi/konten_materi.dart';
import 'tugas/konten_tugas.dart';
import 'ujian/konten_ujian.dart';

class DetailKelasSiswaScreen extends ConsumerStatefulWidget {
  const DetailKelasSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailKelasSiswaScreenState();
}

class _DetailKelasSiswaScreenState extends ConsumerState<DetailKelasSiswaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(kelasSiswaNotifierProvider.notifier).setSelectedKmp();
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
        .watch(kelasSiswaNotifierProvider.notifier)
        .selectedKmp;

    if (selectedKelas == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      if (konten == 'Materi') {
        return SingleChildScrollView(
          child: KontenMateriWidget(
            namaKelas: selectedKelas.judulMapel,
            kelasMapelId: selectedKelas.kelasMapelId,
            // addAction: () {},
          ),
        );
      } else if (konten == 'Tugas') {
        return SingleChildScrollView(
          child: KontenTugasWidget(
            namaKelas: selectedKelas.judulMapel,
            kelasMapelId: selectedKelas.kelasMapelId,
            // addAction: () {},
          ),
        );
      } else if (konten == "Ujian") {
        return SingleChildScrollView(
          child: KontenUjianKelasMapelWidget(
            namaKelas: selectedKelas.judulMapel,
            kelasMapelId: selectedKelas.kelasMapelId,
          ),
        );
      }
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final selectedKelas = ref
        .watch(kelasSiswaNotifierProvider.notifier)
        .selectedKmp;

    if (selectedKelas == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
