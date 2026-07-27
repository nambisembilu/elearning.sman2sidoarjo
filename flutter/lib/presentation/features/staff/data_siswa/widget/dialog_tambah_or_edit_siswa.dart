// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/data_siswa_model.dart';
import '../../../../controllers/staff/data_siswa_riverpod.dart';
import '../../../../controllers/staff/kelas_aktif_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/dropdown_widget.dart';
import '../../../../shared_widgets/general_old/rich_textfield_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahOrEditSiswa extends ConsumerStatefulWidget {
  final Siswa? dataSiswa;

  const DialogTambahOrEditSiswa({super.key, required this.dataSiswa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahOrEditSiswaState();
}

class _DialogTambahOrEditSiswaState
    extends ConsumerState<DialogTambahOrEditSiswa> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nisController = TextEditingController();
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController agamaController = TextEditingController();
  final TextEditingController noTelpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController namaWaliMuridController = TextEditingController();
  final TextEditingController alamatWaliMuridController =
      TextEditingController();
  final TextEditingController noTelpWaliMuridController =
      TextEditingController();

  String? selectedAgama;
  String? selectedJenisKelamin;
  String? selectedKelas;
  int? selectedIdKelas;
  String? selectedStatusWaliMurid;
  List<String> daftarKelasAktif = [];
  List<int> daftarIdKelasAktif = [];
  bool isOneFilled = false;
  // int? waliMuridId;

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    if (widget.dataSiswa != null) {
      nisController.text = widget.dataSiswa?.nis.toString() ?? '';
      nisnController.text = widget.dataSiswa?.nisn.toString() ?? '';
      namaController.text = widget.dataSiswa?.nama ?? '';
      agamaController.text = widget.dataSiswa?.agama ?? '';
      noTelpController.text = widget.dataSiswa?.nomorTelepon.toString() ?? '';
      emailController.text = widget.dataSiswa?.email ?? '';
      alamatController.text = widget.dataSiswa?.alamat ?? '';

      final kelas = widget.dataSiswa!.kelas[0];

      selectedIdKelas = int.parse(kelas['kelas_id'].toString());
      selectedKelas = kelas['nama_kelas'].toString();

      selectedAgama = widget.dataSiswa?.agama ?? '';
      selectedJenisKelamin = widget.dataSiswa?.jenisKelamin ?? '';
    }

    // jika ada data wali murid, isi controller
    if (widget.dataSiswa != null && widget.dataSiswa!.waliMurid.isNotEmpty) {
      final wali = widget.dataSiswa!.waliMurid[0];
      namaWaliMuridController.text = wali['nama_wm']?.toString() ?? '';
      // statusWaliMuridController.text = wali['status']?.toString() ?? '';
      alamatWaliMuridController.text = wali['alamat_wm']?.toString() ?? '';
      noTelpWaliMuridController.text = wali['no_telp_wm']?.toString() ?? '';

      // Simpan wali_murid_id
      // waliMuridId = int.parse(wali['wali_murid_id'] ?? '');

      selectedStatusWaliMurid = wali['status']?.toString() ?? '';
    }

    // fetch kelas aktif di sini
    Future.microtask(() {
      ref.read(kelasAktifNotifierProvider.notifier).fetchKelasAktif();
    });

    if (!mounted) return;

    // listener untuk deteksi ada field wali murid yang diisi
    void checkWaliMuridFields() {
      setState(() {
        isOneFilled =
            namaWaliMuridController.text.isNotEmpty ||
            alamatWaliMuridController.text.isNotEmpty ||
            noTelpWaliMuridController.text.isNotEmpty ||
            (selectedStatusWaliMurid != null &&
                selectedStatusWaliMurid!.isNotEmpty);
      });
    }

    namaWaliMuridController.addListener(checkWaliMuridFields);
    alamatWaliMuridController.addListener(checkWaliMuridFields);
    noTelpWaliMuridController.addListener(checkWaliMuridFields);
  }

  @override
  Widget build(BuildContext context) {
    final kelasAktifState = ref.watch(kelasAktifNotifierProvider);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.dataSiswa == null ? "Tambah Siswa" : "Edit Siswa",
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
                            "Informasi Siswa",
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
                            title: "NIS",
                            hintText: "Masukkan NIS",
                            p_controller: nisController,
                            isRequired: true,
                          ),
                          SizedBox(width: 15),
                          TextFieldGeneralWidget(
                            title: "NISN",
                            hintText: "Masukkan NISN",
                            p_controller: nisnController,
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
                            p_controller: noTelpController,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Kelas",
                            pHintText: "Pilih Kelas",
                            valueParams: selectedKelas,
                            pItems: kelasAktifState.when(
                              data: (kelasList) {
                                // simpan daftar id juga biar bisa mapping
                                daftarKelasAktif = kelasList
                                    .map((e) => e.nama_kelas)
                                    .toList();
                                daftarIdKelasAktif = kelasList
                                    .map((e) => e.id)
                                    .toList();
                                return daftarKelasAktif;
                              },
                              loading: () => [],
                              error: (err, st) => [],
                            ),
                            pOnChanged: (value) {
                              setState(() {
                                selectedKelas = value;
                                // mapping index ke id
                                final index = daftarKelasAktif.indexOf(
                                  value ?? "",
                                );
                                if (index != -1) {
                                  selectedIdKelas = daftarIdKelasAktif[index];
                                }
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Jenis Kelamin",
                            pHintText: "Pilih Jenis Kelamin",
                            valueParams: selectedJenisKelamin,
                            pItems: ["Perempuan", "Laki-Laki"],
                            pOnChanged: (value) {
                              setState(() {
                                selectedJenisKelamin = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
                          ),
                          const SizedBox(width: 10),
                          DropdownGeneralWidget(
                            pTitle: "Agama",
                            pHintText: "Pilih Agama",
                            valueParams: selectedAgama,
                            pItems: [
                              "Islam",
                              "Kristen",
                              "Katolik",
                              "Budha",
                              "Hindu",
                              "Konghucu",
                            ],
                            pOnChanged: (value) {
                              setState(() {
                                selectedAgama = value;
                              });
                            },
                            isRequired: true,
                            isSubmitted: isSubmitted,
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
                const SizedBox(height: 20),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.info, color: Colors.black, weight: 600),
                          const SizedBox(width: 8),
                          Text(
                            "Informasi Wali Murid",
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
                            title: "Nama Wali Murid",
                            hintText: "Masukkan Nama Wali Murid",
                            p_controller: namaWaliMuridController,
                            isRequired:
                                widget.dataSiswa != null &&
                                widget.dataSiswa!.waliMurid.isNotEmpty,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          DropdownGeneralWidget(
                            pTitle: "Status Wali Murid",
                            pHintText: "Pilih Status Wali Murid",
                            valueParams: selectedStatusWaliMurid,
                            pItems: ["Ayah", "Ibu", "Wali"],
                            pOnChanged: (value) {
                              setState(() {
                                selectedStatusWaliMurid = value;
                                if (value!.isNotEmpty) {
                                  isOneFilled = true;
                                }
                              });
                            },
                            isRequired:
                                widget.dataSiswa != null &&
                                widget.dataSiswa!.waliMurid.isNotEmpty,
                            isSubmitted: isSubmitted,
                          ),
                          const SizedBox(width: 15),
                          TextFieldGeneralWidget(
                            title: "Nomor Telepon Wali Murid",
                            hintText: "Masukkan Nomor Telpon Wali Murid",
                            p_controller: noTelpWaliMuridController,
                            isRequired:
                                widget.dataSiswa != null &&
                                widget.dataSiswa!.waliMurid.isNotEmpty,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichTextFieldGeneralWidget(
                        title: "Alamat Wali Murid",
                        hintText: "Masukkan Alamat Wali Murid",
                        p_controller: alamatWaliMuridController,
                        isRequired:
                            widget.dataSiswa != null &&
                            widget.dataSiswa!.waliMurid.isNotEmpty,
                        pMinLines: 4,
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

            print("isOneFilled : $isOneFilled");
            final isValid = _formKey.currentState!.validate();

            // Cek field wali murid
            bool isWaliMuridFilled =
                namaWaliMuridController.text.isNotEmpty ||
                alamatWaliMuridController.text.isNotEmpty ||
                noTelpWaliMuridController.text.isNotEmpty ||
                (selectedStatusWaliMurid != null &&
                    selectedStatusWaliMurid!.isNotEmpty);

            // Cek empty fields utama
            if (namaController.text.trim().isEmpty ||
                nisController.text.trim().isEmpty ||
                nisnController.text.trim().isEmpty ||
                emailController.text.trim().isEmpty ||
                noTelpController.text.trim().isEmpty ||
                alamatController.text.trim().isEmpty ||
                selectedJenisKelamin == null ||
                selectedAgama == null ||
                selectedIdKelas == null ||
                // validasi wali murid hanya jika dataSiswa ada dan waliMurid awalnya ada
                (widget.dataSiswa != null &&
                    widget.dataSiswa!.waliMurid.isNotEmpty &&
                    !isWaliMuridFilled)) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Siswa Wajib Diisi",
                ),
              );
              return;
            }

            // Validasi tambahan untuk wali murid
            if (isOneFilled) {
              if (namaWaliMuridController.text.isEmpty ||
                  alamatWaliMuridController.text.isEmpty ||
                  noTelpWaliMuridController.text.isEmpty ||
                  selectedStatusWaliMurid == null ||
                  selectedStatusWaliMurid!.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => DialogErrorWidget(
                    errorText:
                        "Lengkapi Informasi Wali Murid untuk Menambahkan wali murid",
                  ),
                );
                return;
              }
            }

            if (isValid) {
              // Print semua parameter sebelum dikirim
              print("===== DATA SISWA =====");
              print("Nama: ${namaController.text}");
              print("NIS: ${nisController.text}");
              print("NISN: ${nisnController.text}");
              print("Jenis Kelamin: $selectedJenisKelamin");
              print("Agama: $selectedAgama");
              print("Email: ${emailController.text}");
              print("No Telp: ${noTelpController.text}");
              print("Alamat: ${alamatController.text}");
              print("Kelas ID: $selectedIdKelas");
              print("===== DATA WALI MURID =====");
              print(
                "Status Wali Murid: ${isWaliMuridFilled ? selectedStatusWaliMurid : null}",
              );
              print(
                "Nama Wali Murid: ${isWaliMuridFilled ? namaWaliMuridController.text : null}",
              );
              print(
                "Alamat Wali Murid: ${isWaliMuridFilled ? alamatWaliMuridController.text : null}",
              );
              print(
                "No Telp Wali Murid: ${isWaliMuridFilled ? noTelpWaliMuridController.text : null}",
              );
              print("======================");
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                //print semua param disini
                final success = widget.dataSiswa == null
                    ? await ref
                          .read(dataSiswaNotifierProvider.notifier)
                          .addSiswa(
                            nis: int.parse(nisController.text),
                            nisn: int.parse(nisnController.text),
                            nama: namaController.text,
                            jenisKelamin: selectedJenisKelamin,
                            agama: selectedAgama,
                            email: emailController.text,
                            nomorTelepon: int.parse(noTelpController.text),
                            alamat: alamatController.text,
                            kelasId: selectedIdKelas,
                            // hanya kirim wali murid jika diisi
                            statusWaliMurid: isWaliMuridFilled
                                ? selectedStatusWaliMurid
                                : null,
                            namaWaliMurid: isWaliMuridFilled
                                ? namaWaliMuridController.text
                                : null,
                            alamatWaliMurid: isWaliMuridFilled
                                ? alamatWaliMuridController.text
                                : null,
                            noTelpWaliMurid: isWaliMuridFilled
                                ? int.tryParse(noTelpWaliMuridController.text)
                                : null,
                          )
                    : await ref
                          .read(dataSiswaNotifierProvider.notifier)
                          .updateSiswa(
                            userId: widget.dataSiswa!.userId,
                            nis: int.parse(nisController.text),
                            nisn: int.parse(nisnController.text),
                            nama: namaController.text,
                            jenisKelamin: selectedJenisKelamin,
                            agama: selectedAgama,
                            email: emailController.text,
                            nomorTelepon: int.parse(noTelpController.text),
                            alamat: alamatController.text,
                            kelasId: selectedIdKelas,
                            // hanya kirim wali murid jika diisi
                            statusWaliMurid: isWaliMuridFilled
                                ? selectedStatusWaliMurid
                                : null,
                            namaWaliMurid: isWaliMuridFilled
                                ? namaWaliMuridController.text
                                : null,
                            alamatWaliMurid: isWaliMuridFilled
                                ? alamatWaliMuridController.text
                                : null,
                            noTelpWaliMurid: isWaliMuridFilled
                                ? int.tryParse(noTelpWaliMuridController.text)
                                : null,
                          );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: widget.dataSiswa == null
                          ? 'Data siswa berhasil ditambahkan'
                          : 'Data siswa berhasil diperbarui',
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
