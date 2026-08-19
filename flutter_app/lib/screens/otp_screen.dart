import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  final String purpose;
  final String? newPassword;

  const OtpScreen({
    super.key,
    required this.email,
    required this.purpose,
    this.newPassword,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit OTP sent to your email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);

      if (widget.purpose == 'registration') {
        final response = await authRepo.verifyRegistration(widget.email, otp);
        if (response.user != null) {
          await ref.read(authStateProvider.notifier).setUser(response.user);
          if (mounted) {
            context.go('/dashboard');
          }
        } else {
          setState(() {
            _errorMessage = response.message;
          });
        }
      } else {
        final response = await authRepo.resetPassword(
          widget.email,
          otp,
          widget.newPassword ?? '',
        );
        if (response.status == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated successfully! Please login.'),
                backgroundColor: AppTheme.safeGreen,
              ),
            );
            context.go('/login');
          }
        } else {
          setState(() {
            _errorMessage = response.message;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final response = await authRepo.resendOtp(widget.email, widget.purpose);
      setState(() {
        _successMessage = response.message;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Verification'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: CyberCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_rounded,
                    size: 54,
                    color: AppTheme.cyberCyan,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enter 6-Digit OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Verification code sent to:\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.threatRedBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.threatRed),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.safeGreenBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.safeGreen),
                      ),
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: AppTheme.safeGreen, fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      letterSpacing: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cyberCyan,
                    ),
                    decoration: const InputDecoration(
                      hintText: '000000',
                      counterText: '',
                    ),
                    onSubmitted: (_) => _handleVerify(),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerify,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('VERIFY & CONTINUE'),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _resendCountdown > 0 ? 'Resend code in ${_resendCountdown}s' : "Didn't receive OTP?",
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      if (_resendCountdown == 0)
                        TextButton(
                          onPressed: _isLoading ? null : _handleResend,
                          child: const Text('Resend Code', style: TextStyle(color: AppTheme.cyberCyan)),
                        ),
                    ],
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
