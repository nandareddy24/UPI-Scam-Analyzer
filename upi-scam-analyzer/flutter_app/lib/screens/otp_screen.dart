import 'package:flutter/material.dart';
import '../services/otp_api_service.dart';
import '../services/auth_service.dart';
import '../theme.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;
  const OtpScreen({super.key, required this.email, required this.password});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _auth = AuthService();

  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyAndCreateAccount() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      setState(() => _error = 'Enter the 6-digit code sent to your email.');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    final verifyResult = await OtpApiService.verifyOtp(widget.email, otp);

    if (!verifyResult.success) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = verifyResult.message;
      });
      return;
    }

    final signupResult = await _auth.signUp(widget.email, widget.password);

    if (!mounted) return;
    setState(() => _verifying = false);

    if (!signupResult.success) {
      setState(() => _error = signupResult.message);
      return;
    }

    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _resendOtp() async {
    setState(() {
      _resending = true;
      _error = null;
    });
    final result = await OtpApiService.sendOtp(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success ? 'A new verification code was sent to your email.' : result.message),
        backgroundColor: result.success ? AppTheme.primaryDark : AppTheme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.15),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 48,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Enter Verification Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We sent a 6-digit code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _otpCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        letterSpacing: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          letterSpacing: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _verifying ? null : _verifyAndCreateAccount,
                      child: _verifying
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF0F172A),
                              ),
                            )
                          : const Text('Verify & Activate Account'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _resending ? null : _resendOtp,
                      child: Text(
                        _resending ? 'Sending new code...' : "Didn't receive the code? Resend",
                        style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

