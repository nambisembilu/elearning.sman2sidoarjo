import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/data_guru_model.dart';

class DialogDetailGuru extends StatefulWidget {
  final Guru guru;

  const DialogDetailGuru({super.key, required this.guru});

  @override
  State<DialogDetailGuru> createState() => _DialogDetailGuruState();
}

class _DialogDetailGuruState extends State<DialogDetailGuru>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Group schedule by day
    final Map<String, List<dynamic>> scheduleByDay = {};
    if (widget.guru.jadwalMengajar.isNotEmpty) {
      for (var schedule in widget.guru.jadwalMengajar) {
        final day = schedule['Hari'] ?? '';
        if (!scheduleByDay.containsKey(day)) {
          scheduleByDay[day] = [];
        }
        scheduleByDay[day]!.add(schedule);
      }
    }

    // Define day order for consistent display
    const dayOrder = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Detail Guru"),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Symbols.close, color: Colors.black, weight: 600),
          ),
        ],
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Profile information
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.59,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Icon(Symbols.person, size: 50),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.guru.nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "(NIP/NUPTK : ${widget.guru.nipNuptk})",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Symbols.phone, color: Color(0xff016EB3)),
                            const SizedBox(width: 10),
                            Text(widget.guru.nomorTelepon.toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Symbols.email, color: Color(0xff016EB3)),
                            const SizedBox(width: 10),
                            Text(widget.guru.email.toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Symbols.location_on, color: Color(0xff016EB3)),
                            const SizedBox(width: 10),
                            Text(widget.guru.alamat.toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // Right side - Subjects and schedule
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.59,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TabBar with full-width indicators and no divider
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
                        dividerColor: Colors.transparent, // Remove divider
                        tabs: const [
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Mata Pelajaran"),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("Jadwal Mengajar"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TabBarView content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Tab 1: Mata Pelajaran
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Symbols.menu_book,
                                    color: Color(0xff016EB3),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Mata Pelajaran yang Diampu (${widget.guru.mataPelajaran.length})",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: widget.guru.mataPelajaran.map((
                                      mapel,
                                    ) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff016EB3),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mapel["judul"]!
                                                        .split("-")
                                                        .first
                                                        .trim(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    mapel["judul"]!
                                                        .split("-")
                                                        .last
                                                        .trim(),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                mapel["jurusan"]!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xff016EB3),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Tab 2: Jadwal Mengajar - Using actual data
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon
                              Row(
                                children: [
                                  Icon(Symbols.schedule, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Jadwal Mengajar Mingguan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Schedule content
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.guru.jadwalMengajar == null ||
                                          widget.guru.jadwalMengajar.isEmpty)
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            "Tidak ada jadwal mengajar",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      else
                                        ...dayOrder
                                            .where(
                                              (day) => scheduleByDay
                                                  .containsKey(day),
                                            )
                                            .map((day) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  _buildDaySchedule(
                                                    day,
                                                    scheduleByDay[day]!,
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                              );
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a day schedule section
  Widget _buildDaySchedule(String day, List<dynamic> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xff016EB3),
          ),
        ),
        const SizedBox(height: 8),

        // Time slots
        Column(
          children: schedules.map((schedule) {
            return _buildTimeSlot(
              schedule['Waktu'],
              schedule['Mata Pelajaran'],
              schedule['Kelas'],
              schedule['Ruang'],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build a time slot item
  Widget _buildTimeSlot(
    String time,
    String subject,
    String className,
    String room,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Subject
          Text(
            subject,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),

          // Class and room
          Text(
            "$className • $room",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
