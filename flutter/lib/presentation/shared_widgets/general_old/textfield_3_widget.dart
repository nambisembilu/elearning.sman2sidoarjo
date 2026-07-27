import 'package:flutter/material.dart';

class Textfield3Widget extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController? pController; // Jadikan nullable
  final bool isRequired;
  final ValueChanged<String>? onChanged; // Tambahkan onChanged

  const Textfield3Widget({
    super.key,
    required this.title,
    required this.hintText,
    this.pController, // Jadikan optional
    required this.isRequired,
    this.onChanged, // Tambahkan onChanged
  });

  @override
  State<Textfield3Widget> createState() =>
      _Textfield3WidgetState();
}

class _Textfield3WidgetState extends State<Textfield3Widget> {
  bool _showError = false;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    // Gunakan controller yang diberikan atau buat internal controller
    _internalController = widget.pController ?? TextEditingController();
  }

  @override
  void didUpdateWidget(Textfield3Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika controller external berubah, update internal controller
    if (widget.pController != null &&
        widget.pController != oldWidget.pController) {
      _internalController = widget.pController!;
    }
  }

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
            const SizedBox(height: 2),
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
        const SizedBox(height: 5),
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: _internalController,
            onChanged: (value) {
              // Panggil callback onChanged jika ada
              widget.onChanged?.call(value);

              // Validasi jika required
              if (widget.isRequired) {
                setState(() {
                  _showError = value.trim().isEmpty;
                });
              }
            },
            validator:
                widget.isRequired
                    ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        setState(() => _showError = true);
                        return ''; // Return empty string to avoid default error UI
                      } else {
                        setState(() => _showError = false);
                      }
                      return null;
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
              // Hilangkan error border untuk menjaga konsistensi
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(120, 144, 156, 1),
                  width: 0.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(120, 144, 156, 1),
                  width: 1.0,
                ),
              ),
              // Hilangkan error text karena kita sudah menampilkannya di samping
              errorText: null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Hanya dispose internal controller, bukan external controller
    if (widget.pController == null) {
      _internalController.dispose();
    }
    super.dispose();
  }
}
