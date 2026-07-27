enum UserRole { admin, staff, guru, siswa }

extension UserRoleExtension on String {
  UserRole toUserRole() {
    final role = trim().toLowerCase();

    switch (role) {
      case 'super admin':
        return UserRole.admin; // ⬅️ ini admin asli

      case 'admin':
        return UserRole.staff; // ⬅️ ini staff

      case 'guru':
        return UserRole.guru;

      case 'siswa':
        return UserRole.siswa;

      default:
        throw Exception("Role tidak dikenali: $this");
    }
  }
}
