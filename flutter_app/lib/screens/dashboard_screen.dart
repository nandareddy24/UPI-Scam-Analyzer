import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/stat_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final historyState = ref.watch(historyStateProvider);
    final healthState = ref.watch(healthStatusProvider);
    final user = authState.asData?.value;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Security User';

    final scansList = historyState.asData?.value ?? [];
    final totalScans = scansList.length;
    final safeScans = scansList.where((s) => s.result.toLowerCase() == 'safe' || s.displayScore <= 40).length;
    final warningScans = scansList.where((s) => s.result.toLowerCase() == 'warning' || (s.displayScore > 40 && s.displayScore <= 70)).length;
    final dangerScans = scansList.where((s) => s.result.toLowerCase() == 'dangerous' || s.displayScore > 70).length;

    final isOnline = healthState.asData?.value['status'] == 'ok';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(historyStateProvider);
            ref.invalidate(healthStatusProvider);
          },
          color: AppTheme.cyberCyan,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cyberCyan.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppTheme.cyberCyan, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UPI Scam Analyzer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '"Protect your digital payments"',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.cyberCyan.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.cardBgElevated,
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.cyberCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Backend Health Indicator Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0x2200E676) : const Color(0x22FFB300),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOnline ? AppTheme.safeGreen : AppTheme.warningAmber,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? AppTheme.safeGreen : AppTheme.warningAmber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isOnline
                              ? 'Backend AI Models Online (Flask REST Server Connected)'
                              : 'Local Security Rules Active (Backend Reconnecting...)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOnline ? AppTheme.safeGreen : AppTheme.warningAmber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Overall Threat Summary Card
                CyberCard(
                  borderColor: AppTheme.cyberCyan.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'System Security Status',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: dangerScans > 0
                                  ? AppTheme.threatRedBg
                                  : (warningScans > 0 ? AppTheme.warningAmberBg : AppTheme.safeGreenBg),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dangerScans > 0 ? 'HIGH THREAT' : (warningScans > 0 ? 'MODERATE' : 'SECURE'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: dangerScans > 0
                                    ? AppTheme.threatRed
                                    : (warningScans > 0 ? AppTheme.warningAmber : AppTheme.safeGreen),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Metric Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: StatBadge(
                              label: 'Total Scans',
                              value: '$totalScans',
                              icon: Icons.radar_rounded,
                              color: AppTheme.cyberCyan,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBadge(
                              label: 'Safe',
                              value: '$safeScans',
                              icon: Icons.check_circle_rounded,
                              color: AppTheme.safeGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: StatBadge(
                              label: 'Warning',
                              value: '$warningScans',
                              icon: Icons.warning_rounded,
                              color: AppTheme.warningAmber,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatBadge(
                              label: 'Dangerous',
                              value: '$dangerScans',
                              icon: Icons.gpp_maybe_rounded,
                              color: AppTheme.threatRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Header
                const Text(
                  'Quick Scam Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Actions Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildQuickAction(
                      context,
                      title: 'UPI Check',
                      subtitle: 'Verify VPA Handles',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppTheme.cyberCyan,
                      onTap: () => context.push('/scan-upi'),
                    ),
                    _buildQuickAction(
                      context,
                      title: 'URL Scan',
                      subtitle: 'Phishing Detector',
                      icon: Icons.link_rounded,
                      color: AppTheme.cyberBlue,
                      onTap: () => context.push('/scan-url'),
                    ),
                    _buildQuickAction(
                      context,
                      title: 'SMS Analyzer',
                      subtitle: 'ML Fraud Detector',
                      icon: Icons.message_rounded,
                      color: const Color(0xFF00E5FF),
                      onTap: () => context.push('/scan-sms'),
                    ),
                    _buildQuickAction(
                      context,
                      title: 'QR Scanner',
                      subtitle: 'Pre-payment Check',
                      icon: Icons.qr_code_scanner_rounded,
                      color: AppTheme.cyberPurple,
                      onTap: () => context.push('/scan-qr'),
                    ),
                    _buildQuickAction(
                      context,
                      title: 'APK Scanner',
                      subtitle: 'Malware & Fraud',
                      icon: Icons.android_rounded,
                      color: AppTheme.safeGreen,
                      onTap: () => context.push('/scan-apk'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Scans Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Scan Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/history'),
                      child: const Text('View All', style: TextStyle(color: AppTheme.cyberCyan)),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                if (scansList.isEmpty)
                  CyberCard(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.shield_outlined, color: AppTheme.textMuted, size: 40),
                            SizedBox(height: 10),
                            Text(
                              'No scans performed yet.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Select a scanner above to analyze your first UPI handle or link.',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: scansList.take(4).map((scan) => _buildRecentScanItem(scan)).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CyberCard(
      onTap: onTap,
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScanItem(ScanResult scan) {
    final color = AppTheme.getRiskColor(scan.displayScore);
    return CyberCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              scan.result.toLowerCase() == 'dangerous'
                  ? Icons.gpp_maybe_rounded
                  : (scan.result.toLowerCase() == 'warning' ? Icons.warning_amber_rounded : Icons.verified_user_rounded),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.inputData,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${scan.type} Scan • ${scan.reason}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  scan.result.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${scan.displayScore}/100',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
