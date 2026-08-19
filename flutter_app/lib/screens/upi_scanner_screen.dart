import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class UpiScannerScreen extends ConsumerStatefulWidget {
  const UpiScannerScreen({super.key});

  @override
  ConsumerState<UpiScannerScreen> createState() => _UpiScannerScreenState();
}

class _UpiScannerScreenState extends ConsumerState<UpiScannerScreen> {
  final _upiController = TextEditingController();
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  bool _validateUpiFormat(String upi) {
    return RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(upi);
  }

  Future<void> _analyzeUpi() async {
    final upi = _upiController.text.trim();
    if (upi.isEmpty) {
      setState(() => _errorMessage = 'Please enter a UPI ID or VPA address.');
      return;
    }

    if (!_validateUpiFormat(upi)) {
      setState(() => _errorMessage = 'Invalid format! Valid UPI format: username@bank (e.g. merchant@upi)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanUpi(upi);
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
        title: const Text('UPI Scam Detector'),
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
                      Icon(Icons.account_balance_wallet_rounded, color: AppTheme.cyberCyan, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Analyze UPI VPA Address',
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
                    'Enter recipient UPI ID before paying (e.g. test@upi, merchant@paytm)',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _upiController,
                    decoration: InputDecoration(
                      labelText: 'UPI VPA Address',
                      hintText: 'example@upi',
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.cyberCyan),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                        onPressed: () => _upiController.clear(),
                      ),
                    ),
                    onSubmitted: (_) => _analyzeUpi(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeUpi,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.security_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('VERIFY UPI THREAT SCORE'),
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
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      ),
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
