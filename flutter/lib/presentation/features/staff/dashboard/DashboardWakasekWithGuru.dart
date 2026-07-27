// import 'package:flutter/material.dart';

// // import 'DashboardStats.dart';

// class DashboardWakasekWithGuru extends StatefulWidget {
//   const DashboardWakasekWithGuru({super.key});

//   @override
//   State<DashboardWakasekWithGuru> createState() =>
//       _DashboardWakasekWithGuruState();
// }

// class _DashboardWakasekWithGuruState extends State<DashboardWakasekWithGuru> {
//   int _selectedIndex = 0;

//   void _handleMenuChange(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   Widget _getPage(int index) {
//     switch (index) {
//       // case 0:
//       //   return const DashboardStats();
//       case 0:
//         return const DataGuruScreen();
//       case 1:
//         return const DataSiswaScreen();
//       case 2:
//         return const MataPelajaranScreen();
//       case 3:
//         return JadwalPelajaranScreen();
//       case 4:
//         return TahunAjaranScreen();
//       // case 4:
//       //   return const JadwalAkademikScreen();
//       case 5:
//         return const KelasScreen();
//       // case 6:
//       //   return const RangeNilaiKategoriScreen();
//       case 6:
//         return const NilaiTugasScreen();
//       case 7:
//         return const NilaiSumatifLMScreen();
//       case 8:
//         return const NilaiUjianSumatifScreen();
//       case 9:
//         return const NilaiAkhirScreen();
//       case 10:
//         return const RubrikMapelScreen();
//       default:
//         return const Center(child: Text("Halaman Tidak Ditemukan"));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Navbar(title: ''),
//       backgroundColor: Colors.blue,
//       body: ResponsiveLayout(
//         selectedIndex: _selectedIndex,
//         onItemSelected: _handleMenuChange,
//         content: _getPage(_selectedIndex),
//       ),
//     );
//   }
// }
