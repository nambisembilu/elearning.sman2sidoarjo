import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../models/staff/filtering_model.dart';
import '../../../../models/staff/rubrik_mapel_model.dart';
import '../../../controllers/staff/rubrik_mapel/rubrik_mapel_riverpod.dart';
import '../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../shared_widgets/general_old/filter_dropdown.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../../shared_widgets/general_old/table_cell.dart';
import '../../../shared_widgets/general_old/table_header_cell.dart';

class RubrikMapelStaffScreen extends ConsumerStatefulWidget {
  const RubrikMapelStaffScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RubrikMapelStaffScreenState();
}

class _RubrikMapelStaffScreenState extends ConsumerState<RubrikMapelStaffScreen> {
  String? selectedMapel;
  String? selectedTahunAjaran;

  int? selectedMapelId;
  int? selectedTahunAjaranId;

  bool _isInitializing = true;

  List<MataPelajaran2> listMapelDiampu = [];
  List<TahunAjaran> listTahunAjaran = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // await _loadKoor();
      await _loadTahunAjaran();
      await _loadMapelDiampu();
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  // Future<void> _loadKoor() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('user_id');
  //   if (mounted) {
  //     setState(() {
  //       if()
  //       isKoor = prefs.getBool('isKoor') ?? false;
  //     });
  //   }
  // }

  // benerin ya sin
  Future<void> _loadMapelDiampu() async {
    try {
      final list = await ref
          .read(rubrikMapelRiverpodProvider.notifier)
          .fetchMapelDiampu();

      if (!mounted) return;

      setState(() {
        listMapelDiampu = list;
        if (listMapelDiampu.isNotEmpty) {
          selectedMapel = listMapelDiampu.first.judulMapel;
          selectedMapelId = listMapelDiampu.first.mapelId;
        }
      });

      // Hanya panggil resetAndFetch jika mapelId tersedia
      if (selectedMapelId != null) {
        await ref
            .read(rubrikMapelRiverpodProvider.notifier)
            .resetAndFetch(
              mapelId: selectedMapelId!,
              search: '',
              page: 1,
              tahunAjaranId: selectedTahunAjaranId!,
            );
      }
    } catch (e) {
      print("Error loading mapel diampu: $e");
      if (mounted) {
        setState(() {
          listMapelDiampu = [];
        });
      }
    }
  }

  Future<void> _loadTahunAjaran() async {
    try {
      final list = await ref
          .read(rubrikMapelRiverpodProvider.notifier)
          .fetchTahunAjaran();

      if (!mounted) return;

      setState(() {
        listTahunAjaran = list;
        final listTahunAjaranAktif = list
            .where((e) => e.isActive == 'true')
            .toList();
        if (listTahunAjaran.isNotEmpty) {
          selectedTahunAjaran = listTahunAjaranAktif.first.tahunAjaran;
          selectedTahunAjaranId = listTahunAjaranAktif.first.id;
        }
      });

      // Hanya panggil resetAndFetch jika mapelId tersedia
      if (selectedMapelId != null && selectedTahunAjaranId != null) {
        await ref
            .read(rubrikMapelRiverpodProvider.notifier)
            .resetAndFetch(
              mapelId: selectedMapelId!,
              search: '',
              page: 1,
              tahunAjaranId: selectedMapelId!,
            );
      }
    } catch (e) {
      print("Error loading mapel diampu: $e");
      if (mounted) {
        setState(() {
          listTahunAjaran = [];
        });
      }
    }
  }

  void _navigateToKelolaRubrik() {
    context.go(
      '/dashboard/guru/rubrik-mata-pelajaran/kelola-rubrik',
      // extra: true, // Mark as coming from detail screen
    );
  }

