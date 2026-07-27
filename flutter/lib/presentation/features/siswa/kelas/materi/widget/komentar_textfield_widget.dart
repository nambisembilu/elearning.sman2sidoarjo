// import 'package:flutter/material.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

// class KomentarWidget extends StatelessWidget {
//   final String hintText;
//   final TextEditingController pController;
//   final bool isExpanded;

//   const KomentarWidget({
//     super.key,
//     required this.hintText,
//     required this.pController,
//     this.isExpanded = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: const [
//               Icon(Symbols.people, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 "Komentar kelas",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           // 🔹 Area komentar scrollable dengan tinggi fixed
//           Container(
//             height:
//                 isExpanded ? 300 : 200, // Tinggi berbeda untuk desktop/mobile
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(6),
//               border: Border.all(color: Colors.grey[200]!),
//             ),
//             padding: const EdgeInsets.all(12),
//             child: ListView(
//               children: const [
//                 Center(
//                   child: Text(
//                     "Belum ada komentar.",
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: SizedBox(
//                   height: 40,
//                   child: TextFormField(
//                     controller: pController,
//                     style: const TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.normal,
//                       fontSize: 14,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: hintText,
//                       hintStyle: const TextStyle(
//                         color: Colors.blueGrey,
//                         fontWeight: FontWeight.normal,
//                         fontSize: 14,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: const EdgeInsets.symmetric(
//                         vertical: 0,
//                         horizontal: 16,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade400,
//                           width: 0.5,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(6),
//                         borderSide: BorderSide(
//                           color: Colors.grey.shade600,
//                           width: 1.0,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: IconButton(
//                   onPressed: () {},
//                   icon: const Icon(Symbols.send, color: Colors.white),
//                   padding: const EdgeInsets.all(8),
//                   constraints: const BoxConstraints(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
  
//   }
// }
