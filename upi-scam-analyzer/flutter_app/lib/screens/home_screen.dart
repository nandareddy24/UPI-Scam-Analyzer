import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/analyzer_service.dart';
import '../services/firestore_service.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';
import 'message_analyzer_screen.dart';
import 'upi_analyzer_screen.dart';
import 'url_analyzer_screen.dart';
import 'ocr_qr_scanner_screen.dart';
import 'report_scam_screen.dart';
import 'history_screen.dart';
import 'admin_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  String _activeTab = 'upi'; // upi | url | sms | ocr
  final _inputCtrl = TextEditingController();
  ScanResult? _inlineResult;
  bool _scanning = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _runInlineScan(String uid) async {
    setState(() {
      _scanning = true;
      _inlineResult = null;
    });

    final text = _inputCtrl.text.trim();
    ScanResult res;
    if (_activeTab == 'upi') {
      res = AnalyzerService.analyzeUpiId(text.isEmpty ? 'example@scamhandle' : text);
    } else if (_activeTab == 'url') {
      res = AnalyzerService.analyzeUrl(text.isEmpty ? 'http://verify-bank-account.com' : text);
    } else if (_activeTab == 'sms') {
      res = AnalyzerService.analyzeMessage(text.isEmpty ? 'URGENT: Your account is blocked. Enter OTP 4567.' : text);
    } else {
      res = AnalyzerService.analyzeOcrQr('scanned_image.png', text);
    }

    final targetUid = uid.isNotEmpty ? uid : 'local_user';
    FirestoreService().saveScan(targetUid, res);

    if (!mounted) return;
    setState(() {
      _scanning = false;
      _inlineResult = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;
    final email = user?.email ?? '';
    final uid = user?.uid ?? '';
    final isAdmin = email.trim().toLowerCase() == 'nandakumarreddy63@gmail.com';

    // Build pages dynamically based on admin role
    final List<Widget> pages = [
      _buildDashboardView(context, email, uid, isAdmin),
      const OcrQrScannerScreen(),
      const ReportScamScreen(),
      const HistoryScreen(),
    ];

    if (isAdmin) {
      pages.add(AdminScreen(userEmail: email));
    }

    // Build bottom navigation items dynamically
    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'OCR/QR'),
      const BottomNavigationBarItem(icon: Icon(Icons.report_problem_rounded), label: 'Report'),
      const BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
    ];

    if (isAdmin) {
      navItems.add(const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: 'Admin'));
    }

    // Safeguard index bound
    final safeIndex = _bottomNavIndex >= pages.length ? 0 : _bottomNavIndex;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI Scam Analyzer',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                Text(
                  'AI Threat Shield Active',
                  style: TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Scan History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.textMuted),
            tooltip: 'Log out',
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: pages[safeIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (idx) => setState(() => _bottomNavIndex = idx),
        backgroundColor: AppTheme.cardDark,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: navItems,
      ),
    );
  }

  Widget _buildDashboardView(BuildContext context, String email, String uid, bool isAdmin) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_outlined, color: AppTheme.accentCyan, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      email.isNotEmpty ? email : 'User Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppTheme.warning.withOpacity(0.2) : AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAdmin ? 'ADMIN USER' : 'USER ACCOUNT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isAdmin ? AppTheme.warning : AppTheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1930 National Cyber Helpline Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '1930',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'National Cyber Crime Helpline Active',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Report financial fraud directly to 1930',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.security_rounded, color: AppTheme.primary, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Stats Overview Row
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.verified_user_rounded,
                    title: 'Real-Time',
                    subtitle: 'Verification',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.analytics_rounded,
                    title: '99.2%',
                    subtitle: 'Scam Accuracy',
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.bolt_rounded,
                    title: 'Instant AI',
                    subtitle: 'Threat Scoring',
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // AI Threat Scanner Widget
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Threat Scanner',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan UPI Handles, Links, SMS, or QR payloads in real-time.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabChip(
                          label: '💳 UPI ID',
                          selected: _activeTab == 'upi',
                          onTap: () => setState(() {
                            _activeTab = 'upi';
                            _inlineResult = null;
                            _inputCtrl.clear();
                          }),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: '🔗 Phishing URL',
                          selected: _activeTab == 'url',
                          onTap: () => setState(() {
                            _activeTab = 'url';
                            _inlineResult = null;
                            _inputCtrl.clear();
                          }),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: '💬 SMS / Chat',
                          selected: _activeTab == 'sms',
                          onTap: () => setState(() {
                            _activeTab = 'sms';
                            _inlineResult = null;
                            _inputCtrl.clear();
                          }),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: '📷 OCR / QR',
                          selected: _activeTab == 'ocr',
                          onTap: () => setState(() {
                            _activeTab = 'ocr';
                            _inlineResult = null;
                            _inputCtrl.clear();
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _inputCtrl,
                    maxLines: _activeTab == 'sms' ? 3 : 1,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: _activeTab == 'upi'
                          ? 'e.g. refund-care@ybl or 9876543210@paytm'
                          : _activeTab == 'url'
                              ? 'e.g. http://verify-kyc-update-bank.com'
                              : _activeTab == 'sms'
                                  ? 'e.g. Your account is blocked. Verify at http://...'
                                  : 'Extracted text or upi:// pay link',
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanning ? null : () => _runInlineScan(uid),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: Text(_scanning ? 'Analyzing Payload...' : '🔍 Analyze Threat Now'),
                    ),
                  ),

                  if (_inlineResult != null) ...[
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ResultScreen(result: _inlineResult!)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _inlineResult!.riskLevel == RiskLevel.high
                              ? AppTheme.danger.withOpacity(0.12)
                              : _inlineResult!.riskLevel == RiskLevel.medium
                                  ? AppTheme.warning.withOpacity(0.12)
                                  : AppTheme.safe.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _inlineResult!.riskLevel == RiskLevel.high
                                ? AppTheme.danger
                                : _inlineResult!.riskLevel == RiskLevel.medium
                                    ? AppTheme.warning
                                    : AppTheme.safe,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _inlineResult!.riskLevel == RiskLevel.high
                                  ? Icons.gpp_maybe_rounded
                                  : Icons.verified_user_rounded,
                              color: _inlineResult!.riskLevel == RiskLevel.high
                                  ? AppTheme.danger
                                  : _inlineResult!.riskLevel == RiskLevel.medium
                                      ? AppTheme.warning
                                      : AppTheme.safe,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _inlineResult!.verdictTitle,
                                    style: TextStyle(
                                      color: _inlineResult!.riskLevel == RiskLevel.high
                                          ? AppTheme.danger
                                          : _inlineResult!.riskLevel == RiskLevel.medium
                                              ? AppTheme.warning
                                              : AppTheme.safe,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Score: ${_inlineResult!.score}/25 • Confidence: ${_inlineResult!.confidence}%',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Tools Grid Cards
            const Text(
              'Security Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.0,
              children: [
                _DashboardCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'UPI ID\nChecker',
                  subtitle: 'Inspect Handles',
                  accentColor: AppTheme.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UpiAnalyzerScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.link_rounded,
                  label: 'Phishing Link\nAnalyzer',
                  subtitle: 'Detect Malicious URLs',
                  accentColor: AppTheme.warning,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UrlAnalyzerScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.chat_rounded,
                  label: 'SMS & Chat\nScanner',
                  subtitle: 'Scan Scam Messages',
                  accentColor: AppTheme.accentCyan,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MessageAnalyzerScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'OCR Screenshot\n& QR Detector',
                  subtitle: 'Decode Pay Image/QR',
                  accentColor: AppTheme.accentPurple,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OcrQrScannerScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.report_problem_rounded,
                  label: 'Report\nScam Entity',
                  subtitle: 'Submit Fraud Handles',
                  accentColor: AppTheme.danger,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ReportScamScreen()),
                  ),
                ),
                _DashboardCard(
                  icon: Icons.history_toggle_off_rounded,
                  label: 'Scan Audit\nHistory',
                  subtitle: 'Review Past Reports',
                  accentColor: AppTheme.safe,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
                if (isAdmin)
                  _DashboardCard(
                    icon: Icons.admin_panel_settings_rounded,
                    label: 'Admin Panel\nModeration',
                    subtitle: 'Review Flags & Users',
                    accentColor: AppTheme.warning,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AdminScreen(userEmail: email)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),

            // User-Specific Recent Scans Section
            if (uid.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Recent Scans',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<ScanResult>>(
                stream: FirestoreService().watchHistory(uid.isNotEmpty ? uid : 'local_user'),
                initialData: FirestoreService().currentHistory,
                builder: (context, snapshot) {
                  final scans = snapshot.data ?? FirestoreService().currentHistory;
                  if (scans.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppTheme.primary)));
                  }
                  if (snapshot.hasError && scans.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Could not load history: ${snapshot.error}',
                        style: const TextStyle(color: AppTheme.danger, fontSize: 12),
                      ),
                    );
                  }
                  if (scans.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.shield_outlined, color: AppTheme.textMuted, size: 32),
                          SizedBox(height: 8),
                          Text(
                            'No Scans Yet under this Account',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Scans performed under your email will appear here.',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  final recent = scans.take(3).toList();
                  return Column(
                    children: recent.map((scan) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Icon(
                            scan.type == 'upi'
                                ? Icons.account_balance_wallet_rounded
                                : scan.type == 'url'
                                    ? Icons.link_rounded
                                    : Icons.chat_rounded,
                            color: scan.type == 'upi'
                                ? AppTheme.primary
                                : scan.type == 'url'
                                    ? AppTheme.warning
                                    : AppTheme.accentCyan,
                          ),
                          title: Text(
                            scan.input,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM, hh:mm a').format(scan.timestamp),
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                          trailing: RiskBadge(
                            level: scan.riskLevel,
                            score: scan.score,
                            fontSize: 10,
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ResultScreen(result: scan)),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0F172A) : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardDark,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
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