  @override
  Widget build(BuildContext context) {
    final rubrikMapelState = ref.watch(rubrikMapelRiverpodProvider);
    final rubrikMapelNotifier = ref.watch(rubrikMapelRiverpodProvider.notifier);

    // Tampilkan loading selama inisialisasi
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tampilkan pesan jika tidak ada mapel yang diampu
    if (listMapelDiampu.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Tidak ada mata pelajaran yang diampu.",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      const Header2Widget(
                        header2Title: "Rubrik Mata Pelajaran",
                        subtitle:
                            "Lihat lingkup materi dan tujuan pembelajaran.",
                      ),
                      if (rubrikMapelNotifier.isKoorMapel == true)
                        ElevatedButton.icon(
                          onPressed: () {
                            _navigateToKelolaRubrik();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff016EB3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: const Size(120, 50),
                          ),
                          icon: const Icon(Symbols.add_circle),
                          label: const Text("Perbarui"),
                        ),
                      if (rubrikMapelNotifier.rubrikMapelList.isEmpty)
                        ElevatedButton.icon(
                          onPressed: () {
                            _navigateToKelolaRubrik();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff016EB3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: const Size(120, 50),
                          ),
                          icon: const Icon(Symbols.add_circle),
                          label: const Text("Tambah"),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "[ Koordinator Mata Pelajaran : ${rubrikMapelNotifier.koorMapel} ]",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 157),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Symbols.info),
                        SizedBox(width: 20),
                        Text(
                          "Rubrik mata pelajaran hanya bisa dikelola oleh koordinator mata pelajaran dan hanya dapat diubah saat tahun ajaran berganti.",
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan lingkup materi...",
                        onChangedSearch: (value) {
                          if (selectedMapelId != null) {
                            ref
                                .read(rubrikMapelRiverpodProvider.notifier)
                                .resetAndFetch(
                                  mapelId: selectedMapelId!,
                                  search: value,
                                  page: 1,
                                  tahunAjaranId: selectedTahunAjaranId!,
                                );
                          }
                        },
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
                          FilterDropdownWidget(
                            pHintText: "Semua Mata Pelajaran",
                            valueParams: selectedMapel,
                            pItems: listMapelDiampu
                                .map((e) => e.judulMapel)
                                .toList(),
                            pOnChanged: (value) async {
                              if (value != null) {
                                final selected = listMapelDiampu.firstWhere(
                                  (e) => e.judulMapel == value,
                                );

                                setState(() {
                                  selectedMapel = selected.judulMapel;
                                  selectedMapelId = selected.mapelId;
                                });

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setInt(
                                  'mapel_id',
                                  selectedMapelId!,
                                );

                                ref
                                    .read(rubrikMapelRiverpodProvider.notifier)
                                    .resetAndFetch(
                                      mapelId: selectedMapelId!,
                                      page: 1,
                                      tahunAjaranId: selectedTahunAjaranId!,
                                    );
                              }
                            },
                            widhtDropdown: 200,
                          ),
                          SizedBox(width: 10),
                          FilterDropdownWidget(
                            pHintText: "Semua Tahun Ajaran",
                            valueParams: selectedTahunAjaran,
                            pItems: listTahunAjaran
                                .map((e) => e.tahunAjaran)
                                .toList(),
                            pOnChanged: (value) async {
                              if (value != null) {
                                final selected = listTahunAjaran.firstWhere(
                                  (e) => e.tahunAjaran == value,
                                );

                                setState(() {
                                  selectedTahunAjaran = selected.tahunAjaran;
                                  selectedTahunAjaranId = selected.id;
                                });

                                ref
                                    .read(rubrikMapelRiverpodProvider.notifier)
                                    .resetAndFetch(
                                      mapelId: selectedMapelId!,
                                      page: 1,
                                      tahunAjaranId: selectedTahunAjaranId!,
                                    );
                              }
                            },
                            widhtDropdown: 200,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  rubrikMapelState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final errorMsg =
                            err.toString().contains("PostgrestException")
                            ? err
                                  .toString()
                                  .split("message:")
                                  .last
                                  .split(",")
                                  .first
                                  .trim()
                            : err.toString();

                        showDialog(
                          context: context,
                          builder: (context) =>
                              DialogErrorWidget(errorText: 'Error : $errorMsg'),
                        );
                      });

