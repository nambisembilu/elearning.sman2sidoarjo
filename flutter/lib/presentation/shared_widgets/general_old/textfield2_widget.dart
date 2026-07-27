import 'package:flutter/material.dart';

class TextField2GeneralWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController pController;
  final bool isRequired;

  const TextField2GeneralWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.pController,
    required this.isRequired,
  });

  @override
  State<TextField2GeneralWidget> createState() =>
      _TextField2GeneralWidgetState();
}

class _TextField2GeneralWidgetState extends State<TextField2GeneralWidget> {
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                if (widget.isRequired)
                  const Text("*", style: TextStyle(color: Colors.red)),
              ],
            ),
            SizedBox(height: 2),
            if (_showError)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  "( Wajib diisi )",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 5),
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: widget.pController,
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
    );
  }
}
