import 'package:flutter/material.dart';

class RichTextFieldGeneralWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController p_controller;
  final bool isRequired;
  final int pMinLines;

  const RichTextFieldGeneralWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.p_controller,
    required this.isRequired,
    required this.pMinLines,
  });

  @override
  State<RichTextFieldGeneralWidget> createState() =>
      _RichTextFieldGeneralWidgetState();
}

class _RichTextFieldGeneralWidgetState
    extends State<RichTextFieldGeneralWidget> {
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4),
            if (widget.isRequired)
              Text("*", style: TextStyle(color: Colors.red)),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  "Wajib diisi",
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        ),
        TextFormField(
          validator:
              widget.isRequired
                  ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      setState(() => _showError = true);
                    } else {
                      setState(() => _showError = false);
                    }
                    return null; // <- tidak kembalikan error, jadi border tidak merah
                  }
                  : null,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          minLines: widget.pMinLines,
          maxLines: null,
          controller: widget.p_controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.white, // background searchbar
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12, // atur jarak vertikal biar tidak mepet atas
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: const Color.fromRGBO(120, 144, 156, 1),
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: const Color.fromRGBO(120, 144, 156, 1),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
