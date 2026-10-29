import 'package:flutter/material.dart';
import '../services/analyzer_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import 'result_screen.dart';

class OcrQrScannerScreen extends StatefulWidget {
  const OcrQrScannerScreen({super.key});

  @override
  State<OcrQrScannerScreen> createState() => _OcrQrScannerScreenState();
}

class _OcrQrScannerScreenState extends State<OcrQrScannerScreen> {
  final _qrPayloadCtrl = TextEditingController();
  final _ocrTextCtrl = TextEditingController();
  String? _ocrFileName;
  String? _qrFileName;
  bool _loading = false;

  @override
  void dispose() {
    _qrPayloadCtrl.dispose();
    _ocrTextCtrl.dispose();
    super.dispose();
  }

  void _runOcrScan() async {
    setState(() => _loading = true);
    final sample = _ocrTextCtrl.text.trim();
    final result = AnalyzerService.analyzeOcrQr(
      _ocrFileName ?? 'payment_screenshot.png',
      sample.isEmpty ? 'Suspicious UPI VPA extracted: refund-care@ybl' : sample,
    );

    final uid = AuthService().currentUser?.uid ?? 'local_user';
    FirestoreService().saveScan(uid, result.copyWith(id: 'ocr_${DateTime.now().millisecondsSinceEpoch}'));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _runQrScan() async {
    setState(() => _loading = true);
    final payload = _qrPayloadCtrl.text.trim();
    final result = AnalyzerService.analyzeOcrQr(
      _qrFileName ?? 'qr_image.png',
      payload.isEmpty ? 'upi://pay?pa=scamuser@ybl&pn=FakeRefundCare&am=4999' : payload,
    );

    final uid = AuthService().currentUser?.uid ?? 'local_user';
    FirestoreService().saveScan(uid, result.copyWith(id: 'ocr_${DateTime.now().millisecondsSinceEpoch}'));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR & QR Code Scanner'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Screenshots & QRs',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Extract and analyze text, VPAs & pay URLs',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OCR Screenshot Scanner Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.image_search_rounded, color: AppTheme.accentCyan, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'OCR Screenshot Scanner',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select a payment screenshot or paste extracted text:',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        setState(() => _ocrFileName = 'payment_proof_sample.png');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selected payment_proof_sample.png for OCR')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _ocrFileName != null ? AppTheme.primary : AppTheme.cardBorder,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: _ocrFileName != null ? AppTheme.primary : AppTheme.textMuted,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _ocrFileName ?? 'Tap to select Screenshot Image (.png, .jpg)',
                                style: TextStyle(
                                  color: _ocrFileName != null ? AppTheme.primary : AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _ocrTextCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Optional Extracted Text / Message',
                        hintText: 'e.g. Refund care request: refund-care@ybl',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _runOcrScan,
                        icon: const Icon(Icons.document_scanner_rounded, size: 18),
                        label: Text(_loading ? 'Scanning OCR...' : 'Scan Screenshot Now'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // QR Fraud Detector Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.qr_code_2_rounded, color: AppTheme.warning, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'QR Fraud Detector',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Upload a QR Code image or paste upi:// pay link:',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () {
                        setState(() => _qrFileName = 'upi_qr_code.png');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selected upi_qr_code.png')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.bgDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _qrFileName != null ? AppTheme.warning : AppTheme.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.qr_code_rounded,
                                color: _qrFileName != null ? AppTheme.warning : AppTheme.textMuted,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _qrFileName ?? 'Tap to select QR Code Image',
                                style: TextStyle(
                                  color: _qrFileName != null ? AppTheme.warning : AppTheme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _qrPayloadCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Or Paste QR Payload / UPI String',
                        hintText: 'e.g. upi://pay?pa=scam@ybl&am=4999',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warning,
                          foregroundColor: const Color(0xFF0F172A),
                        ),
                        onPressed: _loading ? null : _runQrScan,
                        icon: const Icon(Icons.fact_check_rounded, size: 18),
                        label: Text(_loading ? 'Decoding QR...' : 'Decode & Scan QR Code'),
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
