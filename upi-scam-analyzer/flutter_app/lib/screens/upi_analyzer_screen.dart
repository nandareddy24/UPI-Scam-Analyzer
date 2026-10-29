import 'package:flutter/material.dart';
import '../services/analyzer_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'result_screen.dart';

class UpiAnalyzerScreen extends StatefulWidget {
  const UpiAnalyzerScreen({super.key});

  @override
  State<UpiAnalyzerScreen> createState() => _UpiAnalyzerScreenState();
}

class _UpiAnalyzerScreenState extends State<UpiAnalyzerScreen> {
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
    final result = AnalyzerService.analyzeUpiId(text);

    final uid = AuthService().currentUser?.uid ?? 'local_user';
    FirestoreService().saveScan(uid, result.copyWith(id: 'upi_${DateTime.now().millisecondsSinceEpoch}'));

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI ID Checker', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inspect UPI Handle',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Check suspicious UPI handles before making payments',
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
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. refund-desk-urgent@ybl',
                    labelText: 'UPI VPA / Handle',
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Sample Scam UPI', style: TextStyle(fontSize: 11, color: AppTheme.danger)),
                      backgroundColor: AppTheme.danger.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'paytm-customer-support-refund@ybl'),
                    ),
                    ActionChip(
                      label: const Text('Sample Safe UPI', style: TextStyle(fontSize: 11, color: AppTheme.primary)),
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'user123@okicici'),
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
                      : const Text('Scan UPI Handle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

