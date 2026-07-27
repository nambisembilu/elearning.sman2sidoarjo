import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../models/staff/tahun_ajaran_model.dart';
import '../../../../services/staff/tahun_ajaran_service.dart';

class TahunAjaranStaffScreen extends StatefulWidget {
  const TahunAjaranStaffScreen({super.key});

  @override
  State<TahunAjaranStaffScreen> createState() => _TahunAjaranStaffScreenState();
}

class _TahunAjaranStaffScreenState extends State<TahunAjaranStaffScreen> {
  // Service
  final TahunAjaran1Service _tahunAjaranService = TahunAjaran1Service(
    Supabase.instance.client,
  );

  // State untuk data
  List<TahunAjaran1> _tahunAjaranList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';

  // State untuk pagination
  int _currentPage = 1;
  int _totalPage = 1;
  int _totalItems = 0;

  // State untuk form tambah
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tahunMulaiController = TextEditingController();
  final TextEditingController _tahunSelesaiController = TextEditingController();
  final TextEditingController _tanggalGanjilController =
      TextEditingController();
  final TextEditingController _tanggalGenapController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTahunAjaran();
  }

  Future<void> _loadTahunAjaran() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _tahunAjaranService.getAllTahunAjaran(
        page: _currentPage,
        search: _searchQuery,
      );

      setState(() {
        _tahunAjaranList = response.data;
        _totalPage = response.totalPage;
        _totalItems = response.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _currentPage = 1;
    _loadTahunAjaran();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadTahunAjaran();
  }

  // Helper function untuk mendapatkan tanggal mulai semester
  String _getTanggalMulaiSemester(
    List<Map<String, dynamic>> semester,
    String namaSemester,
  ) {
    if (semester.isEmpty) return '-';

    for (var sem in semester) {
      if (sem['nama_semester'] == namaSemester) {
        return sem['tanggal_awal_semester']?.toString() ?? '-';
      }
    }
    return '-';
  }

  Future<void> _tambahTahunAjaran() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _tahunAjaranService.addTahunAjaran(
        tahunMulai: _tahunMulaiController.text,
        tahunSelesai: _tahunSelesaiController.text,
        tanggalMulaiSmtGanjil: _tanggalGanjilController.text,
        tanggalMulaiSmtGenap: _tanggalGenapController.text,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Close form dialog
      Navigator.pop(context);

      // Reset form
      _tahunMulaiController.clear();
      _tahunSelesaiController.clear();
      _tanggalGanjilController.clear();
      _tanggalGenapController.clear();

      // Reload data
      _currentPage = 1;
      await _loadTahunAjaran();

      // Show success message
      _showSuccessDialog('Tahun ajaran berhasil ditambahkan');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Gagal menambahkan tahun ajaran: ${e.toString()}');
    }
  }

  Future<void> _hapusTahunAjaran(int tahunAjaranId, String tahunAjaran) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus tahun ajaran "$tahunAjaran"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _tahunAjaranService.deleteTahunAjaran(
        tahun_ajaran_id: tahunAjaranId,
      );

      // Close loading dialog
      Navigator.pop(context);

      // Reload data
      await _loadTahunAjaran();

      // Show success message
      _showSuccessDialog('Tahun ajaran berhasil dihapus');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('Gagal menghapus tahun ajaran: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sukses', style: TextStyle(color: Colors.green)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDialogTambah() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tambah Tahun Ajaran",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Masukkan informasi tahun ajaran baru",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Symbols.close, color: Colors.black, weight: 600),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        // Tahun Mulai
                        TextFormField(
                          controller: _tahunMulaiController,
                          decoration: const InputDecoration(
                            labelText: 'Tahun Mulai*',
                            border: OutlineInputBorder(),
                            hintText: 'Contoh: 2024',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tahun mulai harus diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Masukkan tahun yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tahun Selesai
                        TextFormField(
                          controller: _tahunSelesaiController,
                          decoration: const InputDecoration(
                            labelText: 'Tahun Selesai*',
                            border: OutlineInputBorder(),
                            hintText: 'Contoh: 2025',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tahun selesai harus diisi';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Masukkan tahun yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tanggal Mulai Semester Ganjil
                        TextFormField(
                          controller: _tanggalGanjilController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Mulai Semester Ganjil*',
                            border: OutlineInputBorder(),
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal harus diisi';
                            }
                            final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!regex.hasMatch(value)) {
                              return 'Format: YYYY-MM-DD';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tanggal Mulai Semester Genap
                        TextFormField(
                          controller: _tanggalGenapController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Mulai Semester Genap*',
                            border: OutlineInputBorder(),
                            hintText: 'YYYY-MM-DD',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal harus diisi';
                            }
                            final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                            if (!regex.hasMatch(value)) {
                              return 'Format: YYYY-MM-DD';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _tambahTahunAjaran,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff016EB3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // =====================
  // Pagination Helpers (sama seperti di kelas_screen)
  // =====================
  List<Widget> _buildPaginationButtons() {
    List<Widget> buttons = [];

    if (_totalPage <= 5) {
      // Kalau halaman sedikit, tampil semua
      for (int i = 1; i <= _totalPage; i++) {
        buttons.add(_pageButton(i));
      }
    } else {
      // Selalu tampilkan halaman 1
      buttons.add(_pageButton(1));

      // Ellipsis awal
      if (_currentPage > 4) {
        buttons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("..."),
          ),
        );
      }

      // Halaman sekitar currentPage
      int start = (_currentPage - 1).clamp(2, _totalPage - 3);
      int end = (_currentPage + 1).clamp(4, _totalPage - 1);

      for (int i = start; i <= end; i++) {
        buttons.add(_pageButton(i));
      }

      // Ellipsis akhir
      if (_currentPage < _totalPage - 3) {
        buttons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("..."),
          ),
        );
      }

      // Halaman terakhir
      buttons.add(_pageButton(_totalPage));
    }

    return buttons;
  }

  Widget _pageButton(int page) {
    final bool isActive = page == _currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Colors.blue : null,
          foregroundColor: isActive ? Colors.white : Colors.black,
          minimumSize: const Size(36, 36),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _onPageChanged(page),
        child: Text("$page"),
      ),
    );
  }

  // =====================
  // Tabel Builder - DISESUAIKAN dengan response JSON
  // =====================
  Widget _buildTahunAjaranTable() {
    if (_tahunAjaranList.isEmpty) {
      return const Center(
        child: Text(
          "Data tahun ajaran tidak tersedia.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabel
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
                      2: IntrinsicColumnWidth(),
                      3: IntrinsicColumnWidth(),
                      4: FixedColumnWidth(80),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      // Header Row
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F5F5),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Tahun Ajaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Mulai Semester Ganjil',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Mulai Semester Genap',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Status',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Aksi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Data Rows
                      for (final tahunAjaran in _tahunAjaranList)
                        TableRow(
                          decoration: BoxDecoration(
                            color:
                                _tahunAjaranList.indexOf(tahunAjaran) % 2 == 0
                                ? Colors.white
                                : Colors.grey[50],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                tahunAjaran.tahunAjaran,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                _getTanggalMulaiSemester(
                                  tahunAjaran.semester,
                                  'Ganjil',
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                _getTanggalMulaiSemester(
                                  tahunAjaran.semester,
                                  'Genap',
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Chip(
                                label: Text(
                                  tahunAjaran.isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: tahunAjaran.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                backgroundColor: tahunAjaran.isActive
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: PopupMenuButton<String>(
                                position: PopupMenuPosition.under,
                                color: Colors.white,
                                icon: const Icon(Symbols.more_horiz, size: 20),
                                onSelected: (value) {
                                  if (value == 'hapus') {
                                    _hapusTahunAjaran(
                                      tahunAjaran.tahunAjaranId,
                                      tahunAjaran.tahunAjaran,
                                    );
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
                    "Menampilkan ${_tahunAjaranList.length} dari $_totalItems data",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Kontrol pagination di bawah
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                  _loadTahunAjaran();
                                }
                              : null,
                          child: const Text("Sebelumnya"),
                        ),
                        const SizedBox(width: 8),

                        /// Pagination dengan ellipsis
                        ..._buildPaginationButtons(),

                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _currentPage < _totalPage
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                  _loadTahunAjaran();
                                }
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
                    "Menampilkan ${_tahunAjaranList.length} dari $_totalItems data",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                                _loadTahunAjaran();
                              }
                            : null,
                        child: const Text("Sebelumnya"),
                      ),
                      const SizedBox(width: 8),

                      /// Pagination dengan ellipsis
                      ..._buildPaginationButtons(),

                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _currentPage < _totalPage
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                                _loadTahunAjaran();
                              }
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

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Cari berdasarkan tahun ajaran...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TAHUN AJARAN',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showDialogTambah,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff016EB3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Tambah Tahun Ajaran',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Container utama
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Tahun Ajaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola data tahun ajaran',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search dan Filter Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSearchBar(),
                      // Jika perlu filter bisa ditambahkan di sini
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tabel atau loading
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else
                    _buildTahunAjaranTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tahunMulaiController.dispose();
    _tahunSelesaiController.dispose();
    _tanggalGanjilController.dispose();
    _tanggalGenapController.dispose();
    super.dispose();
  }
}
