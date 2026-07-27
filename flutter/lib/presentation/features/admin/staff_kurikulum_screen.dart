import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../shared_widgets/general_old/dialog_konfirmasi_widget.dart';
import '../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../shared_widgets/general_old/header2_widget.dart';
import '../../shared_widgets/general_old/header_widget.dart';
import '../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../shared_widgets/general_old/table_cell.dart';
import '../../shared_widgets/general_old/table_header_cell.dart';

class StaffKurikulumScreen extends StatefulWidget {
  const StaffKurikulumScreen({super.key});

  @override
  State<StaffKurikulumScreen> createState() => _StaffKurikulumScreenState();
}

class _StaffKurikulumScreenState extends State<StaffKurikulumScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> staffKurikulumList = [];
  List<Map<String, dynamic>> guruList = [];

  int currentPage = 1;
  int totalPage = 1;
  int totalItems = 0;

  bool isLoading = true;
  bool isLoadingGuru = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStaffKurikulum();
    fetchGuruNonStaff();
  }

  Future<void> fetchStaffKurikulum({int page = 1, String search = ''}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.rpc(
        'get_all_staff_kurikulum',
        params: {'p_page': page, 'p_search': search},
      );

      if (response != null) {
        setState(() {
          staffKurikulumList = List<Map<String, dynamic>>.from(
            response['data'] ?? [],
          );
          currentPage = response['page'] ?? 1;
          totalPage = response['total_page'] ?? 1;
          totalItems = response['total'] ?? 0;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) =>
            DialogErrorWidget(errorText: 'Error: ${e.toString()}'),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchGuruNonStaff() async {
    setState(() {
      isLoadingGuru = true;
    });

    try {
      final response = await supabase.rpc('get_guru_non_staff_kurikulum');

      if (response != null) {
        setState(() {
          guruList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching guru: $e');
    } finally {
      setState(() {
        isLoadingGuru = false;
      });
    }
  }

  Future<void> deleteStaffKurikulum(int staffKurikulumId) async {
    try {
      await supabase.rpc(
        'delete_staff_kurikulum',
        params: {'p_staff_kurikulum_id': staffKurikulumId},
      );

      // Tutup loading dialog terlebih dahulu
      Navigator.of(context, rootNavigator: true).pop();

      // Tunggu sedikit sebelum menampilkan dialog sukses
      await Future.delayed(const Duration(milliseconds: 100));

      // Tampilkan dialog sukses
      showDialog(
        context: context,
        builder: (context) =>
            DialogSuccessWidget(succesText: 'Staff berhasil dihapus'),
      );

      // Refresh data setelah dialog sukses ditutup
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context, rootNavigator: true).pop(); // Tutup dialog sukses
        fetchStaffKurikulum(page: currentPage, search: searchController.text);
      });
    } catch (e) {
      // Tutup loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Tampilkan error
      showDialog(
        context: context,
        builder: (context) =>
            DialogErrorWidget(errorText: 'Error: ${e.toString()}'),
      );
    }
  }

  Future<void> addStaffKurikulum(int userId) async {
    try {
      await supabase.rpc('add_staff_kurikulum', params: {'p_user_id': userId});

      // Tutup loading dialog terlebih dahulu
      Navigator.of(context, rootNavigator: true).pop();

      // Tunggu sedikit sebelum menampilkan dialog sukses
      await Future.delayed(const Duration(milliseconds: 100));

      Navigator.pop(context);
      // Tampilkan dialog sukses
      showDialog(
        context: context,
        builder: (context) =>
            DialogSuccessWidget(succesText: 'Staff berhasil ditambahkan'),
      );

      // Refresh data setelah dialog sukses ditutup
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context, rootNavigator: true).pop(); // Tutup dialog sukses
        fetchStaffKurikulum(page: currentPage, search: searchController.text);
        fetchGuruNonStaff(); // Refresh daftar guru
      });
    } catch (e) {
      // Tutup loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Tampilkan error
      showDialog(
        context: context,
        builder: (context) =>
            DialogErrorWidget(errorText: 'Error: ${e.toString()}'),
      );
    }
  }

  void showDialogTambahStaff() {
    int? selecteduserId;
    String? selectedGuruNama;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tambah Staff Kurikulum",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Pilih guru untuk ditambahkan sebagai staff kurikulum",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Symbols.close, color: Colors.black, weight: 600),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Guru",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          constraints: BoxConstraints(minHeight: 48),
                          child: DropdownButtonFormField2<String>(
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(120, 144, 156, 1),
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Color.fromRGBO(120, 144, 156, 1),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            // value: selectedGuruNama,
                            hint: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Pilih Guru",
                                style: TextStyle(
                                  color: Colors.blueGrey[400],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              offset: const Offset(0, -5),
                            ),
                            items: guruList
                                .map(
                                  (e) => DropdownItem<String>(
                                    value: e['nama'],
                                    child: Text(
                                      e['nama'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                final selectedGuru = guruList.firstWhere(
                                  (e) => e['nama'] == value,
                                );
                                selectedGuruNama = value;
                                selecteduserId = selectedGuru['user_id'];
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (selecteduserId == null) {
                  showDialog(
                    context: context,
                    builder: (context) => DialogErrorWidget(
                      errorText: "Silakan pilih guru terlebih dahulu",
                    ),
                  );
                  return;
                }

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );

                try {
                  await addStaffKurikulum(selecteduserId!);
                } catch (e) {
                  // Error handling sudah ada di addStaffKurikulum
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff016EB3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(70, 40),
              ),
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              headerTitle: "STAFF KURIKULUM",
              btnAddTitle: "Tambah Staff",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: true,
              addAction: () {
                showDialogTambahStaff();
              },
              exportAction: () {},
              importAction: () {},
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
                  Header2Widget(
                    header2Title: "Daftar Staff Kurikulum",
                    subtitle:
                        "Kelola atau lakukan pencarian data staff kurikulum.",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan nama atau NIP/NUPTK...",
                        onChangedSearch: (value) {
                          fetchStaffKurikulum(page: 1, search: value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : staffKurikulumList.isEmpty
                      ? const Center(
                          child: Text("Data staff kurikulum tidak tersedia."),
                        )
                      : buildStaffTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStaffTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      2: FixedColumnWidth(50),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: [
                          TableHeaderCell("NIP/NUPTK"),
                          TableHeaderCell("Nama"),
                          TableHeaderCell("Aksi"),
                        ],
                      ),
                      for (final staff in staffKurikulumList)
                        TableRow(
                          children: [
                            TableCellWidget(
                              staff['nip_nuptk_nisn']?.toString() ?? "-",
                            ),
                            TableCellWidget(staff['nama'] ?? "-"),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: PopupMenuButton<String>(
                                  position: PopupMenuPosition.under,
                                  color: Colors.white,
                                  icon: const Icon(Symbols.more_horiz),
                                  onSelected: (value) async {
                                    if (value == 'hapus') {
                                      // Tampilkan dialog konfirmasi dan tunggu hasilnya
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return DialogKonfirmasiWidget(
                                            confirmText:
                                                "Apakah anda yakin ingin menghapus staff '${staff['nama']}' ?",
                                            confirmAction: () {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pop(true);
                                            },
                                          );
                                        },
                                      );

                                      // Jika user memilih "Ya"
                                      if (shouldDelete == true) {
                                        // Tampilkan loading
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        try {
                                          await deleteStaffKurikulum(
                                            staff['staff_kurikulum_id'],
                                          );
                                        } catch (e) {
                                          // Error handling sudah ada di deleteStaffKurikulum
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'hapus',
                                      child: SizedBox(
                                        height: 15,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Hapus',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
        const SizedBox(height: 16),

        // Pagination
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Menampilkan ${staffKurikulumList.length} dari $totalItems data",
            ),
            Row(
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () => fetchStaffKurikulum(
                          page: currentPage - 1,
                          search: searchController.text,
                        )
                      : null,
                  child: const Text("Sebelumnya"),
                ),
                const SizedBox(width: 8),

                // Pagination numbers
                ..._buildPaginationButtons(),

                const SizedBox(width: 8),
                TextButton(
                  onPressed: currentPage < totalPage
                      ? () => fetchStaffKurikulum(
                          page: currentPage + 1,
                          search: searchController.text,
                        )
                      : null,
                  child: const Text("Selanjutnya"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPaginationButtons() {
    List<Widget> buttons = [];

    if (totalPage <= 5) {
      for (int i = 1; i <= totalPage; i++) {
        buttons.add(_pageButton(i));
      }
    } else {
      buttons.add(_pageButton(1));

      if (currentPage > 4) {
        buttons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("..."),
          ),
        );
      }

      int start = (currentPage - 1).clamp(2, totalPage - 3);
      int end = (currentPage + 1).clamp(4, totalPage - 1);

      for (int i = start; i <= end; i++) {
        buttons.add(_pageButton(i));
      }

      if (currentPage < totalPage - 3) {
        buttons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("..."),
          ),
        );
      }

      buttons.add(_pageButton(totalPage));
    }

    return buttons;
  }

  Widget _pageButton(int page) {
    final bool isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : null,
          foregroundColor: isActive ? Colors.white : Colors.black,
          minimumSize: const Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed: () =>
            fetchStaffKurikulum(page: page, search: searchController.text),
        child: Text("$page"),
      ),
    );
  }
}