                      final cachedData = ref
                          .read(rubrikMapelRiverpodProvider.notifier)
                          .rubrikMapelList;

                      return buildRubrikMapelTabel(
                        context,
                        cachedData,
                        ref,
                        selectedMapelId ?? 0, // Default value jika null
                        selectedTahunAjaranId ?? 0,
                      );
                    },
                    data: (rubrikList) => buildRubrikMapelTabel(
                      context,
                      rubrikList,
                      ref,
                      selectedMapelId ?? 0, // Default value jika null
                      selectedTahunAjaranId ?? 0,
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

// ... (fungsi _buildPaginationButtons, _pageButton, dan buildRubrikMapelTabel tetap sama)

/// =====================
/// Pagination Helpers
/// =====================
List<Widget> _buildPaginationButtons(
  int totalPage,
  int currentPage,
  void Function(int) onPageSelected,
) {
  List<Widget> buttons = [];

  if (totalPage <= 5) {
    // Kalau halaman sedikit, tampil semua
    for (int i = 1; i <= totalPage; i++) {
      buttons.add(_pageButton(i, currentPage, onPageSelected));
    }
  } else {
    // Selalu tampilkan halaman 1
    buttons.add(_pageButton(1, currentPage, onPageSelected));

    // Ellipsis awal
    if (currentPage > 4) {
      buttons.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text("..."),
        ),
      );
    }

    // Halaman sekitar currentPage
    int start = (currentPage - 1).clamp(2, totalPage - 3);
    int end = (currentPage + 1).clamp(4, totalPage - 1);

    for (int i = start; i <= end; i++) {
      buttons.add(_pageButton(i, currentPage, onPageSelected));
    }

    // Ellipsis akhir
    if (currentPage < totalPage - 3) {
      buttons.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text("..."),
        ),
      );
    }

    // Halaman terakhir
    buttons.add(_pageButton(totalPage, currentPage, onPageSelected));
  }

  return buttons;
}

Widget _pageButton(int i, int currentPage, void Function(int) onPageSelected) {
  final bool isActive = i == currentPage;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2.0),
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : null,
        foregroundColor: isActive ? Colors.white : Colors.black,
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => onPageSelected(i),
      child: Text("$i"),
    ),
  );
}

