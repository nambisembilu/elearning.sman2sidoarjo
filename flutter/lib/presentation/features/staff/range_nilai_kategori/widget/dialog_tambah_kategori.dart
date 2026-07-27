import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../controllers/staff/range_nilai_kategori/range_nilai_kategori_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahKategori extends ConsumerStatefulWidget {
  const DialogTambahKategori({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahKategoriState();
}

class _DialogTambahKategoriState extends ConsumerState<DialogTambahKategori> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaKategoriController = TextEditingController();
  TextEditingController nilaiMinController = TextEditingController();
  TextEditingController nilaiMaksController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  bool isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tambah Kategori Nilai",
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
                            "Informasi Kategori Nilai",
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
                            title: "Kategori Nilai",
                            hintText: "Contoh : A",
                            p_controller: namaKategoriController,
                            isRequired: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextFieldGeneralWidget(
                            title: "Nilai Minimum",
                            hintText: "Contoh : 70",
                            p_controller: nilaiMinController,
                            isRequired: true,
                          ),
                          SizedBox(width: 10),
                          TextFieldGeneralWidget(
                            title: "Nilai Maksimum",
                            hintText: "Contoh : 80",
                            p_controller: nilaiMaksController,
                            isRequired: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          TextFieldGeneralWidget(
                            title: "Deskripsi",
                            hintText: "Contoh : Baik",
                            p_controller: deskripsiController,
                            isRequired: true,
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

            if (namaKategoriController.text.trim().isEmpty ||
                nilaiMinController.text.trim().isEmpty ||
                nilaiMaksController.text.trim().isEmpty ||
                deskripsiController.text.trim().isEmpty) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Katgeori Nilai Wajib Diisi",
                ),
              );
              return;
            }

            if (int.parse(nilaiMinController.text) >
                int.parse(nilaiMaksController.text)) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText:
                      "Nilai maksimum harus lebih besar dari nilai minimum",
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
                final success = await ref
                    .read(rangeNilaiKategoriNotifierProvider.notifier)
                    .addRangeNilaiKategori(
                      kategori: namaKategoriController.text,
                      nilaiMin: int.parse(nilaiMinController.text),
                      nilaiMaks: int.parse(nilaiMaksController.text),
                      deskripsi: deskripsiController.text,
                    );

                Navigator.pop(context);

                if (success) {
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: "Kategori nilai berhasil ditambahkan",
                    ),
                  );
                }
              } catch (e) {
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
