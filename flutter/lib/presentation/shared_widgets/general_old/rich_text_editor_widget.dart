// import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

// class RichTextEditorWidget extends StatefulWidget {
//   final String title;
//   final String hintText;
//   final bool isRequired;
//   final Function(String) onChanged;

//   const RichTextEditorWidget({
//     super.key,
//     required this.title,
//     required this.hintText,
//     required this.isRequired,
//     required this.onChanged,
//   });

//   @override
//   State<RichTextEditorWidget> createState() => _RichTextEditorWidgetState();
// }

// class _RichTextEditorWidgetState extends State<RichTextEditorWidget> {
//   late HtmlEditorController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = HtmlEditorController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               widget.title,
//               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(width: 4),
//             if (widget.isRequired)
//               const Text("*", style: TextStyle(color: Colors.red)),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           height: 300,
//           child: HtmlEditor(
//             controller: controller,
//             htmlEditorOptions: HtmlEditorOptions(
//               hint: widget.hintText,
//               shouldEnsureVisible: true,
//               initialText: '',
//             ),
//             htmlToolbarOptions: const HtmlToolbarOptions(
//               toolbarPosition: ToolbarPosition.aboveEditor,
//               toolbarType: ToolbarType.nativeScrollable,
//               defaultToolbarButtons: [
//                 StyleButtons(),
//                 FontButtons(clearAll: true),
//                 ColorButtons(),
//                 ParagraphButtons(
//                   alignLeft: true,
//                   alignCenter: true,
//                   alignRight: true,
//                   alignJustify: true,
//                   lineHeight: false,
//                   decreaseIndent: true,
//                   increaseIndent: true,
//                   // ul: true,
//                   // ol: true,
//                 ),
//                 InsertButtons(link: true, table: true, hr: true),
//               ],
//             ),
//             callbacks: Callbacks(
//               onChangeContent: (String? changed) {
//                 if (changed != null) {
//                   widget.onChanged(changed);
//                 }
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
