import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:file_picker/file_picker.dart'; // ✅ tambahkan ini

class DialogImporDataSiswa extends ConsumerStatefulWidget {
  const DialogImporDataSiswa({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogImporDataSiswaState();
}

class _DialogImporDataSiswaState extends ConsumerState<DialogImporDataSiswa> {
  final _formKey = GlobalKey<FormState>();
  bool isSubmitted = false;

  String? _selectedFileName;
  String? _selectedFilePath;

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'], // hanya format excel
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
        _selectedFileName = result.files.single.name;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Impor Data Siswa",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "Pilih file dengan format dan template yang sesuai.",
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
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickExcelFile,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Klik untuk memilih file (.xls / .xlsx)",
                      suffixIcon: const Icon(Icons.attach_file),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _selectedFileName ?? '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "File harus dipilih";
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedFilePath != null)
                Text(
                  "Path: $_selectedFilePath",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // TODO: tambahkan logika impor di sini
              Navigator.pop(context);
            }
          },
          child: const Text("Impor"),
        ),
      ],
    );
  }
}
