import 'package:flutter/material.dart';

class TextFieldGeneralWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController p_controller;
  final bool isRequired;

  const TextFieldGeneralWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.p_controller,
    required this.isRequired,
  });

  @override
  State<TextFieldGeneralWidget> createState() => _TextFieldGeneralWidgetState();
}

class _TextFieldGeneralWidgetState extends State<TextFieldGeneralWidget> {
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              if (widget.isRequired)
                const Text("*", style: TextStyle(color: Colors.red)),
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
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: TextFormField(
              controller: widget.p_controller,
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
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.blueGrey[400],
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(120, 144, 156, 1),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(120, 144, 156, 1),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
