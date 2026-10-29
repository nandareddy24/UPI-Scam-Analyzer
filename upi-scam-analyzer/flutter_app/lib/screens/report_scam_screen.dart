import 'package:flutter/material.dart';
import '../theme.dart';

class ReportScamScreen extends StatefulWidget {
  const ReportScamScreen({super.key});

  @override
  State<ReportScamScreen> createState() => _ReportScamScreenState();
}

class _ReportScamScreenState extends State<ReportScamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _proofCtrl = TextEditingController();

  String _category = 'UPI ID';
  bool _submitted = false;

  @override
  void dispose() {
    _targetCtrl.dispose();
    _reasonCtrl.dispose();
    _proofCtrl.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Fraudulent Scam'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _submitted
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Report Submitted Successfully!',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your report for "${_targetCtrl.text}" has been submitted for moderation.',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _submitted = false;
                              _targetCtrl.clear();
                              _reasonCtrl.clear();
                              _proofCtrl.clear();
                            });
                          },
                          child: const Text('Report Another Scam'),
                        ),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.report_problem_rounded, color: AppTheme.danger, size: 32),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Submit Fraudulent Entity',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Report suspicious handles, links or SMS to protect the community.',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Form Fields
                      const Text(
                        'Scam Category',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            dropdownColor: AppTheme.cardDark,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            items: const [
                              DropdownMenuItem(value: 'UPI ID', child: Text('💳 UPI ID / VPA Handle')),
                              DropdownMenuItem(value: 'Phishing URL', child: Text('🔗 Phishing Web Link')),
                              DropdownMenuItem(value: 'Scam Message', child: Text('💬 SMS / WhatsApp Message')),
                            ],
                            onChanged: (val) => setState(() => _category = val!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _targetCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Reported Entity / Target',
                          hintText: _category == 'UPI ID'
                              ? 'e.g. fake-refund-care@ybl'
                              : _category == 'Phishing URL'
                                  ? 'e.g. http://fake-bank-login.com'
                                  : 'e.g. +919876543210',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter the entity' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _reasonCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Reason / What Happened?',
                          hintText: 'Describe how the scam occurred (e.g. Asked for OTP/PIN)...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe the incident' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _proofCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Evidence / Notes (Optional)',
                          hintText: 'e.g. Screenshot link or message proof',
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.danger,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _submitReport,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: const Text('Submit Report for Moderation'),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
