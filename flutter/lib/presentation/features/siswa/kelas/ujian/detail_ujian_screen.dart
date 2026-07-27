// ignore_for_file: avoid_print
import 'package:elearning_sman2sidoarjo/core/routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../models/siswa/detail_ujian_model.dart';
import '../../../../shared_widgets/general_old/main_button2_widget.dart'; // Tambahkan import

class DetailUjianSiswaScreen extends ConsumerStatefulWidget {
  const DetailUjianSiswaScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailUjianSiswaScreenState();
}

class _DetailUjianSiswaScreenState
    extends ConsumerState<DetailUjianSiswaScreen> {
  List<DetailUjian> detailUjian = [];
  bool isLoading = true;
  TextEditingController komentarController = TextEditingController();

  int? ujianId;
  int? userId;

  // Tambahkan variabel untuk debug info
  String debugInfo = '';
  String supabaseResponse = '';
  List<String> sharedPrefsKeys = [];

  @override
  void initState() {
    super.initState();
    _loadDetailUjian();
  }

  Future<void> _loadDetailUjian() async {
    try {
      print("=== DETAIL UJIAN SCREEN DEBUG ===");

      final prefs = await SharedPreferences.getInstance();

      // Debug: print semua keys dan values
      print("1. Semua SharedPreferences:");
      for (var key in prefs.getKeys()) {
        print(
          "   • $key: ${prefs.get(key)} (tipe: ${prefs.get(key).runtimeType})",
        );
      }

      final prefsUjianId = prefs.getInt('ujianId');
      final prefsUserId = prefs.getString('user_id');

      print("2. ujianId dari prefs: $prefsUjianId");
      print("3. userId dari prefs: $prefsUserId");

      String debug = '=== DEBUG INFO ===\n\n';
      debug += '1. SharedPreferences:\n';
      debug += '   • ujianId: $prefsUjianId\n';
      debug += '   • userId: $prefsUserId\n';

      // Jika null, cari tahu kenapa
      if (prefsUjianId == null) {
        debug += '\n❌ ujianId NULL di SharedPreferences!\n';
        debug += 'Kemungkinan:\n';
        debug += '1. Belum disimpan dari halaman sebelumnya\n';
        debug += '2. Key salah (harus \'ujianId\' bukan \'ujian_id\')\n';
        debug += '3. SharedPreferences tidak persist antar screen\n';
      }

      if (prefsUserId == null) {
        debug += '\n❌ userId NULL di SharedPreferences!\n';
        debug += 'Pastikan login berhasil dan userId tersimpan.\n';
      }

      // Hanya lanjut jika kedua ID ada
      if (prefsUjianId != null && prefsUserId != null) {
        print("4. Parameter ke Supabase:");
        print("   • p_ujian_id: $prefsUjianId");
        print("   • p_user_id: ${int.parse(prefsUserId)}");

        debug += '\n2. Memanggil Supabase dengan:\n';
        debug += '   • p_ujian_id: $prefsUjianId\n';
        debug += '   • p_user_id: ${int.parse(prefsUserId)}\n';

        final supabase = Supabase.instance.client;
        final response = await supabase.rpc(
          'get_info_ujian4',
          params: {
            'p_ujian_id': prefsUjianId,
            'p_user_id': int.parse(prefsUserId),
          },
        );

        print("5. Response dari Supabase:");
        print("   • Tipe: ${response.runtimeType}");
        print("   • Nilai: $response");

        debug += '\n3. Response Supabase:\n';
        debug += '   • Tipe: ${response.runtimeType}\n';
        debug += '   • Nilai: $response\n';

        if (response is List && response.isNotEmpty) {
          print("6. Raw data pertama: ${response.first}");

          // Debug: Tampilkan keys dari response pertama
          if (response.first is Map) {
            print("7. Keys dalam response: ${(response.first as Map).keys}");
          }

          try {
            final list = response.map((e) {
              print("8. Mapping item: $e");
              return DetailUjian.fromJson(e as Map<String, dynamic>);
            }).toList();

            print("9. Konversi berhasil! Jumlah: ${list.length}");
            debug += '\n✅ Konversi berhasil! ${list.length} item.\n';

            setState(() {
              detailUjian = list;
              ujianId = prefsUjianId;
              userId = int.parse(prefsUserId);
              isLoading = false;
              debugInfo = debug;
            });
            return;
          } catch (e, st) {
            print("10. Error konversi: $e");
            print("Stack trace: $st");
            debug += '\n❌ Error konversi: $e\n';
          }
        } else if (response == null) {
          debug += '\n⚠️ Response NULL dari Supabase\n';
        } else if (response is List && response.isEmpty) {
          debug += '\n⚠️ List kosong dari Supabase\n';
          debug += 'Coba di Postman dengan parameter yang sama:\n';
          debug += '{\n';
          debug += '  "p_ujian_id": $prefsUjianId,\n';
          debug += '  "p_user_id": ${int.parse(prefsUserId)}\n';
          debug += '}\n';
        }
      }

      setState(() {
        ujianId = prefsUjianId;
        userId = prefsUserId != null ? int.parse(prefsUserId) : null;
        isLoading = false;
        debugInfo = debug;
      });

      print("=== END DETAIL DEBUG ===");
    } catch (e, stackTrace) {
      print("FATAL ERROR: $e");
      print("Stack: $stackTrace");

      setState(() {
        debugInfo = 'FATAL ERROR: $e\n\n$stackTrace';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tampilkan debug info jika detailUjian kosong
          if (detailUjian.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Debug Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bug_report, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'DEBUG INFORMATION',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada ujian ditemukan.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ujianId: $ujianId',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'userId: $userId',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Detail Debug:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          debugInfo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol untuk coba lagi
                  Center(
                    child: ElevatedButton(
                      onPressed: _loadDetailUjian,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info tambahan
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kemungkinan masalah:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. ujianId belum disimpan di SharedPreferences',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '2. Function RPC get_info_ujian4 tidak mengembalikan data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '3. Parameter yang dikirim salah',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Tampilkan data ujian jika ada
          final ujian = detailUjian.first;
          final now = DateTime.now();
          final startDateTime = DateTime.parse(
            "${ujian.tanggalUjian} ${ujian.jamMulai}",
          );

          final endDateTime = DateTime.parse(
            "${ujian.tanggalUjian} ${ujian.jamSelesai}",
          );

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // // Debug info kecil di atas
                        // Container(
                        //   padding: const EdgeInsets.all(8),
                        //   decoration: BoxDecoration(
                        //     color: Colors.green[50],
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       const Icon(
                        //         Icons.check_circle,
                        //         color: Colors.green,
                        //         size: 16,
                        //       ),
                        //       const SizedBox(width: 8),
                        //       Text(
                        //         'Data ditemukan | ujianId: $ujianId | userId: $userId',
                        //         style: const TextStyle(
                        //           fontSize: 12,
                        //           color: Colors.green,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 16),

                        // Data ujian
                        Text(
                          ujian.judulUjian,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ujian.deskripsi,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Pelaksanaan Ujian : ${ujian.tanggalUjian}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Dimulai Pukul : ${ujian.jamMulai}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Selesai Pukul : ${ujian.jamSelesai}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        if (ujian.statusNilai == 'Ditampilkan')
                          Text(
                            "Nilai : ${ujian.nilaiUjian.toString()}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 10),

                        // Tombol berdasarkan status
                        if (ujian.statusPengerjaan == false) ...[
                          if (now.isBefore(startDateTime))
                            MainButton2Widget(
                              isDisabled: true,
                              btnColor: Colors.grey,
                              btnAction: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final kelasMapelId = prefs.getInt(
                                  'kelasMapelId',
                                );
                                context.go(RoutesNames.soalUjianSiswa);
                              },
                              btnTitle: "Ujian Belum Dimulai",
                            ),
                          if (now.isAfter(endDateTime))
                            MainButton2Widget(
                              isDisabled: true,
                              btnColor: Colors.grey,
                              btnAction: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final kelasMapelId = prefs.getInt(
                                  'kelasMapelId',
                                );
                                context.go(RoutesNames.soalUjianSiswa);
                              },
                              btnTitle: "Ujian Sudah Ditutup",
                            ),
                          if (now.isAfter(startDateTime) &&
                              now.isBefore(endDateTime))
                            MainButton2Widget(
                              isDisabled: false,
                              btnColor: const Color(0xff016EB3),
                              btnAction: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final kelasMapelId = prefs.getInt(
                                  'kelasMapelId',
                                );
                                await prefs.setString(
                                  'endDateTime',
                                  endDateTime.toString(),
                                );
                                context.go(RoutesNames.soalUjianSiswa);
                              },
                              btnTitle: "Kerjakan Sekarang",
                            ),
                        ],
                        if (ujian.statusPengerjaan == true)
                          MainButton2Widget(
                            isDisabled: false,
                            btnColor: const Color(0xff016EB3),
                            btnAction: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              final kelasMapelId = prefs.getInt('kelasMapelId');
                              context.go(RoutesNames.jawabanUjianSiswa);
                            },
                            btnTitle: "Lihat",
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
