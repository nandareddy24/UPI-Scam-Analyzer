import 'package:flutter/material.dart';
import '../services/analyzer_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'result_screen.dart';

class UrlAnalyzerScreen extends StatefulWidget {
  const UrlAnalyzerScreen({super.key});

  @override
  State<UrlAnalyzerScreen> createState() => _UrlAnalyzerScreenState();
}

class _UrlAnalyzerScreenState extends State<UrlAnalyzerScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    final result = AnalyzerService.analyzeUrl(text);

    final uid = AuthService().currentUser?.uid ?? 'local_user';
    FirestoreService().saveScan(uid, result.copyWith(id: 'url_${DateTime.now().millisecondsSinceEpoch}'));

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phishing URL Analyzer', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.link_rounded, color: AppTheme.warning),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inspect Phishing Links',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Scan suspicious web links for phishing triggers',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. http://secure-kyc-verify-bank.com/login',
                    labelText: 'Website URL',
                    prefixIcon: Icon(Icons.language_rounded, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Phishing URL', style: TextStyle(fontSize: 11, color: AppTheme.danger)),
                      backgroundColor: AppTheme.danger.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'http://192.168.1.1/login-banking-secure-update.apk'),
                    ),
                    ActionChip(
                      label: const Text('Legit URL', style: TextStyle(fontSize: 11, color: AppTheme.primary)),
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'https://www.sbi.co.in/portal/web/home'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _analyze,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0F172A)),
                        )
                      : const Text('Analyze URL Threat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

