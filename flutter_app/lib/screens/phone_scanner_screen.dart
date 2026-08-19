import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class PhoneScannerScreen extends ConsumerStatefulWidget {
  const PhoneScannerScreen({super.key});

  @override
  ConsumerState<PhoneScannerScreen> createState() => _PhoneScannerScreenState();
}

class _PhoneScannerScreenState extends ConsumerState<PhoneScannerScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _analyzePhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter a phone number to scan.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanPhone(phone);
      setState(() {
        _result = res;
      });
      ref.read(historyStateProvider.notifier).loadHistory();
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
        title: const Text('Phone Number Checker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone_in_talk_rounded, color: AppTheme.cyberCyan, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Check Phone Number Threat Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Detects known cybercrime helpline records, spam reports & format anomalies.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+91 9876543210',
                      prefixIcon: const Icon(Icons.phone_rounded, color: AppTheme.cyberCyan),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                        onPressed: () => _phoneController.clear(),
                      ),
                    ),
                    onSubmitted: (_) => _analyzePhone(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _analyzePhone,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('CHECK PHONE NUMBER'),
                            ],
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.threatRedBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.threatRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.threatRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            if (_result != null) RiskResultCard(result: _result!),
          ],
        ),
      ),
    );
  }
}
