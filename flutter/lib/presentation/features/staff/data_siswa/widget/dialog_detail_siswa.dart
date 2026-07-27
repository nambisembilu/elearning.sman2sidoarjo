import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../../models/staff/data_siswa_model.dart';

class DialogDetailSiswa extends StatefulWidget {
  final Siswa siswa;
  const DialogDetailSiswa({super.key, required this.siswa});

  @override
  State<DialogDetailSiswa> createState() => _DialogDetailSiswaState();
}

class _DialogDetailSiswaState extends State<DialogDetailSiswa>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Detail Siswa"),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Symbols.close, color: Colors.black, weight: 600),
          ),
        ],
      ),
      content: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xff016EB3),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade700,
              dividerColor: Colors.transparent, // Remove divider
              tabs: const [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Profil Siswa"),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Wali Murid"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  //tab 1
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Row(children: [
                        ],
                      )],
                  ),
                  // tab 2
                  Column(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
