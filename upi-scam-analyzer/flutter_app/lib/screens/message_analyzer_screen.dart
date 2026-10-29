import 'package:flutter/material.dart';
import '../services/analyzer_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import 'result_screen.dart';

class MessageAnalyzerScreen extends StatefulWidget {
  const MessageAnalyzerScreen({super.key});

  @override
  State<MessageAnalyzerScreen> createState() => _MessageAnalyzerScreenState();
}

class _MessageAnalyzerScreenState extends State<MessageAnalyzerScreen> {
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
    final result = AnalyzerService.analyzeMessage(text);

    final uid = AuthService().currentUser?.uid ?? 'local_user';
    FirestoreService().saveScan(uid, result.copyWith(id: 'msg_${DateTime.now().millisecondsSinceEpoch}'));

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS & Chat Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        color: AppTheme.accentCyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chat_rounded, color: AppTheme.accentCyan),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Message Text',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Paste SMS, WhatsApp, or email text to scan for scam triggers',
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
                  maxLines: 7,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. "Dear customer, your bank account is suspended. Update KYC now at http://bit.ly/kyc-fix or pay Rs 500 penalty..."',
                    labelText: 'Message Body',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('Scam SMS Sample', style: TextStyle(fontSize: 11, color: AppTheme.danger)),
                      backgroundColor: AppTheme.danger.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.danger.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'URGENT: Your Electricity bill is unpaid! Power will be disconnected at 9:30 PM today. Pay immediately to electricity-officer@ybl or call 9876543210'),
                    ),
                    ActionChip(
                      label: const Text('Normal Message', style: TextStyle(fontSize: 11, color: AppTheme.primary)),
                      backgroundColor: AppTheme.primary.withOpacity(0.12),
                      side: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                      onPressed: () => setState(() => _ctrl.text = 'Hey Ramesh, please send me the meeting minutes for today whenever you get a chance. Thanks!'),
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
                      : const Text('Run AI Message Scan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

