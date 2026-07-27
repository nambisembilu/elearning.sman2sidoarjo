import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class FilterDropdownWidget2 extends StatelessWidget {
  final String pHintText;
  final String? valueParams;
  // final List<DropdownMenuItem<String>> pItems;
  final List<DropdownItem<String>> pItems;
  final ValueChanged<String?>? pOnChanged;
  final double widhtDropdown;

  const FilterDropdownWidget2({
    super.key,
    required this.pHintText,
    required this.valueParams,
    required this.pItems,
    required this.pOnChanged,
    required this.widhtDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widhtDropdown,
      height: 40,
      child: DropdownButtonFormField2<String>(
        isDense: true,
        isExpanded: true,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
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
        // value: valueParams,
        // ==== HINT SEBAGAI WIDGET ====
        hint: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            pHintText,
            style: TextStyle(
              color: Colors.blueGrey[400],
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 100,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          offset: const Offset(0, -5),
        ),
        items: pItems,
        onChanged: pOnChanged,
      ),
    );
  }
}
