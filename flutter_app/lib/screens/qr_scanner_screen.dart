import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme/app_theme.dart';
import '../models/scan_result.dart';
import '../providers/app_providers.dart';
import '../widgets/cyber_card.dart';
import '../widgets/risk_result_card.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  bool _isProcessing = false;
  ScanResult? _result;
  String? _errorMessage;
  String? _scannedData;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    _processPayload(code);
  }

  Future<void> _pickGalleryImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        final code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          _processPayload(code);
          return;
        }
      }

      // If mobile_scanner couldn't parse image directly, use backend image scan API
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanImage(image.path);
      setState(() {
        _isProcessing = false;
        _result = res;
      });
      ref.read(historyStateProvider.notifier).loadHistory();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to analyze gallery QR image. ${e.toString()}';
      });
    }
  }

  Future<void> _processPayload(String code) async {
    setState(() {
      _isProcessing = true;
      _scannedData = code;
      _errorMessage = null;
      _result = null;
    });

    _scannerController.stop();

    try {
      final repo = ref.read(scanRepositoryProvider);
      final res = await repo.scanQr(code);
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
          _isProcessing = false;
        });
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
      _result = null;
      _errorMessage = null;
      _scannedData = null;
    });
    _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final qrPayload = _result?.qrPayload;
    final isUpiQr = qrPayload != null && qrPayload['type'] == 'UPI_QR';

    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI QR Fraud Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_rounded),
            tooltip: 'Pick QR from Gallery',
            onPressed: _pickGalleryImage,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: AppTheme.cyberCyan),
            tooltip: 'Toggle Torch Flash',
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Camera Area
          Expanded(
            flex: 3,
            child: _scannedData == null
                ? Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _handleBarcode,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        color: Colors.black54,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_scanner_rounded, color: AppTheme.cyberCyan, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Point camera at payment QR code',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : Container(
                    width: double.infinity,
                    color: AppTheme.cardBgElevated,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 54, color: AppTheme.cyberCyan),
                        const SizedBox(height: 10),
                        const Text(
                          'QR Payload Scanned & Parsed',
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          _scannedData!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontFamily: 'monospace'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
          ),

          // Analysis Output Area
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isProcessing)
                    const CyberCard(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: AppTheme.cyberCyan),
                            SizedBox(height: 14),
                            Text(
                              'Analyzing QR VPA parameters & blacklists...',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_errorMessage != null) ...[
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
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('SCAN ANOTHER QR CODE'),
                    ),
                  ],

                  if (_result != null) ...[
                    // UPI QR Details Breakdown
                    if (isUpiQr)
                      CyberCard(
                        borderColor: AppTheme.cyberCyan,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_rounded, color: AppTheme.cyberCyan, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Extracted Payment QR Parameters',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            const Divider(height: 20, color: AppTheme.borderDark),
                            _buildQrDetailRow('Merchant / Payee Name (pn)', qrPayload['name'] ?? 'Not specified'),
                            _buildQrDetailRow('UPI VPA Address (pa)', qrPayload['vpa'] ?? 'Unknown VPA'),
                            _buildQrDetailRow('Amount (am)', qrPayload['amount']?.isNotEmpty == true ? '₹${qrPayload['amount']}' : 'Flexible / Any Amount'),
                          ],
                        ),
                      ),

                    RiskResultCard(result: _result!),

                    const SizedBox(height: 14),

                    OutlinedButton.icon(
                      onPressed: _resetScanner,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('SCAN ANOTHER QR CODE'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
