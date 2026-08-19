import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class SmsScannerScreen extends ConsumerStatefulWidget {
  const SmsScannerScreen({super.key});

  @override
  ConsumerState<SmsScannerScreen> createState() => _SmsScannerScreenState();
}

class _SmsScannerScreenState extends ConsumerState<SmsScannerScreen> {
  final _smsController = TextEditingController();
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _pasteClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _smsController.text = data.text!;
    }
  }

  Future<void> _analyzeSms() async {
    final text = _smsController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Please type or paste an SMS message to analyze.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanSms(text);
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
        title: const Text('SMS Fraud Analyzer'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.message_rounded, color: AppTheme.cyberCyan, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Analyze SMS Text',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _pasteClipboard,
                        icon: const Icon(Icons.content_paste_rounded, size: 16, color: AppTheme.cyberCyan),
                        label: const Text('Paste', style: TextStyle(color: AppTheme.cyberCyan, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scans message body using TF-IDF NLP model for financial fraud & phishing links.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _smsController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Paste or type suspicious SMS message text here...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeSms,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('ANALYZE SMS FRAUD THREAT'),
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
