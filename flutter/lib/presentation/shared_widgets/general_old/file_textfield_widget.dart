import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class FileTextFieldWidget extends StatelessWidget {
  final String title;
  final VoidCallback? addFileAction;

  const FileTextFieldWidget({
    super.key,
    required this.title,
    required this.addFileAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: addFileAction,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(10),
            dashPattern: [6, 3], // 6px garis, 3px spasi
            color: Colors.grey,
            strokeWidth: 2,
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.upload),
                  Text("Klik untuk upload file"),
                  Text("PDF,DOC,PPT,XLS,MP3,MP4"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
