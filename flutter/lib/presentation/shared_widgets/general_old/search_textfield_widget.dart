import 'package:flutter/material.dart';

class SearchTextFieldWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChangedSearch;

  const SearchTextFieldWidget({
    super.key,
    required this.hintText,
    required this.onChangedSearch,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: SizedBox(
        height: 40,
        child: TextField(
          // style: TextStyle(fontSize: 14, color: Colors.grey[350]),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.blueGrey[400],
              size: 20,
            ), // ikon di kiri
            filled: true,
            fillColor: Colors.white, // background searchbar
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
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
          onChanged: onChangedSearch,
        ),
      ),
    );
  }
}
