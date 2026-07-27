import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../models/guru/jadwal_mengajar_model.dart';
import '../../../controllers/guru/jadwal_mengajar/jadwal_mengajar_riverpod.dart';
import '../../../shared_widgets/general_old/header2_widget.dart';
import '../../../shared_widgets/general_old/header_widget.dart';

class JadwalMengajarScreen extends ConsumerStatefulWidget {
  const JadwalMengajarScreen({super.key});

  @override
  ConsumerState<JadwalMengajarScreen> createState() =>
      _JadwalMengajarScreenState();
}

class _JadwalMengajarScreenState extends ConsumerState<JadwalMengajarScreen> {
  @override
  Widget build(BuildContext context) {
    final jadwalMengajarState = ref.watch(jadwalMengajarRiverpodProvider);

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWidget(
            headerTitle: "JADWAL MENGAJAR",
            btnAddTitle: '',
            showExportBtn: false,
            showImportBtn: false,
            showAddBtn: false,
            addAction: null,
            exportAction: null,
            importAction: null,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header2Widget(
                    header2Title: "Jadwal Mengajar Mingguan",
                    subtitle: "Lihat jadwal mengajar anda",
                  ),
                  const SizedBox(height: 20),

                  // Konten jadwal berdasarkan state
                  Expanded(
                    child: jadwalMengajarState.when(
                      data: (list) {
                        if (list.isEmpty) {
                          return const Center(
                            child: Text(
                              "Tidak ada jadwal mengajar",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        // Group berdasarkan hari
                        final Map<String, List<JadwalMataPelajaran>>
                        scheduleByDay = {};
                        for (var schedule in list) {
                          final day = schedule.hari;
                          if (!scheduleByDay.containsKey(day)) {
                            scheduleByDay[day] = [];
                          }
                          scheduleByDay[day]!.add(schedule);
                        }

                        const dayOrder = [
                          'Senin',
                          'Selasa',
                          'Rabu',
                          'Kamis',
                          'Jumat',
                          'Sabtu',
                          'Minggu',
                        ];

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dayOrder
                                .where((day) => scheduleByDay.containsKey(day))
                                .map(
                                  (day) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDaySchedule(
                                        day,
                                        scheduleByDay[day]!,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Text(
                          "Terjadi kesalahan: $err",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan jadwal per hari
  Widget _buildDaySchedule(String day, List<JadwalMataPelajaran> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: schedules.map((schedule) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        schedule.mataPelajaran,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(schedule.waktu),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(schedule.namaKelas), Text("Ruang ")],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
