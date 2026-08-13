import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import 'history_screen.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final isAdmin = user?.isAdmin ?? false;

    final pages = [
      const _DashboardHomeTab(),
      const _ScannerSelectionTab(),
      const HistoryScreen(),
      const ReportScreen(),
      if (isAdmin) const AdminScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex < pages.length ? _currentIndex : 0],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex < pages.length ? _currentIndex : 0,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security),
            label: 'Scan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeTab extends ConsumerWidget {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.asData?.value;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'User';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Security Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Security Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'EXCELLENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '98',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / 100',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI Real-time Protection Active',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Security Scanners & Tools',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // Grid of Scanners
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.25,
              children: [
                _buildActionCard(
                  context,
                  title: 'UPI Checker',
                  subtitle: 'Verify VPA & UPI ID',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.indigo,
                  route: '/scan-upi',
                ),
                _buildActionCard(
                  context,
                  title: 'Phone Checker',
                  subtitle: 'Detect Fraud Callers',
                  icon: Icons.phone_in_talk_outlined,
                  color: Colors.blue,
                  route: '/scan-phone',
                ),
                _buildActionCard(
                  context,
                  title: 'SMS Analyzer',
                  subtitle: 'ML Text Fraud Scan',
                  icon: Icons.message_outlined,
                  color: Colors.teal,
                  route: '/scan-sms',
                ),
                _buildActionCard(
                  context,
                  title: 'URL Scanner',
                  subtitle: 'Detect Phishing Links',
                  icon: Icons.link_outlined,
                  color: Colors.orange,
                  route: '/scan-url',
                ),
                _buildActionCard(
                  context,
                  title: 'OCR Scanner',
                  subtitle: 'Gallery/Camera Image',
                  icon: Icons.document_scanner_outlined,
                  color: Colors.purple,
                  route: '/scan-ocr',
                ),
                _buildActionCard(
                  context,
                  title: 'QR Scanner',
                  subtitle: 'Live Camera Scan',
                  icon: Icons.qr_code_scanner_outlined,
                  color: Colors.deepOrange,
                  route: '/scan-qr',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerSelectionTab extends StatelessWidget {
  const _ScannerSelectionTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scam Shield Scanners'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.account_balance_wallet)),
            title: const Text('UPI ID Checker'),
            subtitle: const Text('Check VPAs for scam history and risk rating'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-upi'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.phone)),
            title: const Text('Phone Number Checker'),
            subtitle: const Text('Lookup reported fraudulent phone numbers'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-phone'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.sms)),
            title: const Text('SMS Fraud Detector'),
            subtitle: const Text('Analyze text messages using AI/ML classifier'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-sms'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.link)),
            title: const Text('Phishing URL Scanner'),
            subtitle: const Text('Detect malicious domains & phishing links'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-url'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.image)),
            title: const Text('OCR Screenshot Scanner'),
            subtitle: const Text('Extract text & details from payment screenshots'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-ocr'),
          ),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.qr_code_scanner)),
            title: const Text('Native QR Scanner'),
            subtitle: const Text('Scan payment QR codes live using camera'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/scan-qr'),
          ),
        ],
      ),
    );
  }
}
