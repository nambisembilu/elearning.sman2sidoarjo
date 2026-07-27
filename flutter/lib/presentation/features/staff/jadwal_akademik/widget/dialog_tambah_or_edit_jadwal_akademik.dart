import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../../models/staff/jadwal_akademik_model.dart';
import '../../../../controllers/staff/jadwal_akademik_riverpod.dart';
import '../../../../shared_widgets/general_old/dialog_error_widget.dart';
import '../../../../shared_widgets/general_old/dialog_success_widget.dart';
import '../../../../shared_widgets/general_old/textfield_widget.dart';

class DialogTambahOrEditJadwalAkademik extends ConsumerStatefulWidget {
  final JadwalAkademik? dataJadwalAkademik;

  const DialogTambahOrEditJadwalAkademik({
    super.key,
    required this.dataJadwalAkademik,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogTambahOrEditJadwalAkademikState();
}

class _DialogTambahOrEditJadwalAkademikState
    extends ConsumerState<DialogTambahOrEditJadwalAkademik> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaKegiatan = TextEditingController();
  final TextEditingController tanggalMulaiController = TextEditingController();
  final TextEditingController tanggalSelesaiController =
      TextEditingController();

  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;

  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();

    if (widget.dataJadwalAkademik != null) {
      namaKegiatan.text = widget.dataJadwalAkademik!.namaKegiatan;
      tanggalMulai = widget.dataJadwalAkademik!.tanggalMulai;
      tanggalSelesai = widget.dataJadwalAkademik!.tanggalSelesai;

      tanggalMulaiController.text =
          "${tanggalMulai!.day.toString().padLeft(2, '0')}-${tanggalMulai!.month.toString().padLeft(2, '0')}-${tanggalMulai!.year}";
      tanggalSelesaiController.text =
          "${tanggalSelesai!.day.toString().padLeft(2, '0')}-${tanggalSelesai!.month.toString().padLeft(2, '0')}-${tanggalSelesai!.year}";
    }
  }

  Future<void> _pickDate({
    required BuildContext context,
    required bool isMulai,
  }) async {
    final initialDate = isMulai
        ? (tanggalMulai ?? DateTime.now())
        : (tanggalSelesai ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isMulai) {
          tanggalMulai = picked;
          tanggalMulaiController.text =
              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        } else {
          tanggalSelesai = picked;
          tanggalSelesaiController.text =
              "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
        }
      });
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
            widget.dataJadwalAkademik == null
                ? "Tambah Jadwal Akademik"
                : "Edit Jadwal Akademik",
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
                            "Informasi Jadwal Akademik",
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
                            title: "Nama Kegiatan",
                            hintText: "Masukkan Nama Kegiatan",
                            p_controller: namaKegiatan,
                            isRequired: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanggal Mulai",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () =>
                                _pickDate(context: context, isMulai: true),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tanggalMulaiController.text.isEmpty
                                    ? "Pilih tanggal mulai"
                                    : tanggalMulaiController.text,
                                style: TextStyle(
                                  color: tanggalMulaiController.text.isEmpty
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanggal Selesai",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () =>
                                _pickDate(context: context, isMulai: false),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tanggalSelesaiController.text.isEmpty
                                    ? "Pilih tanggal selesai"
                                    : tanggalSelesaiController.text,
                                style: TextStyle(
                                  color: tanggalSelesaiController.text.isEmpty
                                      ? Colors.grey
                                      : Colors.black,
                                ),
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
            if (namaKegiatan.text.trim().isEmpty) {
              showDialog(
                context: context,
                builder: (context) => DialogErrorWidget(
                  errorText: "Semua Informasi Jadwal Akademik Wajib Diisi",
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
                final success = widget.dataJadwalAkademik == null
                    ? await ref
                          .read(jadwalAkademikRiverpodProvider.notifier)
                          .addJadwalAkademik(
                            namaKegiatan: namaKegiatan.text,
                            tanggalMulai: tanggalMulai!,
                            tanggalSelesai: tanggalSelesai!,
                          )
                    : await ref
                          .read(jadwalAkademikRiverpodProvider.notifier)
                          .updateJadwalAkademik(
                            JadwalAkademikId: widget.dataJadwalAkademik!.id,
                            namaKegiatan: namaKegiatan.text,
                            tanggalMulai: tanggalMulai!,
                            tanggalSelesai: tanggalSelesai!,
                          );

                // Remove loading indicator
                Navigator.pop(context);

                if (success) {
                  // Close dialog
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => DialogSuccessWidget(
                      succesText: widget.dataJadwalAkademik == null
                          ? 'Jadwal Akademik berhasil ditambahkan'
                          : 'Jadwal Akademik berhasil diperbarui',
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
