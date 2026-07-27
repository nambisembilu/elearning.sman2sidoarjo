import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../shared_widgets/general_old/header2_widget.dart';
import '../../shared_widgets/general_old/header_widget.dart';
import '../../shared_widgets/general_old/search_textfield_widget.dart';
import '../../shared_widgets/general_old/table_cell.dart';
import '../../shared_widgets/general_old/table_header_cell.dart';

class LogAktivitasScreen extends StatefulWidget {
  const LogAktivitasScreen({super.key});

  @override
  State<LogAktivitasScreen> createState() => _LogAktivitasScreenState();
}

class _LogAktivitasScreenState extends State<LogAktivitasScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> logAktivitasList = [];

  int currentPage = 1;
  int totalPage = 1;
  int totalItems = 0;

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLogAktivitas();
  }

  Future<void> fetchLogAktivitas({int page = 1, String search = ''}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.rpc(
        'get_log_aktivitas_fix',
        params: {'p_search': search, 'p_page': page},
      );

      print('Response from get_log_aktivitas_fix: $response'); // Debug log

      if (response != null) {
        // Response langsung berupa Map, bukan List
        final Map<String, dynamic> data = response;

        setState(() {
          logAktivitasList = List<Map<String, dynamic>>.from(
            data['data'] ?? [],
          );
          currentPage = data['page'] ?? 1;
          totalPage = data['total_page'] ?? 1;
          totalItems = data['total'] ?? 0;
        });

        print(
          'Parsed data: total=$totalItems, page=$currentPage, totalPage=$totalPage, items=${logAktivitasList.length}',
        ); // Debug log
      } else {
        setState(() {
          logAktivitasList = [];
          currentPage = 1;
          totalPage = 1;
          totalItems = 0;
        });
      }
    } catch (e) {
      print('Error fetching log aktivitas: $e'); // Debug log
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

  String formatDateTime(String dateTimeString) {
    try {
      // Handle jika dateTimeString mengandung "T" (ISO format)
      String formattedString = dateTimeString;
      if (dateTimeString.contains('T')) {
        formattedString = dateTimeString.replaceAll('T', ' ');
      }

      // Parse string ke DateTime
      final dateTime = DateTime.parse(formattedString);

      // Format: DD-MM-YYYY HH:mm
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');

      return '$day-$month-$year $hour:$minute';
    } catch (e) {
      print('Error formatting date: $e - Input: $dateTimeString'); // Debug log
      return dateTimeString;
    }
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
              headerTitle: "LOG AKTIVITAS",
              btnAddTitle: "",
              showExportBtn: false,
              showImportBtn: false,
              showAddBtn: false,
              addAction: () {},
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
                    header2Title: "Daftar Log Aktivitas",
                    subtitle: "Lihat dan lacak aktivitas sistem.",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SearchTextFieldWidget(
                        hintText: "Cari berdasarkan aktivitas atau staff...",
                        onChangedSearch: (value) {
                          fetchLogAktivitas(page: 1, search: value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : logAktivitasList.isEmpty
                      ? const Center(
                          child: Text("Data log aktivitas tidak tersedia."),
                        )
                      : buildLogAktivitasTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogAktivitasTable() {
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
                      1: IntrinsicColumnWidth(flex: 2),
                      2: IntrinsicColumnWidth(flex: 2),
                      3: IntrinsicColumnWidth(flex: 3),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: [
                          TableHeaderCell("ID"),
                          TableHeaderCell("Waktu"),
                          TableHeaderCell("Staff Kurikulum"),
                          TableHeaderCell("Aktivitas"),
                        ],
                      ),
                      for (final log in logAktivitasList)
                        TableRow(
                          children: [
                            TableCellWidget(log['id']?.toString() ?? "-"),
                            TableCellWidget(
                              log['created_at'] != null
                                  ? formatDateTime(log['created_at'].toString())
                                  : "-",
                            ),
                            TableCellWidget(
                              log['staff_nama']?.toString() ?? "-",
                            ),
                            TableCellWidget(
                              log['aktivitas']?.toString() ?? "-",
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
              "Menampilkan ${logAktivitasList.length} dari $totalItems data",
            ),
            Row(
              children: [
                TextButton(
                  onPressed: currentPage > 1
                      ? () => fetchLogAktivitas(
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
                      ? () => fetchLogAktivitas(
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
            fetchLogAktivitas(page: page, search: searchController.text),
        child: Text("$page"),
      ),
    );
  }
}
