import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/enums/role_user_enum.dart';
import '../../../../../core/routes/routes_name.dart';

class LoginDialog extends StatelessWidget {
  LoginDialog({super.key});

  final List<UserRole> loginOptions = [
    UserRole.admin,
    UserRole.siswa,
    UserRole.guru,
    UserRole.staff,
  ];

  IconData _getLoginIcon(UserRole userType) {
    switch (userType) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.siswa:
        return Icons.school;
      case UserRole.guru:
        return Icons.person;
      case UserRole.staff:
        return Icons.folder_special;
    }
  }

  String _getLabel(UserRole userType) {
    switch (userType) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.guru:
        return 'Guru';
      case UserRole.siswa:
        return 'Siswa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFF0062b3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Login Sebagai',
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: loginOptions.map((option) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          RoutesNames.login,
                          extra: option, // ✅ kirim enum UserRole
                        );

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0062b3),
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(
                            color: Color(0xFF0062b3),
                            width: 2,
                          ),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        children: [
                          Icon(_getLoginIcon(option), size: 28),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              _getLabel(option),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
