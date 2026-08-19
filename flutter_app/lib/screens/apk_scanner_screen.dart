import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class ApkScannerScreen extends ConsumerStatefulWidget {
  const ApkScannerScreen({super.key});

  @override
  ConsumerState<ApkScannerScreen> createState() => _ApkScannerScreenState();
}

class _ApkScannerScreenState extends ConsumerState<ApkScannerScreen> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  Future<void> _pickApkFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!file.name.toLowerCase().endsWith('.apk')) {
          setState(() {
            _errorMessage = 'Selected file is not an Android APK (.apk) file.';
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _result = null;
          _errorMessage = null;
        });

        if (file.path != null) {
          await _analyzeApk(file.path!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select file: $e';
      });
    }
  }

  Future<void> _analyzeApk(String path) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanApk(path);
      setState(() {
        _result = res;
      });
      ref.read(historyStateProvider.notifier).loadHistory();
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
        title: const Text('APK Security Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CyberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.android_rounded, color: AppTheme.safeGreen, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Scan Android APK File',
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
                    'Detects fake banking APKs, SMS OTP interceptors, overlay attacks, and suspicious permission requests before installation.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),

                  if (_selectedFile != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description_rounded, color: AppTheme.cyberCyan, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile!.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Size: ${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickApkFile,
                    icon: const Icon(Icons.file_open_rounded),
                    label: Text(_selectedFile == null ? 'SELECT APK FILE TO SCAN' : 'CHANGE APK FILE'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const CyberCard(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.cyberCyan),
                      SizedBox(height: 14),
                      Text('Decompiling Manifest & Inspecting Permissions...', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.threatRedBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.threatRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.threatRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            if (_result != null && !_isLoading) RiskResultCard(result: _result!),
          ],
        ),
      ),
    );
  }
}
