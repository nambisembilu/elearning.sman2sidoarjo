// import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

// class HtmlTextEditor extends StatefulWidget {
//   final HtmlEditorController controller;
//   final String hint;
//   final double height;
//   final Function(String)? onChanged;

//   const HtmlTextEditor({
//     super.key,
//     required this.controller,
//     this.hint = "Tulis konten di sini...",
//     this.height = 300,
//     this.onChanged,
//   });

//   @override
//   State<HtmlTextEditor> createState() => _HtmlTextEditorState();
// }

// class _HtmlTextEditorState extends State<HtmlTextEditor> {
//   @override
//   Widget build(BuildContext context) {
//     return HtmlEditor(
//       controller: widget.controller,
//       htmlEditorOptions: HtmlEditorOptions(
//         hint: widget.hint,
//         shouldEnsureVisible: true,
//       ),
//       htmlToolbarOptions: const HtmlToolbarOptions(
//         defaultToolbarButtons: [
//           StyleButtons(),
//           FontButtons(),
//           ColorButtons(),
//           ListButtons(),
//           ParagraphButtons(),
//           InsertButtons(picture: true, link: true, video: true),
//         ],
//       ),
//       otherOptions: OtherOptions(height: widget.height),
//       callbacks: Callbacks(
//         onChangeContent: (String? value) {
//           if (widget.onChanged != null && value != null) {
//             widget.onChanged!(value);
//           }
//         },
//       ),
//     );
//   }
// }
