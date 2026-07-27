import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/auth/auth_service.dart';
import 'reset_pass_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.client;

      // Generate OTP baru
      final response = await supabase.rpc(
        'generate_unique_otp',
        params: {'p_email': widget.email},
      );

      if (response == null) {
        throw Exception('Gagal generate OTP');
      }

      // Kirim email
      await supabase.functions.invoke(
        'send-otp-email',
        body: {'email': widget.email, 'otp': response.toString()},
      );

      // Restart timer
      _startResendTimer();

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP baru telah dikirim ke ${widget.email}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengirim ulang OTP. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      setState(() {
        _errorMessage = 'OTP harus 4 digit';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final supabase = SupabaseService.client;

      // Verifikasi OTP
      final user = await supabase
          .from('users')
          .select('id, reset_otp, created_at')
          .eq('email', widget.email)
          .eq('reset_otp', otp)
          .filter('deleted_at', 'is', null)
          .maybeSingle();

      if (user == null) {
        setState(() {
          _errorMessage = 'OTP tidak valid';
          _loading = false;
        });
        return;
      }

      // Cek expiry OTP (10 menit)
      final createdAtStr = user['updated_at']?.toString();
      if (createdAtStr != null) {
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt != null) {
          final now = DateTime.now();
          final diffMinutes = now.difference(createdAt).inMinutes;

          if (diffMinutes > 10) {
            setState(() {
              _errorMessage = 'OTP sudah kadaluarsa';
              _loading = false;
            });
            return;
          }
        }
      }

      // Jika OTP valid, lanjut ke halaman reset password
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordScreen(email: widget.email, otp: otp),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal verifikasi OTP: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.verified_user,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 32),

                // Judul
                const Text(
                  'Verifikasi OTP',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Masukkan OTP yang dikirim ke:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 40),

                // Form Card
                Container(
                  // width: double.infinity,
                  width: 500,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // OTP Field
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'Kode OTP',
                          hintText: 'Masukkan 4 digit kode',
                          prefixIcon: const Icon(Icons.password),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error Message
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Verifikasi OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Resend Button
                      _canResend
                          ? TextButton(
                              onPressed: _resendOtp,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, size: 16),
                                  SizedBox(width: 4),
                                  Text('Kirim ulang OTP'),
                                ],
                              ),
                            )
                          : Text(
                              'Kirim ulang dalam $_resendTimer detik',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Back Button
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16),
                            SizedBox(width: 4),
                            Text('Kembali'),
                          ],
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
    );
  }
}
