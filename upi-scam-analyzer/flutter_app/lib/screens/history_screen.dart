import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/scan_result.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'upi':
        return Icons.account_balance_wallet_outlined;
      case 'url':
        return Icons.link_rounded;
      case 'ocr':
        return Icons.qr_code_scanner_rounded;
      default:
        return Icons.sms_outlined;
    }
  }

  Color _accentColorFor(String type) {
    switch (type.toLowerCase()) {
      case 'upi':
        return AppTheme.primary;
      case 'url':
        return AppTheme.warning;
      case 'ocr':
        return AppTheme.safe;
      default:
        return AppTheme.accentCyan;
    }
  }

  Future<void> _confirmDelete(BuildContext context, String uid, String scanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Audit Record?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'This audit record will be permanently deleted from your account history.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService().deleteScan(uid, scanId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audit record deleted.')),
        );
      }
    }
  }

  Future<void> _confirmClearAll(BuildContext context, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All History?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text(
          'Are you sure you want to clear all your past audit logs? This cannot be undone.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService().clearAllHistory(uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All scan audit logs cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Audit History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (uid != null)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.textMuted),
              tooltip: 'Clear All History',
              onPressed: () => _confirmClearAll(context, uid),
            ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in.', style: TextStyle(color: AppTheme.textMuted)))
          : StreamBuilder<List<ScanResult>>(
              stream: FirestoreService().watchHistory(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Error Loading History',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final scans = snapshot.data ?? [];
                if (scans.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cardDark,
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 48,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Audit Records Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Run a UPI, URL, SMS, or QR threat scan from the dashboard to log your audit history.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.search_rounded, size: 18),
                            label: const Text('Run Threat Scan'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: scans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final scan = scans[i];
                    final accent = _accentColorFor(scan.type);
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_iconFor(scan.type), color: accent),
                        ),
                        title: Text(
                          scan.input,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(scan.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RiskBadge(
                              level: scan.riskLevel,
                              score: scan.score,
                              fontSize: 10,
                            ),
                            if (scan.id != null) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textMuted, size: 20),
                                tooltip: 'Delete record',
                                onPressed: () => _confirmDelete(context, uid, scan.id!),
                              ),
                            ],
                          ],
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ResultScreen(result: scan)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
