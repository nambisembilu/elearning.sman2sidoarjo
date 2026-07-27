import 'package:flutter/material.dart';

import '../../../../core/helper/navigation_helper.dart';
import '../../../../models/section_keys.dart';
import 'dialogs/download_dialog.dart';
import 'dialogs/login_dialog.dart';

class Navbar extends StatelessWidget {
  final BuildContext parentContext;

  const Navbar({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          InkWell(
            onTap: () => NavigationHelper.scrollToSection(SectionKeys.homeKey),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0062b3), Color(0xFF2196F3)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.school, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'E-Learning SMANDA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0062b3),
                  ),
                ),
              ],
            ),
          ),
          // Navigation Menu
          if (MediaQuery.of(context).size.width > 768)
            Row(
              children: [
                _buildNavItem(
                  'Beranda',
                  () => NavigationHelper.scrollToSection(SectionKeys.homeKey),
                ),
                _buildNavItem(
                  'Fitur',
                  () =>
                      NavigationHelper.scrollToSection(SectionKeys.featuresKey),
                ),
                _buildNavItem(
                  'Manfaat',
                  () =>
                      NavigationHelper.scrollToSection(SectionKeys.benefitsKey),
                ),
                _buildNavItem(
                  'Cara Pakai',
                  () =>
                      NavigationHelper.scrollToSection(SectionKeys.howToUseKey),
                ),
                const SizedBox(width: 20),
                _buildLoginButton(context),
                _buildDownloadButton(context),
              ],
            )
          else
            _buildMobileMenu(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFF0062b3).withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0062b3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ElevatedButton.icon(
        onPressed: () =>
            showDialog(context: context, builder: (context) => LoginDialog()),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0062b3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        icon: const Icon(Icons.login, size: 18),
        label: const Text(
          'Masuk',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => const DownloadDialog(),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 5,
      ),
      icon: const Icon(Icons.download, size: 18),
      label: const Text(
        'Download',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildMobileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'beranda':
            NavigationHelper.scrollToSection(SectionKeys.homeKey);
            break;
          case 'fitur':
            NavigationHelper.scrollToSection(SectionKeys.featuresKey);
            break;
          case 'manfaat':
            NavigationHelper.scrollToSection(SectionKeys.benefitsKey);
            break;
          case 'carapakai':
            NavigationHelper.scrollToSection(SectionKeys.howToUseKey);
            break;
          case 'login':
            showDialog(context: context, builder: (context) => LoginDialog());
            break;
          case 'download':
            showDialog(
              context: context,
              builder: (context) => const DownloadDialog(),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'beranda',
          child: Row(
            children: [
              Icon(Icons.home, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Beranda'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'fitur',
          child: Row(
            children: [
              Icon(Icons.star, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Fitur'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'manfaat',
          child: Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Manfaat'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'carapakai',
          child: Row(
            children: [
              Icon(Icons.help, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Cara Pakai'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'login',
          child: Row(
            children: [
              Icon(Icons.login, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Masuk'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, color: Color(0xFF0062b3)),
              SizedBox(width: 10),
              Text('Download'),
            ],
          ),
        ),
      ],
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF0062b3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}
