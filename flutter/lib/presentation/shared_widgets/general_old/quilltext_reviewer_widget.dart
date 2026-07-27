import 'dart:convert';
import 'package:flutter/material.dart';

class SimpleRichText extends StatelessWidget {
  final String jsonContent;
  const SimpleRichText({super.key, required this.jsonContent});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> ops = jsonDecode(jsonContent);
    List<TextSpan> spans = [];

    for (var op in ops) {
      final text = op['insert'] ?? '';
      final attrs = op['attributes'] ?? {};
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            fontWeight:
                attrs['bold'] == true ? FontWeight.bold : FontWeight.normal,
            fontStyle:
                attrs['italic'] == true ? FontStyle.italic : FontStyle.normal,
            decoration:
                attrs['underline'] == true
                    ? TextDecoration.underline
                    : TextDecoration.none,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: spans,
      ),
    );
  }
}
