// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;

// class QuillTextfiledWidget extends StatefulWidget {
//   final quill.QuillController textController;
//   final bool isRequired;

//   const QuillTextfiledWidget({
//     super.key,
//     required this.textController,
//     required this.isRequired,
//   });

//   @override
//   State<QuillTextfiledWidget> createState() => QuillTextfiledWidgetState();
// }

// class QuillTextfiledWidgetState extends State<QuillTextfiledWidget> {
//   bool _showError = false;

//   /// Validasi text
//   bool validate() {
//     final plainText = widget.textController.document.toPlainText().trim();

//     if (widget.isRequired && plainText.isEmpty) {
//       setState(() => _showError = true);
//       return false;
//     } else {
//       setState(() => _showError = false);
//       return true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.12,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Text(
//                     "Deskripsi",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   ),
//                   const SizedBox(width: 4),
//                   if (widget.isRequired)
//                     const Text("*", style: TextStyle(color: Colors.red)),
//                 ],
//               ),
//               const SizedBox(height: 2),
//               if (_showError)
//                 const Padding(
//                   padding: EdgeInsets.only(left: 4),
//                   child: Text(
//                     "( Wajib diisi )",
//                     style: TextStyle(color: Colors.red, fontSize: 12),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 5),

//         /// ===============================
//         /// 🔥 Quill Editor (flutter_quill 2.0.7)
//         /// ===============================
//         Container(
//           height: 300,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             children: [
//               /// 🔹 Toolbar basic (pengganti QuillSimpleToolbar)
//               quill.QuillToolbar.basic(
//                 controller: widget.textController,
//                 multiRowsDisplay: false,
//               ),

//               /// 🔹 Editor basic
//               Expanded(
//                 child: quill.QuillEditor(
//                   controller: widget.textController,
//                   scrollController: ScrollController(),
//                   scrollable: true,
//                   focusNode: FocusNode(),
//                   autoFocus: false,
//                   readOnly: false,
//                   expands: true,
//                   padding: const EdgeInsets.all(10),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
