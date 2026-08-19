import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _reasonController = TextEditingController();
  final _proofController = TextEditingController();
  String _selectedType = 'UPI';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final List<String> _types = ['UPI', 'Phone', 'SMS', 'URL', 'Other'];

  @override
  void dispose() {
    _dataController.dispose();
    _reasonController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final repo = ref.read(reportRepositoryProvider);
      final msg = await repo.submitReport(
        type: _selectedType,
        inputData: _dataController.text.trim(),
        reason: _reasonController.text.trim(),
        proofData: _proofController.text.trim().isNotEmpty ? _proofController.text.trim() : null,
      );

      setState(() {
        _successMessage = msg;
        _dataController.clear();
        _reasonController.clear();
        _proofController.clear();
      });
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
        title: const Text('Community Fraud Reporting'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CyberCard(
                borderColor: AppTheme.threatRed.withOpacity(0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem_rounded, color: AppTheme.threatRed, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Submit Community Fraud Report',
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
                      'Report scam UPI IDs, phishing URLs, or fraud phone numbers to protect digital payment users.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.threatRedBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.threatRed),
                        ),
                        child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.safeGreenBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.safeGreen),
                        ),
                        child: Text(_successMessage!, style: const TextStyle(color: AppTheme.safeGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Scam Type',
                        prefixIcon: Icon(Icons.category_rounded, color: AppTheme.cyberCyan),
                      ),
                      dropdownColor: AppTheme.cardBgElevated,
                      items: _types
                          .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: AppTheme.textPrimary))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: 'Scam Target / UPI ID / Phone / URL',
                        hintText: 'e.g. scammer@upi or 9876543210',
                        prefixIcon: Icon(Icons.shield_outlined, color: AppTheme.cyberCyan),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the fraudulent target handle/number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Incident Description / Details',
                        hintText: 'Describe how the fraud attempt occurred...',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide details of the incident';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _proofController,
                      decoration: const InputDecoration(
                        labelText: 'Proof Evidence Reference / Txn ID (Optional)',
                        hintText: 'e.g. Txn ID or screenshot link',
                        prefixIcon: Icon(Icons.attachment_rounded, color: AppTheme.cyberCyan),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.threatRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _submitReport,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 20),
                                SizedBox(width: 8),
                                Text('SUBMIT FRAUD REPORT'),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
