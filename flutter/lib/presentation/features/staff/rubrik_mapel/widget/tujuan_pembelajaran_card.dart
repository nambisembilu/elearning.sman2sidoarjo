// import 'package:e_learning/general_widgets/textfield_horizontal_widget.dart';
// import 'package:flutter/widgets.dart';

// class TujuanPembelajaranCard extends StatelessWidget {
//   const TujuanPembelajaranCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFieldHorizontalGeneralWidget(
//               title: "Perlu Bimbingan",
//               hintText: "Masukkan target capaian belajar",
//               pController: index == 0 ? perluBimbinganController : null,
//               onChanged: (value) {
//                 final updatedTp = tp.copyWith(cukupBaik: value);
//                 _updateTujuanPembelajaran(index, updatedTp);
//               },
//               isRequired: false,
//             ),
//             SizedBox(height: 10),
//             TextFieldHorizontalGeneralWidget(
//               title: "Cukup",
//               hintText: "Masukkan target capaian belajar",
//               pController: index == 0 ? cukupController : null,
//               onChanged: (value) {
//                 final updatedTp = tp.copyWith(cukup: value);
//                 _updateTujuanPembelajaran(index, updatedTp);
//               },
//               isRequired: false,
//             ),
//             SizedBox(height: 10),
//             TextFieldHorizontalGeneralWidget(
//               title: "Baik",
//               hintText: "Masukkan target capaian belajar",
//               pController: index == 0 ? baikController : null,
//               onChanged: (value) {
//                 final updatedTp = tp.copyWith(baik: value);
//                 _updateTujuanPembelajaran(index, updatedTp);
//               },
//               isRequired: false,
//             ),
//             SizedBox(height: 10),
//             TextFieldHorizontalGeneralWidget(
//               title: "Sangat Baik",
//               hintText: "Masukkan target capaian belajar",
//               pController: index == 0 ? sangatBaikController : null,
//               onChanged: (value) {
//                 final updatedTp = tp.copyWith(sangatBaik: value);
//                 _updateTujuanPembelajaran(index, updatedTp);
//               },
//               isRequired: false,
//             ),
//           ],
//         );
//   }
// }