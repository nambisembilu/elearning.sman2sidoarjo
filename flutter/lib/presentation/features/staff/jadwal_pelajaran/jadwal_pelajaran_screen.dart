// ignore_for_file: avoid_print

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../models/staff/jadwal_pelajaran_model.dart';
import '../../../controllers/staff/jadwal_mapel_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown_widget_2.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';
import 'widget/dialog_tambah_jadwal_mapel.dart';

class JadwalPelajaranScreen extends ConsumerStatefulWidget {
  const JadwalPelajaranScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _JadwalPelajaranScreenState();
}

class _JadwalPelajaranScreenState extends ConsumerState<JadwalPelajaranScreen>
    with SingleTickerProviderStateMixin {
  String? selectedTahunAjaran;
  String? selectedKelas;

  List<TahunAjaran> tahunAjaranList = [];
  List<KelasByTahunAjaran> kelasList = [];

  late TabController _tabController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Panggil init filter saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFilters();
    });
  }

  // Method untuk mengubah tab bar berdasarkan hari
  void _changeTabByHari(String hari) {
    final hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
    final index = hariList.indexWhere(
      (h) => h.toLowerCase() == hari.toLowerCase(),
    );
    if (index != -1) {
      _tabController.animateTo(index);
    }
  }

  // Method untuk mengubah filter kelas berdasarkan kelasId
  Future<void> _changeKelasFilterByKelasId(int kelasId) async {
    final kelas = kelasList.firstWhere(
      (k) => k.id == kelasId,
      orElse: () => KelasByTahunAjaran(id: -1, namaKelas: '', jurusan: ''),
    );

    if (kelas.id != -1) {
      await _onKelasChanged(kelas.id.toString());
    }
  }

  Future<void> _initFilters() async {
    try {
      final notifier = ref.read(jadwalMapelRiverpodProvider.notifier);

      // 1. Ambil Tahun Ajaran
      final ta = await notifier.fetchTahunAjaran();
      if (ta.isEmpty) {
        setState(() => _isInitializing = false);
        return;
      }

      setState(() {
        tahunAjaranList = ta;
        selectedTahunAjaran = ta.first.id.toString();
      });

      // 2. Ambil Kelas dari tahun ajaran pertama
      final kls = await notifier.fetchKelasByTahunAjaran(ta.first.id);
      if (kls.isEmpty) {
        setState(() => _isInitializing = false);
        return;
      }

      setState(() {
        kelasList = kls;
        selectedKelas = kls.first.id.toString();
      });

      // 3. Fetch Jadwal Mapel
      await notifier.fetchJadwalMapel(
        tahun_ajaran_id: ta.first.id,
        kelas_id: kls.first.id,
      );
    } catch (e) {
      print("Error initializing filters: $e");
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _onTahunAjaranChanged(String? newValue) async {
    if (newValue == null) return;

    setState(() {
      selectedTahunAjaran = newValue;
      selectedKelas = null;
      kelasList = [];
    });

    final notifier = ref.read(jadwalMapelRiverpodProvider.notifier);

    try {
      // ambil kelas berdasarkan tahun ajaran baru
      final kls = await notifier.fetchKelasByTahunAjaran(int.parse(newValue));

      setState(() {
        kelasList = kls;
        selectedKelas = kls.isNotEmpty ? kls.first.id.toString() : null;
      });

      // fetch jadwal pakai filter baru
      if (kls.isNotEmpty) {
        await notifier.fetchJadwalMapel(
          tahun_ajaran_id: int.parse(newValue),
          kelas_id: kls.first.id,
        );
      } else {
        // Jika tidak ada kelas, reset jadwal
        ref.read(jadwalMapelRiverpodProvider.notifier).reset();
      }
    } catch (e) {
      print("Error changing tahun ajaran: $e");
    }
  }

  Future<void> _onKelasChanged(String? newValue) async {
    if (newValue == null || selectedTahunAjaran == null) return;

    setState(() => selectedKelas = newValue);

    final notifier = ref.read(jadwalMapelRiverpodProvider.notifier);

    try {
      await notifier.fetchJadwalMapel(
        tahun_ajaran_id: int.parse(selectedTahunAjaran!),
        kelas_id: int.parse(newValue),
      );
    } catch (e) {
      print("Error changing kelas: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildJadwalHari(
    String hari,
    AsyncValue<List<JadwalMataPelajaran>> jadwalMapelState,
  ) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return jadwalMapelState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (jadwalMapelList) {
        // Filter jadwal berdasarkan hari
        final jadwalHariIni = jadwalMapelList
            .where((jadwal) => jadwal.hari.toLowerCase() == hari.toLowerCase())
            .toList();

        if (jadwalHariIni.isEmpty) {
          return Center(
            child: Text("Tidak ada jadwal pelajaran untuk hari $hari"),
          );
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black26, width: 1.2),
            ),
            clipBehavior: Clip.hardEdge,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          width: 1,
                          color: Colors.black26,
                        ),
                      ),
                      columnWidths: const <int, TableColumnWidth>{
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                        2: IntrinsicColumnWidth(),
                        3: FixedColumnWidth(50),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        const TableRow(
                          children: [
                            TableHeaderCell("Waktu"),
                            TableHeaderCell("Mata Pelajaran"),
                            TableHeaderCell("Guru"),
                            TableHeaderCell("Aksi"),
                          ],
                        ),
                        for (final jadwalMapel in jadwalHariIni)
                          TableRow(
                            children: [
                              TableCellWidget(jadwalMapel.waktu),
                              TableCellWidget(jadwalMapel.mataPelajaran),
                              TableCellWidget(jadwalMapel.guru),
                              IconButton(
                                onPressed: () {
                                  // abaikan dulu
                                  showDialog(
                                    context: context,
                                    builder: (context) => DialogKonfirmasiWidget(
                                      confirmText:
                                          "Apakah anda yakin ingin menghapus jadwal?",
                                      confirmAction: () async {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        try {
                                          final success = await ref
                                              .read(
                                                jadwalMapelRiverpodProvider
                                                    .notifier,
                                              )
                                              .deleteJadwalAkademik(
                                                jadwalMapelId: jadwalMapel.id,
                                              );
                                          Navigator.pop(context);

                                          if (success) {
                                            // Close dialog
                                            Navigator.pop(context);

                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  DialogSuccessWidget(
                                                    succesText:
                                                        "Jadwal pelajaran berhasil dihapus",
                                                  ),
                                            );
                                          }
                                        } catch (e) {
                                          // Remove loading indicator
                                          Navigator.pop(context);

                                          showDialog(
                                            context: context,
                                            builder: (context) => DialogErrorWidget(
                                              errorText:
                                                  'Gagal menghapus jadwal pelajaran: ${e.toString()}',
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Symbols.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jadwalMapelState = ref.watch(jadwalMapelRiverpodProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "JADWAL PELAJARAN",
              btnAddTitle: "Tambah Jadwal Pelajaran",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: true,
              addAction: () {
                showDialog(
                  context: context,
                  builder: (context) => DialogTambahOrEditJadwalMapel(
                    dataJadwalMapel: null,
                    onSuccess: (hari, kelasId) {
                      // Setelah dialog tertutup, ubah tab bar dan filter
                      _changeTabByHari(hari);
                      _changeKelasFilterByKelasId(kelasId);
                    },
                  ),
                );
              },
              exportAction: () {
                // abaikan dulu
              },
              importAction: () {
                // abaikan dulu
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Header2Widget(
                        header2Title: "Jadwal Pelajaran",
                        subtitle:
                            "Lihat dan kelola jadwal pelajaran setiap kelas",
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Filter :",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilterDropdownWidget2(
                            pHintText: "Semua Tahun Ajaran",
                            widhtDropdown: 210,
                            valueParams: selectedTahunAjaran,
                            pItems: tahunAjaranList
                                .map(
                                  (e) => DropdownItem(
                                    value: e.id.toString(),
                                    child: Text(
                                      e.tahunAjaran,
                                    ), // PERBAIKAN: ganti e.nama menjadi e.tahunAjaran
                                  ),
                                )
                                .toList(),
                            pOnChanged: _onTahunAjaranChanged,
                          ),
                          const SizedBox(width: 10),
                          FilterDropdownWidget2(
                            pHintText: "Semua Kelas",
                            valueParams: selectedKelas,
                            pItems: kelasList
                                .map(
                                  (e) => DropdownItem(
                                    value: e.id.toString(),
                                    child: Text(e.namaKelas),
                                  ),
                                )
                                .toList(),
                            pOnChanged: _onKelasChanged,
                            widhtDropdown: 180,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        Tab(child: Text("Senin")),
                        Tab(child: Text("Selasa")),
                        Tab(child: Text("Rabu")),
                        Tab(child: Text("Kamis")),
                        Tab(child: Text("Jumat")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    // height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildJadwalHari('Senin', jadwalMapelState),
                        _buildJadwalHari('Selasa', jadwalMapelState),
                        _buildJadwalHari('Rabu', jadwalMapelState),
                        _buildJadwalHari('Kamis', jadwalMapelState),
                        _buildJadwalHari('Jumat', jadwalMapelState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
