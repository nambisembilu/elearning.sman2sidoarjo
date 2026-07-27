// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:elearning_sman2sidoarjo/presentation/features/guru/kelas/kelompok/list_siswa_non_kelompok_widget.dart';
import 'package:elearning_sman2sidoarjo/presentation/shared_widgets/general_old/search_textfield_widget.dart'
    show SearchTextFieldWidget;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/guru/kelompok_belajar_model.dart';
import '../../../../../models/guru/siswa_kelas_mapel_model.dart';
import '../../../../controllers/guru/konten_kelas/kelompok_belajar_riverpod.dart';
import '../../../../controllers/guru/konten_kelas/siswa_non_kelompok_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';

class DialogTambahOrEditKelompok extends ConsumerStatefulWidget {
  final KelompokBelajar? dataKelompok;

  const DialogTambahOrEditKelompok({super.key, required this.dataKelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahOrEditKelompokState();
}

class _DialogTambahOrEditKelompokState
    extends ConsumerState<DialogTambahOrEditKelompok> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> selectedSiswa = [];
  List<SiswaKelas> listSiswaNonKelompok = [];

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    // _initSiswaNonKelompokList();

    if (widget.dataKelompok != null) {
      final anggota = widget.dataKelompok!.anggotaKelompok;

      selectedSiswa = anggota.map((item) {
        return {
          "siswa_id": int.parse(item["siswa_id"].toString()),
          "nama": item["nama"],
        };
      }).toList();
    }

    if (!mounted) return;
  }

  // Future<void> _initSiswaNonKelompokList() async {
  //   final tugasNotifier = ref.read(kelompokBelajarRiverpodProvider.notifier);
  //   try {
  //     final result = await tugasNotifier.fetchSiswaNonKelompok();
  //     setState(() {
  //       listSiswaNonKelompok = result;
  //     });
  //   } catch (e) {
  //     print('Gagal mengambil siswa non kelompok : $e');
  //   }
  // }

  void addSiswa(int id, String nama) {
    final exists = selectedSiswa.any((item) => item['siswa_id'] == id);

    if (!exists) {
      setState(() {
        // Tambahkan setState
        selectedSiswa.add({'siswa_id': id, 'nama': nama});
      });
    }
  }

  // Tambahkan fungsi removeSiswa
  void removeSiswa(int id, String nama) {
    setState(() {
      selectedSiswa.removeWhere((item) => item['siswa_id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // final kelompokBelajarState = ref.watch(kelompokBelajarRiverpodProvider);
    final siswaNonKelompokState = ref.watch(siswaNonKelompokRiverpodProvider);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.dataKelompok == null ? "Tambah Kelompok" : "Edit Kelompok",
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
          // maxWidth: MediaQuery.of(context).size.width * 0.4,
        ),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: double.infinity,
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
                    SearchTextFieldWidget(
                      hintText: "Cari siswa...",
                      onChangedSearch: (value) {
                        ref
                            .read(siswaNonKelompokRiverpodProvider.notifier)
                            .resetAndFetch(search: value);
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: siswaNonKelompokState.when(
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
                              builder: (context) => DialogErrorWidget(
                                errorText: 'Error : $errorMsg',
                              ),
                            );
                          });

                          final cachedData = ref
                              .read(siswaNonKelompokRiverpodProvider.notifier)
                              .items;

                          return Expanded(
                            child: ListSiswaNonKelompokWidget(
                              listData: cachedData,
                              btnAction: (id, nama) {
                                addSiswa(id, nama);
                              },
                              isKelompok: false,
                            ),
                          );
                        },
                        data: (listSiswa) => Expanded(
                          child: ListSiswaNonKelompokWidget(
                            listData: listSiswa,
                            btnAction: (id, nama) {
                              addSiswa(id, nama);
                            },
                            isKelompok: false,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Symbols.arrow_right_rounded),
              const SizedBox(width: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Anggota Kelompok :"),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListSiswaNonKelompokWidget(
                        listData: selectedSiswa,
                        btnAction: (id, nama) {
                          removeSiswa(id, nama);
                        },
                        isKelompok: true,
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
            setState(() {
              isSubmitted = true;
            });

            final isValid = _formKey.currentState!.validate();

            // Cek empty fields utama
            if (selectedSiswa.isEmpty) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Belum ada anggota yang ditambahkan",
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
                // Ekstrak semua siswa_id dari selectedSiswa
                List<int> siswaIds = selectedSiswa
                    .map((siswa) => siswa['siswa_id'] as int)
                    .toList();

                final success = widget.dataKelompok == null
                    ? await ref
                          .read(kelompokBelajarRiverpodProvider.notifier)
                          .addKelompok(siswaId: siswaIds)
                    : await ref
                          .read(kelompokBelajarRiverpodProvider.notifier)
                          .updateKelompok(
                            kelompokId: widget.dataKelompok!.kelompokBelajarId,
                            siswaId: siswaIds,
                          );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: widget.dataKelompok == null
                          ? 'Kelompok berhasil ditambahkan'
                          : 'Kelompok berhasil diperbarui',
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
