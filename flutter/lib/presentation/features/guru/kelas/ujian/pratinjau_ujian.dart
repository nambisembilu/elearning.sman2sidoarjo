import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'konten_daftar_pengerjaan_ujian.dart';

class PratinjauUjian extends ConsumerStatefulWidget {
  const PratinjauUjian({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PratinjauUjianState();
}

class _PratinjauUjianState extends ConsumerState<PratinjauUjian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [KontenDaftarPengerjaanUjian()],
              ),
            ),
          );
        },
      ),
    );
  }
}
