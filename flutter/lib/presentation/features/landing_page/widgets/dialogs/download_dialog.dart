import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadDialog extends StatelessWidget {
  const DownloadDialog({super.key});

  final Map<String, Map<String, dynamic>> downloadOptions = const {
    'Aplikasi E-Learning Guru': {
      'url':
          'https://drive.google.com/file/d/1l587ZaqBPeCbZhbFzbC0QTrMFjACEwwL/view?usp=sharing',
      'icon': Icons.smartphone,
      'size': '818.4 MB',
    },
    'Aplikasi Elearning Siswa': {
      'url':
          'https://drive.google.com/uc?export=download&id=1cGDtqBZrCVcbBYqnXxqvByxjMdL2JAhw',
      'icon': Icons.smartphone,
      'size': '77.5 MB',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Download Aplikasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: downloadOptions.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0062b3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              entry.value['icon'],
                              color: const Color(0xFF0062b3),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0062b3),
                            ),
                          ),
                          subtitle: Text(
                            'Ukuran: ${entry.value['size']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          onTap: () async {
                            final url = entry.value['url'];
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
