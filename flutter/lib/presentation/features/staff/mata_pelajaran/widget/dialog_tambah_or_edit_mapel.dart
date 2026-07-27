// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/filtering_model.dart';
import '../../../../../models/staff/mata_pelajaran_model.dart';
import '../../../../controllers/staff/mata_pelajaran_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahOrEditMapel extends ConsumerStatefulWidget {
  final MataPelajaran? dataMapel;

  const DialogTambahOrEditMapel({super.key, required this.dataMapel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahOrEditMapelState();
}

class _DialogTambahOrEditMapelState
    extends ConsumerState<DialogTambahOrEditMapel> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaMataPelajaran = TextEditingController();

  String? selecteJenjang;
  String? selectedJurusan;
  String? selectedGuru;
  int? selectedGuruUserId;

  bool isSubmitted = false;

  List<FilterGuru> listGuruNonKoor = [];

  @override
  void initState() {
    super.initState();

    _loadGuruNonKoor();
  }

  Future<void> _loadGuruNonKoor() async {
    try {
      final listGuru = await ref
          .read(mataPelajaranNotifierProvider.notifier)
          .fetchGuruNonKoorMapel();

      if (!mounted) return;

      setState(() {
        listGuruNonKoor = listGuru;
      });
    } catch (e) {
      print("Error loading guru non koor mapel : $e");
      if (mounted) {
        setState(() {
          listGuruNonKoor = [];
          selectedGuru = listGuruNonKoor.first.namaGuru;
          selectedGuruUserId = listGuruNonKoor.first.userId;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.dataMapel == null
                ? "Tambah Mata Pelajaran"
                : "Edit Mata Pelajaran",
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
                            "Informasi Mata Pelajaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          TextFieldGeneralWidget(
                            title: "Nama Mata Pelajaran",
                            hintText: "Masukkan Nama Mata Pelajaran",
                            p_controller: namaMataPelajaran,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Koordinator Mata Pelajaran",
                            pHintText: "Pilih guru",
                            valueParams: selectedGuru,
                            pItems: listGuruNonKoor
                                .map((e) => e.namaGuru)
                                .toList(),
                            pOnChanged: (value) {
                              if (value != null) {
                                final selected = listGuruNonKoor.firstWhere(
                                  (e) => e.namaGuru == value,
                                );

                                setState(() {
                                  selectedGuruUserId = selected.userId;
                                  selectedGuru = selected.namaGuru;
                                });
                              }
                            },
                            isRequired: false,
                            isSubmitted: isSubmitted,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Jenjang",
                            pHintText: "Pilih Jenjang",
                            valueParams: selecteJenjang,
                            pItems: ["10", "11", "12"],
                            pOnChanged: (value) {
                              setState(() {
                                selecteJenjang = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                          const SizedBox(width: 10),
                          DropdownGeneralWidget(
                            pTitle: "Jurusan",
                            pHintText: "Pilih Jurusan",
                            valueParams: selectedJurusan,
                            pItems: selecteJenjang == '10'
                                ? ["Fase E"]
                                : ["MIPA", "IPS", "Bahasa"],
                            pOnChanged: (value) {
                              setState(() {
                                selectedJurusan = value;
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
                // const SizedBox(height: 20),
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
            if (namaMataPelajaran.text.trim().isEmpty ||
                selecteJenjang == null ||
                selectedJurusan == null) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Mata Pelajaran Wajib Diisi",
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
                //print semua param disini
                final success = await ref
                    .read(mataPelajaranNotifierProvider.notifier)
                    .addMataPelajaran(
                      judul: namaMataPelajaran.text,
                      jenjang: selecteJenjang!,
                      jurusan: selectedJurusan!,
                      userId: selectedGuruUserId,
                    );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: 'Mata Pelajaran berhasil ditambahkan',
                    ),
                  );
                }
              } catch (e) {
                // Remove loading indicator
                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => DialogErrorWidget(
                    errorText: widget.dataMapel == null
                        ? 'Gagal menambahkan mata pelajaran: ${e.toString()}'
                        : 'Gagal memperbarui mata pelajaran: ${e.toString()}',
                  ),
                );
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
