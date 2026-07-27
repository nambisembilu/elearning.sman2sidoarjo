import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class KomentarWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController pController;

  const KomentarWidget({
    super.key,
    required this.hintText,
    required this.pController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Berikan constraints agar widget ini tidak unbounded
      constraints: BoxConstraints(
        minWidth: 300, // Atur lebar minimum sesuai kebutuhan
        maxWidth: 400, // Atur lebar maksimum sesuai kebutuhan
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Symbols.people),
                SizedBox(width: 10),
                Text("Komentar kelas"),
              ],
            ),
            const SizedBox(height: 10),
            // 🔹 Area komentar scrollable yang mengisi ruang tersisa
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: const [
                  Center(
                    child: Text(
                      "Belum ada komentar.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // const Icon(Symbols.person),
                // const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextFormField(
                      controller: pController,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: "Masukkan komentar...",
                        hintStyle: TextStyle(
                          color: Colors.blueGrey,
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
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(120, 144, 156, 1),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(120, 144, 156, 1),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(onPressed: () {}, icon: const Icon(Symbols.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
