import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;
  ScanResult? _result;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _result = null;
          _errorMessage = null;
        });
        await _analyzeImage(image.path);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: $e';
      });
    }
  }

  Future<void> _analyzeImage(String path) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanImage(path);
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
        title: const Text('OCR Screenshot Scanner'),
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
                      Icon(Icons.document_scanner_rounded, color: AppTheme.cyberPurple, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Upload Screenshot for OCR Analysis',
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
                    'Extracts embedded text, QR payloads, UPI IDs, and phishing links from payment screenshots.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('GALLERY'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('CAMERA'),
                        ),
                      ),
                    ],
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
                      Text('Running OCR & Neural Scam Analysis...', style: TextStyle(color: AppTheme.textSecondary)),
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
