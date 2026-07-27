// file name: rubrik_detail_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/guru/rubrik_mapel/rubrik_mapel_riverpod.dart';

class RubrikDetailScreen extends ConsumerStatefulWidget {
  final int lingkupMateriId;
  final String lingkupMateri;
  final bool statusKunci;
  final int jumlahTP;
  final List<Map<String, dynamic>> tujuanPembelajaran;

  const RubrikDetailScreen({
    super.key,
    required this.lingkupMateriId,
    required this.lingkupMateri,
    required this.statusKunci,
    required this.jumlahTP,
    required this.tujuanPembelajaran,
  });

  @override
  ConsumerState<RubrikDetailScreen> createState() => _RubrikDetailScreenState();
}

class _RubrikDetailScreenState extends ConsumerState<RubrikDetailScreen> {
  late bool _isKoorMapel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkKoorStatus();
  }

  Future<void> _checkKoorStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString('user_id')!);
    final notifier = ref.read(rubrikMapelRiverpodProvider.notifier);

    // Cek apakah user adalah koor mapel
    _isKoorMapel = userId == notifier.userIdKoorMapel;

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTujuanPembelajaranCard(Map<String, dynamic> tp, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tujuan Pembelajaran ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                // if (_isKoorMapel && !widget.statusKunci)
                //   IconButton(
                //     icon: const Icon(Symbols.edit, size: 20),
                //     onPressed: () {
                //       // TODO: Implement edit TP
                //     },
                //     tooltip: 'Edit Tujuan Pembelajaran',
                //   ),
              ],
            ),
            const SizedBox(height: 12),

            // Deskripsi TP
            if (tp['deskripsi'] != null &&
                tp['deskripsi'].toString().isNotEmpty)
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
                  const SizedBox(height: 16),
                ],
              ),

            // Kriteria Penilaian
            const Text(
              'Kriteria Penilaian:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            _buildKriteriaItem(
              'Perlu Bimbingan',
              tp['perlu_bimbingan']?.toString() ?? 'Belum diisi',
              Colors.red,
            ),
            _buildKriteriaItem(
              'Cukup',
              tp['cukup']?.toString() ?? 'Belum diisi',
              Colors.orange,
            ),
            _buildKriteriaItem(
              'Baik',
              tp['baik']?.toString() ?? 'Belum diisi',
              Colors.blue,
            ),
            _buildKriteriaItem(
              'Sangat Baik',
              tp['sangat_baik']?.toString() ?? 'Belum diisi',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Symbols.arrow_back),
      //     onPressed: () => context.pop(),
      //   ),
      //   title: const Text('Detail Rubrik'),
      //   actions: [
      //     if (_isKoorMapel && !widget.statusKunci)
      //       IconButton(
      //         icon: const Icon(Symbols.edit),
      //         onPressed: _navigateToEditRubrik,
      //         tooltip: 'Edit Rubrik',
      //       ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lingkupMateri,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.lingkupMateriId} • ${widget.jumlahTP} Tujuan Pembelajaran',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // _buildStatusIndicator(),
              ],
            ),

            const SizedBox(height: 16),

            // Informasi status kunci
            if (widget.statusKunci)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rubrik ini terkunci dan tidak dapat diubah karena tahun ajaran telah berganti.',
                        style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Daftar Tujuan Pembelajaran
            Text(
              'Tujuan Pembelajaran',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${widget.tujuanPembelajaran.length} tujuan pembelajaran',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // List Tujuan Pembelajaran
            if (widget.tujuanPembelajaran.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Symbols.description,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada tujuan pembelajaran',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...widget.tujuanPembelajaran.asMap().entries.map((entry) {
                final index = entry.key;
                final tp = entry.value;
                return Column(
                  children: [
                    _buildTujuanPembelajaranCard(tp, index),
                    if (index < widget.tujuanPembelajaran.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }),

            const SizedBox(height: 32),

            // Tombol Aksi
            // if (_isKoorMapel && !widget.statusKunci)
            //   Row(
            //     children: [
            //       Expanded(
            //         child: OutlinedButton.icon(
            //           onPressed: _navigateToEditRubrik,
            //           icon: const Icon(Symbols.edit),
            //           label: const Text('Edit Rubrik'),
            //           style: OutlinedButton.styleFrom(
            //             padding: const EdgeInsets.symmetric(vertical: 16),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }
}
