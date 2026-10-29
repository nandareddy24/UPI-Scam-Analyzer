import 'package:flutter/material.dart';
import '../theme.dart';

class AdminScreen extends StatefulWidget {
  final String userEmail;
  const AdminScreen({super.key, required this.userEmail});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<Map<String, String>> _reports = [
    {
      'type': 'UPI',
      'target': 'refund-fake-helpdesk@ybl',
      'reason': 'Asked user to accept UPI collect request of ₹4,999 to claim fake GPay refund.',
      'status': 'Pending',
    },
    {
      'type': 'URL',
      'target': 'http://192.168.1.55/update-kyc-bank',
      'reason': 'SMS claiming bank account will be blocked without immediate KYC update.',
      'status': 'Pending',
    },
    {
      'type': 'SMS',
      'target': '+919876543210',
      'reason': 'Lottery win SMS claiming ₹25 Lakhs reward via KBC WhatsApp.',
      'status': 'Pending',
    },
  ];

  final List<Map<String, String>> _blacklists = [
    {'target': 'lottery-winner-kbc@ybl', 'type': 'UPI'},
    {'target': 'http://verify-bank-account-gpay.com', 'type': 'URL'},
  ];

  final _blacklistCtrl = TextEditingController();
  String _selectedType = 'UPI';

  void _approveReport(int index) {
    setState(() {
      final rep = _reports[index];
      rep['status'] = 'Approved';
      _blacklists.add({'target': rep['target']!, 'type': rep['type']!});
    });
  }

  void _rejectReport(int index) {
    setState(() {
      _reports[index]['status'] = 'Rejected';
    });
  }

  void _addBlacklist() {
    final text = _blacklistCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _blacklists.add({'target': text, 'type': _selectedType});
      _blacklistCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userEmail.trim().toLowerCase() == 'nandakumarreddy63@gmail.com';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Console')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, color: AppTheme.danger, size: 48),
                SizedBox(height: 14),
                Text(
                  'Access Denied',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Only authorized admin users (nandakumarreddy63@gmail.com) can access moderation controls.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Moderation Console', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ADMIN', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 11)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Moderation Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(widget.userEmail, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primary, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Moderation rights belong to nandakumarreddy63@gmail.com.',
                          style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Text(
                'Community Reports Queue',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),

              ...List.generate(_reports.length, (index) {
                final r = _reports[index];
                final isApproved = r['status'] == 'Approved';
                final isRejected = r['status'] == 'Rejected';
                final statusColor = isApproved
                    ? AppTheme.primary
                    : isRejected
                        ? AppTheme.danger
                        : AppTheme.warning;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r['type']!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Text(
                            r['status']!.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              color: statusColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r['target']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r['reason']!,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                      ),
                      const SizedBox(height: 14),

                      if (r['status'] == 'Pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                minimumSize: const Size(110, 38),
                              ),
                              onPressed: () => _approveReport(index),
                              child: const Text('Approve', style: TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.danger,
                                side: const BorderSide(color: AppTheme.danger),
                                minimumSize: const Size(80, 38),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () => _rejectReport(index),
                              child: const Text('Reject', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              const Text(
                'Manual Blacklist Addition',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1E293B),
                        value: _selectedType,
                        items: const [
                          DropdownMenuItem(value: 'UPI', child: Text('UPI', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'URL', child: Text('URL', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'SMS', child: Text('SMS', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _blacklistCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter handle/link to blacklist',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(70, 52)),
                    onPressed: _addBlacklist,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

