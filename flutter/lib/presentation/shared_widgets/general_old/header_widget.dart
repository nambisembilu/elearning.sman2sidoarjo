import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HeaderWidget extends StatelessWidget {
  final String headerTitle;
  final String btnAddTitle;
  final bool showExportBtn;
  final bool showImportBtn;
  final bool showAddBtn;
  final VoidCallback? importAction;
  final VoidCallback? exportAction;
  final VoidCallback? addAction;

  const HeaderWidget({
    super.key,
    required this.headerTitle,
    required this.btnAddTitle,
    required this.showExportBtn,
    required this.showImportBtn,
    required this.showAddBtn,
    required this.addAction,
    required this.exportAction,
    required this.importAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700; // breakpoint responsif

        // daftar tombol
        List<Widget> buttons = [
          if (showExportBtn)
            ElevatedButton.icon(
              onPressed: exportAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(120, 50),
              ),
              icon: const Icon(Symbols.download),
              label: const Text("Ekspor Data"),
            ),
          if (showImportBtn)
            ElevatedButton.icon(
              onPressed: importAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(120, 50),
              ),
              icon: const Icon(Symbols.upload),
              label: const Text("Impor Data"),
            ),
          if (showAddBtn)
            ElevatedButton.icon(
              onPressed: addAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff016EB3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                minimumSize: const Size(120, 50),
              ),
              icon: const Icon(Symbols.add_circle),
              label: Text(btnAddTitle),
            ),
        ];

        if (isWide) {
          // layar lebar → sejajar
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                children: buttons,
              ),
            ],
          );
        } else {
          // layar kecil → title di atas, tombol di bawah
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: buttons),
            ],
          );
        }
      },
    );
  }
}