Widget buildRubrikMapelTabel(
  BuildContext context,
  List<RubrikMapel> rubrikMapelList,
  WidgetRef ref,
  int mapelId,
  int tahunAjaranId,
) {
  if (rubrikMapelList.isEmpty) {
    return const Center(child: Text("Data tidak tersedia."));
  }

  final notifier = ref.read(rubrikMapelRiverpodProvider.notifier);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black26, width: 1.2), // border luar
        ),
        clipBehavior: Clip.hardEdge, // penting biar isi ikut radius
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
                    ), // garis antar baris
                    // tidak pakai left/right/top/bottom supaya tidak double border
                  ),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FixedColumnWidth(150),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      // decoration: BoxDecoration(
                      //   color: Colors.grey.shade200,
                      // ),
                      children: const [
                        TableHeaderCell("Lingkup Materi"),
                        TableHeaderCell("Jumlah Tujuan Pembelajaran"),
                        TableHeaderCell("Aksi"),
                      ],
                    ),
                    for (final rubrik in rubrikMapelList)
                      TableRow(
                        children: [
                          TableCellWidget(rubrik.lingkupMateri),
                          TableCellWidget(rubrik.jumlahTP.toString()),
                          InkWell(
                            onTap: () {
                              // navigasi ke detail rubrik
                              _showDetailDialog(context, rubrik);
                            },
                            child: Text("Lihat Detail"),
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
      const SizedBox(height: 16),

      /// Pagination
      LayoutBuilder(
        builder: (context, constraints) {
          // Gunakan breakpoint 600px untuk menentukan layout
          if (constraints.maxWidth < 600) {
            // Layout untuk layar kecil (mobile)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teks informasi di atas
                Text(
                  "Menampilkan ${rubrikMapelList.length} dari ${notifier.total} data",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Kontrol pagination di bawah
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: notifier.currentPage > 1
                            ? () => notifier.fetchPreviousPage()
                            : null,
                        child: const Text("Sebelumnya"),
                      ),
                      const SizedBox(width: 8),

                      /// Pagination dengan ellipsis
                      ..._buildPaginationButtons(
                        notifier.totalPage,
                        notifier.currentPage,
                        (page) => notifier.resetAndFetch(
                          page: page,
                          mapelId: mapelId,
                          tahunAjaranId: tahunAjaranId,
                        ),
                      ),

                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: notifier.hasMore
                            ? () => notifier.fetchNextPage()
                            : null,
                        child: const Text("Selanjutnya"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Layout untuk layar besar (desktop)
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menampilkan ${rubrikMapelList.length} dari ${notifier.total} data",
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: notifier.currentPage > 1
                          ? () => notifier.fetchPreviousPage()
                          : null,
                      child: const Text("Sebelumnya"),
                    ),
                    const SizedBox(width: 8),

                    /// Pagination dengan ellipsis
                    ..._buildPaginationButtons(
                      notifier.totalPage,
                      notifier.currentPage,
                      (page) => notifier.resetAndFetch(
                        page: page,
                        mapelId: mapelId,
                        tahunAjaranId: tahunAjaranId,
                      ),
                    ),

                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: notifier.hasMore
                          ? () => notifier.fetchNextPage()
                          : null,
                      child: const Text("Selanjutnya"),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    ],
  );
}

// 2. Tambahkan fungsi _showDetailDialog:
void _showDetailDialog(BuildContext context, RubrikMapel rubrik) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 700,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rubrik.lingkupMateri,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${rubrik.jumlahTP} Tujuan Pembelajaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (rubrik.statusKunci)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rubrik terkunci - tidak dapat diubah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const Text(
                        'Tujuan Pembelajaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (rubrik.tujuanPembelajaran.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Belum ada tujuan pembelajaran',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...rubrik.tujuanPembelajaran.map((tp) {
                          return _buildTPCard(tp);
                        }).toList(),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// 3. Tambahkan fungsi _buildTPCard:
Widget _buildTPCard(Map<String, dynamic> tp) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Colors.grey[200]!, width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul TP
          Text(
            tp['judul_default']?.toString() ?? 'Tujuan Pembelajaran',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),

          // Deskripsi
          if (tp['deskripsi'] != null && tp['deskripsi'].toString().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tp['deskripsi'].toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
              ],
            ),

          // Kriteria Penilaian
          const Text(
            'Kriteria Penilaian:',
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),

          // Perlu Bimbingan
          if (tp['perlu_bimbingan'] != null)
            _buildKriteriaItem(
              'Perlu Bimbingan',
              tp['perlu_bimbingan'].toString(),
              Colors.red,
            ),

          // Cukup
          if (tp['cukup'] != null)
            _buildKriteriaItem('Cukup', tp['cukup'].toString(), Colors.orange),

          // Baik
          if (tp['baik'] != null)
            _buildKriteriaItem('Baik', tp['baik'].toString(), Colors.blue),

          // Sangat Baik
          if (tp['sangat_baik'] != null)
            _buildKriteriaItem(
              'Sangat Baik',
              tp['sangat_baik'].toString(),
              Colors.green,
            ),
        ],
      ),
    ),
  );
}

// 4. Tambahkan fungsi _buildKriteriaItem:
Widget _buildKriteriaItem(String title, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6, right: 8),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    ),
  );
}
