import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/config/api_config.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = ref.watch(baseUrlProvider);
    final authState = ref.watch(authStateProvider);
    final healthState = ref.watch(healthStatusProvider);
    final user = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Configuration & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Profile Header
            CyberCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.cyberCyan.withOpacity(0.2),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.cyberCyan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Authenticated User',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'User Session Active',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.threatRed),
                    tooltip: 'Logout',
                    onPressed: () => _confirmLogout(context),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Backend Server Configuration
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.dns_rounded, color: AppTheme.cyberCyan, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Backend Server Configuration',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Configure API endpoint for local development (10.0.2.2:5000), Wi-Fi LAN IP, or production Cloud.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // Quick presets
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Production Cloud'),
                        backgroundColor: currentUrl.contains('onrender') ? AppTheme.cyberCyan : AppTheme.cardBgElevated,
                        labelStyle: TextStyle(
                          color: currentUrl.contains('onrender') ? Colors.black : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        onPressed: () {
                          _urlController.text = ApiConfig.defaultProductionUrl;
                          ref.read(baseUrlProvider.notifier).updateUrl(ApiConfig.defaultProductionUrl);
                          ref.invalidate(healthStatusProvider);
                        },
                      ),
                      ActionChip(
                        label: const Text('Android Emulator (10.0.2.2:5000)'),
                        backgroundColor: currentUrl.contains('10.0.2.2') ? AppTheme.cyberCyan : AppTheme.cardBgElevated,
                        labelStyle: TextStyle(
                          color: currentUrl.contains('10.0.2.2') ? Colors.black : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        onPressed: () {
                          _urlController.text = ApiConfig.defaultEmulatorUrl;
                          ref.read(baseUrlProvider.notifier).updateUrl(ApiConfig.defaultEmulatorUrl);
                          ref.invalidate(healthStatusProvider);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Custom Flask API Base URL',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save_rounded, color: AppTheme.cyberCyan),
                        onPressed: () {
                          ref.read(baseUrlProvider.notifier).updateUrl(_urlController.text);
                          ref.invalidate(healthStatusProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Backend API URL updated successfully.')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Health Status & Diagnostics
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Backend Health Diagnostics',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.sync_rounded, color: AppTheme.cyberCyan),
                        onPressed: () => ref.invalidate(healthStatusProvider),
                      )
                    ],
                  ),
                  healthState.when(
                    loading: () => const LinearProgressIndicator(color: AppTheme.cyberCyan),
                    error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppTheme.threatRed)),
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${data['status']}', style: const TextStyle(color: AppTheme.safeGreen, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Service: ${data['service'] ?? "Flask API"}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('Database Engine: ${data['database'] ?? "Disconnected"}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('Environment: ${data['environment'] ?? "Production"}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Privacy & Local Storage
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy & Local Storage',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cleaning_services_rounded, color: AppTheme.cyberBlue),
                    title: const Text('Clear Local Scan Cache', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                    subtitle: const Text('Removes all scan history stored locally on device', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    onTap: () async {
                      await ref.read(historyStateProvider.notifier).clearAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Local scan history cleared.')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Application
            const CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI Scam Analyzer v1.0.0',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Built with Flutter, Dart Material 3 & Flask Scikit-Learn ML Engines.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Application Package: com.nandakumar.upiscamanalyzer',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Logout Session'),
        content: const Text('Are you sure you want to sign out of UPI Scam Analyzer?', style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.threatRed),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
