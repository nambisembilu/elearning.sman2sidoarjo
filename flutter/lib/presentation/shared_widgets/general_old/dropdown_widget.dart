import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropdownGeneralWidget extends StatelessWidget {
  final String pTitle;
  final String pHintText;
  final String? valueParams;
  final List<String> pItems;
  final ValueChanged<String?>? pOnChanged;
  final bool isRequired;
  final bool isSubmitted;

  const DropdownGeneralWidget({
    super.key,
    required this.pTitle,
    required this.pHintText,
    required this.valueParams,
    required this.pItems,
    required this.pOnChanged,
    required this.isRequired,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    bool showError =
        isSubmitted &&
        isRequired &&
        (valueParams == null || valueParams!.isEmpty);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                pTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              if (isRequired)
                const Text("*", style: TextStyle(color: Colors.red)),
              if (showError)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    "Wajib diisi",
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            constraints: BoxConstraints(
              minHeight: 48, // Minimum height untuk dropdown
            ),
            child: DropdownButtonFormField2<String>(
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                // hintText: pHintText,
                // hintStyle: TextStyle(
                //   color: Colors.blueGrey[400],
                //   fontWeight: FontWeight.normal,
                //   fontSize: 12,
                // ),
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
              hint: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  pHintText,
                  style: TextStyle(
                    color: Colors.blueGrey[400],
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200, // Atur tinggi maksimal dropdown menu
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                offset: const Offset(0, -5), // Sesuaikan posisi dropdown
              ),
              items: pItems
                  .map(
                    (e) => DropdownItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: pOnChanged,
            ),
          ),
        ],
      ),
    );
  }
}
