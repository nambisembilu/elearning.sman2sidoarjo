import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/filtering_model.dart';
import '../../../../controllers/staff/kelas_riverpod.dart';
import '../../../../controllers/staff/walas_tersedia_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown_widget.dart';

class DialogTambahKelas extends ConsumerStatefulWidget {
  const DialogTambahKelas({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahKelasState();
}

class _DialogTambahKelasState extends ConsumerState<DialogTambahKelas> {
  final _formKey = GlobalKey<FormState>();

  String? selectedJenjang;
  String? selectedJurusan;
  String? selectedGedung;
  String? selectedGuru;
  int? selectedUserIdGuru;

  List<WalasTersedia> daftarWalasTersedia = [];

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    // panggil fetch data walas pertama kali
    Future.microtask(() {
      ref.read(walasTersediaNotifierProvider.notifier).fetchWalasTersedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataWalasAsync = ref.watch(walasTersediaNotifierProvider);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Kelas Baru",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "Masukkan informasi kelas yang akan ditambahkan.",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Jenjang",
                            pHintText: "Pilih Jenjang",
                            valueParams: selectedJenjang,
                            pItems: ["10", "11", "12"],
                            pOnChanged: (value) {
                              setState(() {
                                selectedJenjang = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                          SizedBox(width: 16),
                          DropdownGeneralWidget(
                            pTitle: "Jurusan",
                            pHintText: "Pilih Jurusan",
                            valueParams: selectedJurusan,
                            pItems: selectedJenjang == '10'
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Gedung",
                            pHintText: "Pilih Gedung",
                            valueParams: selectedGedung,
                            pItems: ["A", "B", "C", "D"],
                            pOnChanged: (value) {
                              setState(() {
                                selectedGedung = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                          SizedBox(width: 16),
                          DropdownGeneralWidget(
                            pTitle: "Wali Kelas",
                            pHintText: "Pilih Wali Kelas",
                            valueParams: selectedGuru,
                            pItems: dataWalasAsync.when(
                              data: (walasList) {
                                daftarWalasTersedia = walasList;
                                return daftarWalasTersedia
                                    .map((e) => e.namaGuru)
                                    .toList();
                              },
                              loading: () => [],
                              error: (err, st) => [],
                            ),
                            pOnChanged: (value) {
                              setState(() {
                                selectedGuru = value;

                                final walas = daftarWalasTersedia.firstWhere(
                                  (e) => e.namaGuru == value,
                                );
                                selectedUserIdGuru = walas.userId;
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

            if (selectedJenjang == null ||
                selectedJurusan == null ||
                selectedGedung == null ||
                selectedGuru == null ||
                selectedUserIdGuru == null) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Kelas Wajib Diisi",
                ),
              );
              return;
            }

            if (isValid) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final success = await ref
                    .read(kelasNotifierProvider.notifier)
                    .addKelas(
                      jenjang: selectedJenjang!,
                      jurusan: selectedJurusan!,
                      gedung: selectedGedung!,
                      user_id: selectedUserIdGuru!,
                    );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: 'Kelas berhasil ditambahkan',
                    ),
                  );
                }
              } catch (e) {
                // Close dialog
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
