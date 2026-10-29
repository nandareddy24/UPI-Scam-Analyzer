import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/otp_api_service.dart';
import '../theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _auth = AuthService();

  bool _otpSent = false;
  bool _loading = false;
  String? _error;
  String? _successNotice;

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  int _resendCooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailCtrl.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 45);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendCooldown <= 1) {
        t.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();

    setState(() {
      _loading = true;
      _error = null;
      _successNotice = null;
    });

    final res = await OtpApiService.sendOtp(email);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      setState(() {
        _otpSent = true;
        _successNotice = 'A 6-digit verification code was sent to $email. Please check your inbox or spam.';
      });
      _startCooldown();
    } else {
      setState(() {
        _error = res.message;
      });
    }
  }

  Future<void> _submitReset() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;
    final confirmPass = _confirmPasswordCtrl.text;

    if (newPass != confirmPass) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _auth.resetPasswordWithOtp(
      email: email,
      otp: otp,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppTheme.safe, size: 28),
              SizedBox(width: 10),
              Text('Password Reset!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            res.message ?? 'Your password has been successfully updated. You can now log in with your new password.',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(); // Back to LoginScreen
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _error = res.message ?? 'Verification failed. Please check the OTP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Icon Header
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withOpacity(0.12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, size: 36, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _otpSent
                        ? 'Enter the 6-digit OTP code sent to your email along with your new password.'
                        : 'Enter your registered email address and we will send you a 6-digit verification code.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Notice & Error Banners
                  if (_successNotice != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.safe.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.safe.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppTheme.safe, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successNotice!,
                              style: const TextStyle(color: AppTheme.safe, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.danger, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: !_otpSent ? _buildEmailStep() : _buildResetStep(),
                  ),

                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Back to Login', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Step 1 of 2: Verify Identity',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Registered Email Address',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _sendOtp,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                  )
                : const Text('Send Reset OTP Code →'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetStep() {
    return Form(
      key: _resetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Step 2 of 2: Set New Password',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              GestureDetector(
                onTap: () => setState(() => _otpSent = false),
                child: const Text('Change Email', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // OTP Field
          TextFormField(
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 6,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              labelText: '6-Digit OTP',
              counterText: '',
              prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.textMuted),
            ),
            validator: (v) {
              if (v == null || v.trim().length != 6) {
                return 'Enter the 6-digit OTP code';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // New Password Field
          TextFormField(
            controller: _newPasswordCtrl,
            obscureText: _obscureNew,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'New Password (min. 6 chars)',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordCtrl,
            obscureText: _obscureConfirm,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != _newPasswordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _loading ? null : _submitReset,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                  )
                : const Text('Verify OTP & Update Password'),
          ),

          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Didn't receive code? ", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              if (_resendCooldown > 0)
                Text(
                  'Resend in ${_resendCooldown}s',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold),
                )
              else
                GestureDetector(
                  onTap: _loading ? null : _sendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
