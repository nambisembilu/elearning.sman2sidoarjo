import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/filtering_model.dart';
import '../../../../../models/staff/jadwal_pelajaran_model.dart';
import '../../../../../models/staff/kelas_aktif_model.dart';
import '../../../../controllers/staff/jadwal_mapel/guru_tersedia_riverpod.dart';
import '../../../../controllers/staff/jadwal_mapel/mapel_by_kelas_hari_riverpod.dart';
import '../../../../controllers/staff/jadwal_mapel/waktu_tersedia_riverpod.dart';
import '../../../../controllers/staff/jadwal_mapel_riverpod.dart';
import '../../../../controllers/staff/kelas_aktif_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahOrEditJadwalMapel extends ConsumerStatefulWidget {
  final JadwalMataPelajaran? dataJadwalMapel;
  final Function(String hari, int kelasId)? onSuccess; // Tambahkan callback

  const DialogTambahOrEditJadwalMapel({
    super.key,
    required this.dataJadwalMapel,
    this.onSuccess,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahOrEditJadwalMapelState();
}

class _DialogTambahOrEditJadwalMapelState
    extends ConsumerState<DialogTambahOrEditJadwalMapel> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController kelasController = TextEditingController();

  List<KelasAktif> daftarKelasAktif = [];
  List<MapelByKelasHari> daftarMapelByKelasHari = [];
  List<FilterGuru> daftarGuruTersedia = [];

  String? selectedHari;
  String? selectedWaktu;
  String? selectedMapel;
  String? selectedGuru;
  String? namaKelas;

  int? kelasId;
  int? mapelId;
  int? guruId;
  int? jadwalMapelId;

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    if (widget.dataJadwalMapel != null) {
      kelasController.text = widget.dataJadwalMapel!.namaKelas;
      selectedHari = widget.dataJadwalMapel!.hari;
      selectedWaktu = widget.dataJadwalMapel!.waktu;
      selectedMapel = widget.dataJadwalMapel!.mataPelajaran;
      selectedGuru = widget.dataJadwalMapel!.guru;
      namaKelas = widget.dataJadwalMapel!.namaKelas;

      kelasId = widget.dataJadwalMapel!.kelasId;
      mapelId = widget.dataJadwalMapel!.mapelId;
      guruId = widget.dataJadwalMapel!.guruId;
      jadwalMapelId = widget.dataJadwalMapel!.id;
    }

    // fetch kelas aktif di sini
    Future.microtask(() {
      ref.read(kelasAktifNotifierProvider.notifier).fetchKelasAktif();
    });
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    final kelasAktifState = ref.watch(kelasAktifNotifierProvider);
    final waktuTersediaState = ref.watch(waktuTersediaNotifierProvider);
    final mapelByKelasHariState = ref.watch(mapelByKelasHariNotifierProvider);
    final guruTersediaState = ref.watch(guruTersediaNotifierProvider);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.dataJadwalMapel == null
                ? "Tambah Jadwal Pelajaran"
                : "Edit Jadwal Pelajaran",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.info, color: Colors.black, weight: 600),
                          const SizedBox(width: 8),
                          Text(
                            "Informasi Jadwal Pelajaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      widget.dataJadwalMapel != null
                          ? Row(
                              children: [
                                TextFieldGeneralWidget(
                                  title: "Kelas",
                                  hintText: "",
                                  p_controller: kelasController,
                                  isRequired: true,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                DropdownGeneralWidget(
                                  pTitle: "Kelas",
                                  pHintText: "Pilih Kelas",
                                  valueParams: namaKelas,
                                  pItems: kelasAktifState.when(
                                    data: (kelasList) {
                                      daftarKelasAktif = kelasList;
                                      return daftarKelasAktif
                                          .map((e) => e.nama_kelas)
                                          .toList();
                                    },
                                    loading: () => [],
                                    error: (err, st) => [],
                                  ),
                                  pOnChanged: (value) {
                                    setState(() {
                                      namaKelas = value;
                                      final kelas = daftarKelasAktif.firstWhere(
                                        (e) => e.nama_kelas == value,
                                        orElse: () => KelasAktif(
                                          id: -1,
                                          nama_kelas: '',
                                          jurusan: '',
                                        ),
                                      );
                                      kelasId = kelas.id;

                                      if (selectedHari != null) {
                                        selectedWaktu = null;
                                        selectedMapel = null;
                                        mapelId = null;
                                        selectedGuru = null;
                                        guruId = null;

                                        ref
                                            .read(
                                              waktuTersediaNotifierProvider
                                                  .notifier,
                                            )
                                            .fetchWaktuTersedia(
                                              kelasId: kelasId!,
                                              hari: selectedHari!,
                                            );

                                        ref
                                            .read(
                                              mapelByKelasHariNotifierProvider
                                                  .notifier,
                                            )
                                            .fetchMapelByKelasHari(
                                              kelasId: kelasId!,
                                              hari: selectedHari!,
                                            );
                                      }
                                    });
                                  },
                                  isRequired: true,
                                  isSubmitted: isSubmitted,
                                ),
                              ],
                            ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Hari",
                            pHintText: "Pilih Hari",
                            valueParams: selectedHari,
                            pItems: [
                              "Senin",
                              "Selasa",
                              "Rabu",
                              "Kamis",
                              "Jumat",
                            ],
                            pOnChanged: (value) {
                              setState(() {
                                selectedHari = value;

                                if (kelasId != null && selectedHari != null) {
                                  selectedWaktu = null;
                                  selectedMapel = null;
                                  mapelId = null;
                                  selectedGuru = null;
                                  guruId = null;

                                  ref
                                      .read(
                                        waktuTersediaNotifierProvider.notifier,
                                      )
                                      .fetchWaktuTersedia(
                                        kelasId: kelasId!,
                                        hari: selectedHari!,
                                      );

                                  ref
                                      .read(
                                        mapelByKelasHariNotifierProvider
                                            .notifier,
                                      )
                                      .fetchMapelByKelasHari(
                                        kelasId: kelasId!,
                                        hari: selectedHari!,
                                      );
                                }
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Waktu",
                            pHintText: "Pilih Waktu",
                            valueParams: selectedWaktu,
                            pItems: waktuTersediaState.when(
                              data: (waktuList) {
                                // ambil semua nama hari dalam bentuk List<String>
                                return waktuList
                                    .map((e) => e.jamPelajaran)
                                    .toList();
                              },
                              loading: () => [],
                              error: (err, st) => [],
                            ),
                            pOnChanged: (value) {
                              setState(() {
                                selectedWaktu = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Mata Pelajaran",
                            pHintText: "Pilih Mata Pelajaran",
                            valueParams: selectedMapel,
                            pItems: mapelByKelasHariState.when(
                              data: (mapelList) {
                                daftarMapelByKelasHari = mapelList;
                                return daftarMapelByKelasHari
                                    .map((e) => e.namaMapel)
                                    .toList();
                              },
                              loading: () => [],
                              error: (err, st) => [],
                            ),
                            pOnChanged: (value) {
                              setState(() {
                                selectedGuru = null;
                                selectedMapel = value;
                                final mapel = daftarMapelByKelasHari.firstWhere(
                                  (e) => e.namaMapel == value,
                                );
                                mapelId = mapel.idMapel;

                                if (mapelId != null &&
                                    selectedHari != null &&
                                    selectedWaktu != null) {
                                  ref
                                      .read(
                                        guruTersediaNotifierProvider.notifier,
                                      )
                                      .fetchGuruTersedia(
                                        mapelId: mapelId!,
                                        hari: selectedHari!,
                                        waktu: selectedWaktu!,
                                      );
                                }
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Guru Pengampu",
                            pHintText: "Pilih Guru Pengampu",
                            valueParams: selectedGuru,
                            pItems: guruTersediaState.when(
                              data: (guruList) {
                                daftarGuruTersedia = guruList;
                                return daftarGuruTersedia
                                    .map((e) => e.namaGuru)
                                    .toList();
                              },
                              loading: () => [],
                              error: (err, st) => [],
                            ),
                            pOnChanged: (value) {
                              setState(() {
                                selectedGuru = value;

                                final guru = daftarGuruTersedia.firstWhere(
                                  (e) => e.namaGuru == value,
                                );
                                guruId = guru.idGuru;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                        ],
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
        ElevatedButton(
          onPressed: () async {
            setState(() {
              isSubmitted = true;
            });

            final isValid = _formKey.currentState!.validate();

            // Cek empty fields utama
            if (selectedGuru == null ||
                selectedHari == null ||
                selectedMapel == null ||
                selectedWaktu == null ||
                namaKelas == null ||
                kelasId == null ||
                mapelId == null ||
                guruId == null) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Jadwal Pelajaran Wajib Diisi",
                ),
              );
              return;
            }

            if (isValid) {
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final success = widget.dataJadwalMapel == null
                    ? await ref
                          .read(jadwalMapelRiverpodProvider.notifier)
                          .addJadwalPelajaran(
                            kelasId: kelasId!,
                            hari: selectedHari!,
                            guruId: guruId!,
                            waktu: selectedWaktu!,
                          )
                    : await ref
                          .read(jadwalMapelRiverpodProvider.notifier)
                          .updateJadwalPelajaran(
                            jadwalMapelId: widget.dataJadwalMapel!.id,
                            kelasId: kelasId!,
                            hari: selectedHari!,
                            guruId: guruId!,
                            waktu: selectedWaktu!,
                          );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Panggil callback jika ada
                  if (widget.onSuccess != null) {
                    widget.onSuccess!(selectedHari!, kelasId!);
                  }

                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: widget.dataJadwalMapel == null
                          ? 'Jadwal Pelajaran berhasil ditambahkan'
                          : 'Jadwal Pelajaran berhasil diperbarui',
                    ),
                  );
                }
              } catch (e) {
                // Remove loading indicator
                Navigator.pop(context);
              }
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
  }
}
