import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class UrlScannerScreen extends ConsumerStatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  ConsumerState<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends ConsumerState<UrlScannerScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _analyzeUrl() async {
    var url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Please enter or paste a website URL to scan.');
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
      _urlController.text = url;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanUrl(url);
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
        title: const Text('Phishing URL Scanner'),
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
                      Icon(Icons.link_rounded, color: AppTheme.cyberBlue, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Scan Website URL for Phishing',
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
                    'Evaluates domain structure, WHOIS, VirusTotal & Google Safe Browsing APIs',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: 'Web Link URL',
                      hintText: 'https://example-phishing-bank.com',
                      prefixIcon: const Icon(Icons.language_rounded, color: AppTheme.cyberBlue),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textMuted),
                        onPressed: () => _urlController.clear(),
                      ),
                    ),
                    onSubmitted: (_) => _analyzeUrl(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _analyzeUrl,
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
                              Text('SCAN LINK FOR THREATS'),
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
