// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/data_guru_model.dart';
import '../../../../controllers/staff/data_guru_riverpod.dart';
import '../../../../controllers/staff/mapel_by_jenjang_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahOrEditGuru extends ConsumerStatefulWidget {
  final Guru? dataGuru;

  const DialogTambahOrEditGuru({super.key, required this.dataGuru});

  @override
  ConsumerState<DialogTambahOrEditGuru> createState() =>
      _DialogTambahOrEditGuruState();
}

class _DialogTambahOrEditGuruState
    extends ConsumerState<DialogTambahOrEditGuru> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nipController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  String? selectedJenjangJurusan;
  String? selectedJenjang;
  String? selectedJurusan;
  String? selectedMapel;
  int? selectedIdMapel;
  List<String> daftarMapel = [];
  List<int> daftarIdMapel = [];

  @override
  void initState() {
    super.initState();

    nipController.text = widget.dataGuru?.nipNuptk.toString() ?? '';
    namaController.text = widget.dataGuru?.nama ?? '';
    emailController.text = widget.dataGuru?.email ?? '';
    telpController.text = widget.dataGuru?.nomorTelepon.toString() ?? '';
    alamatController.text = widget.dataGuru?.alamat ?? '';
    if (widget.dataGuru != null) {
      daftarMapel = widget.dataGuru!.mataPelajaran
          .map((e) => e["judul"] ?? "-")
          .toList();

      daftarIdMapel = widget.dataGuru!.mataPelajaran
          .map((e) => int.tryParse(e["array_mapel_id"] ?? "0") ?? 0)
          .toList();

      print("Daftar Mapel (init): $daftarMapel");
      print("Daftar Id Mapel (init): $daftarIdMapel");
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
            widget.dataGuru == null ? "Tambah Guru" : "Edit Guru",
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
                //jangan diubah ubah
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
                            "Informasi Dasar",
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
                            title: "NIP/NUPTK",
                            hintText: "Masukkan NIP/NUPTK",
                            p_controller: nipController,
                            isRequired: true,
                          ),
                          SizedBox(width: 15),
                          TextFieldGeneralWidget(
                            title: "Nama",
                            hintText: "Masukkan Nama",
                            p_controller: namaController,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextFieldGeneralWidget(
                            title: "Email",
                            hintText: "Masukkan Email",
                            p_controller: emailController,
                            isRequired: true,
                          ),
                          SizedBox(width: 15),
                          TextFieldGeneralWidget(
                            title: "Nomor Telepon",
                            hintText: "Masukkan Nomor Telepon",
                            p_controller: telpController,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichTextFieldGeneralWidget(
                        title: "Alamat",
                        hintText: "Masukkan Alamat",
                        p_controller: alamatController,
                        isRequired: true,
                        pMinLines: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // batas jangan diubah ubah
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
                        children: [
                          Icon(
                            Symbols.import_contacts,
                            color: Colors.black,
                            weight: 600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Mata Pelajaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // sini
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xffF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tambah Mata Pelajaran yang Diajarkan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 15),

                            // Dropdown Jenjang & Jurusan + Mapel + Tombol Tambah
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Jenjang & Jurusan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      DropdownButtonFormField<String>(
                                        menuMaxHeight: 150,
                                        style: const TextStyle(fontSize: 12),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: "Pilih Jenjang & Jurusan",
                                          hintStyle: TextStyle(
                                            color: Colors.blueGrey[400],
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                120,
                                                144,
                                                156,
                                                1,
                                              ),
                                              width: 0.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color.fromRGBO(
                                                120,
                                                144,
                                                156,
                                                1,
                                              ),
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        value: selectedJenjangJurusan,
                                        //berikan style di items nya
                                        dropdownColor: Colors.white,
                                        // itemHeight: 20,
                                        items:
                                            [
                                                  "Kelas 10 - Fase E",
                                                  "Kelas 11 - MIPA",
                                                  "Kelas 11 - IPS",
                                                  "Kelas 11 - Bahasa",
                                                  "Kelas 12 - MIPA",
                                                  "Kelas 12 - IPS",
                                                  "Kelas 12 - Bahasa",
                                                ]
                                                .map(
                                                  (e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedJenjangJurusan = value;
                                            selectedJenjang = value!
                                                .split(" - ")[0]
                                                .split(" ")[1];
                                            selectedJurusan = value.split(
                                              " - ",
                                            )[1];

                                            ref
                                                .read(
                                                  mapelByJenjangNotifierProvider
                                                      .notifier,
                                                )
                                                .fetchMapel(
                                                  jenjang: selectedJenjang!,
                                                  jurusan: selectedJurusan!,
                                                );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Mata Pelajaran",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Consumer(
                                        builder: (context, wiref, _) {
                                          final mapelByJenjangAsync = wiref
                                              .watch(
                                                mapelByJenjangNotifierProvider,
                                              );
                                          return mapelByJenjangAsync.when(
                                            loading: () =>
                                                const CircularProgressIndicator(),
                                            error: (e, st) => Text('Error: $e'),
                                            data: (mapelList) {
                                              return DropdownButtonFormField<
                                                String
                                              >(
                                                isExpanded: true,
                                                menuMaxHeight: 150,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  hintText: "Mata Pelajaran",
                                                  hintStyle: TextStyle(
                                                    color: Colors.blueGrey[400],
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    120,
                                                                    144,
                                                                    156,
                                                                    1,
                                                                  ),
                                                              width: 0.5,
                                                            ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    120,
                                                                    144,
                                                                    156,
                                                                    1,
                                                                  ),
                                                              width: 1.0,
                                                            ),
                                                      ),
                                                ),
                                                value: selectedMapel,
                                                items: [
                                                  const DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: null,
                                                    child: Text(
                                                      "Pilih mata pelajaran",
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  ...mapelList.map((mapel) {
                                                    return DropdownMenuItem<
                                                      String
                                                    >(
                                                      value: mapel.judul,
                                                      child: Text(mapel.judul),
                                                    );
                                                  }),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedMapel = value;
                                                    selectedIdMapel = mapelList
                                                        .firstWhere(
                                                          (mapel) =>
                                                              mapel.judul ==
                                                              value,
                                                        )
                                                        .id;
                                                  });
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (selectedMapel != null &&
                                        !daftarMapel.contains(selectedMapel)) {
                                      setState(() {
                                        daftarMapel.add(selectedMapel!);
                                        daftarIdMapel.add(selectedIdMapel!);
                                      });

                                      // reset dropdown
                                      selectedMapel = null;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff016EB3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(70, 48),
                                  ),
                                  icon: const Icon(Symbols.add_2),
                                  label: const Text("Tambah"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // List Mata Pelajaran
                      if (daftarMapel.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40, bottom: 60),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.menu_book,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Belum ada mata pelajaran yang ditambahkan",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "Pilih jenjang & jurusan dan mata pelajaran di atas untuk menambahkan",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mata Pelajaran yang ditambahkan:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...daftarMapel.map(
                              (e) => Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: const Icon(Icons.book, size: 20),
                                      title: Text(
                                        e,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            final index = daftarMapel.indexOf(
                                              e,
                                            ); // simpan index dulu
                                            if (index != -1) {
                                              daftarMapel.removeAt(index);
                                              daftarIdMapel.removeAt(index);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
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
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final isValid = _formKey.currentState!.validate();

            // Check empty fields
            if (nipController.text.trim().isEmpty ||
                namaController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty ||
                telpController.text.trim().isEmpty ||
                alamatController.text.trim().isEmpty ||
                daftarIdMapel.isEmpty) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText:
                      "Semua field harus diisi dan pilih minimal 1 mata pelajaran",
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
                final success = widget.dataGuru == null
                    ? await ref
                          .read(dataGuruNotifierProvider.notifier)
                          .addGuru(
                            nipNuptk: int.parse(nipController.text),
                            nama: namaController.text,
                            email: emailController.text,
                            noTelp: int.parse(telpController.text),
                            alamat: alamatController.text,
                            mapelId: daftarIdMapel,
                          )
                    : await ref
                          .read(dataGuruNotifierProvider.notifier)
                          .updateGuru(
                            userId: widget.dataGuru!.userId,
                            nipNuptk: int.parse(nipController.text),
                            nama: namaController.text,
                            email: emailController.text,
                            noTelp: int.parse(telpController.text),
                            alamat: alamatController.text,
                            mapelId: daftarIdMapel,
                          );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: widget.dataGuru == null
                          ? 'Berhasil menambahkan guru baru'
                          : 'Berhasil memperbarui data siswa',
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
