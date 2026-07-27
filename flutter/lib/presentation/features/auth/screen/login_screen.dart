// ignore_for_file: deprecated_member_use

import 'package:elearning_sman2sidoarjo/core/enums/role_user_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/routes_name.dart';
import '../../../shared_widgets/button/e_main_btn.dart';
import '../../../shared_widgets/textfield/e_textfield_widget.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole roleUser;

  const LoginScreen({super.key, required this.roleUser});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // context.pushReplacementNamed(RoutesNames.main, extra: state.role);
            if (state.role == UserRole.staff) {
              context.go(RoutesNames.dataGuru);
            } else if (state.role == UserRole.admin) {
              context.go(RoutesNames.daftarStaff);
            } else if (state.role == UserRole.guru) {
              context.go(RoutesNames.kelasGuru);
            } else if (state.role == UserRole.siswa) {
              context.go(RoutesNames.kelasSiswa);
            }
          }

          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400, // 🔥 batas lebar
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo/Icon Aplikasi
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.school,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul
                  const Text(
                    'Silahkan masuk',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Login
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(10, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Field Identifier
                        ETextFieldWidget(
                          controller: _identifierController,
                          labelText: 'NIP/NUPTK/NISN',
                          hintText: 'Masukkan NIP, NUPTK, atau NISN',
                        ),
                        SizedBox(height: 8),
                        ETextFieldWidget(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Masukkan Password',
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),
                        // Pesan Error
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        EMainButton(
                          onPressed: () {
                            context.read<AuthCubit>().login(
                              _identifierController.text,
                              _passwordController.text,
                            );
                          },
                          text: "Masuk",
                        ),
                        SizedBox(height: 10),
                        // Link Lupa Password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForgotPasswordScreen(), // langsung panggil kelas halaman
                              ),
                            );
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
