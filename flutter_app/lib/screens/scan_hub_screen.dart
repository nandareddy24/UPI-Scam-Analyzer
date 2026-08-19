import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'upi_scanner_screen.dart';
import 'url_scanner_screen.dart';
import 'sms_scanner_screen.dart';
import 'qr_scanner_screen.dart';
import 'ocr_scanner_screen.dart';
import 'apk_scanner_screen.dart';

class ScanHubScreen extends StatefulWidget {
  final int initialTab;

  const ScanHubScreen({super.key, this.initialTab = 0});

  @override
  State<ScanHubScreen> createState() => _ScanHubScreenState();
}

class _ScanHubScreenState extends State<ScanHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Scan Hub'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.cyberCyan,
          labelColor: AppTheme.cyberCyan,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.payment_rounded, size: 20), text: 'UPI Check'),
            Tab(icon: Icon(Icons.link_rounded, size: 20), text: 'URL Scan'),
            Tab(icon: Icon(Icons.sms_rounded, size: 20), text: 'SMS Analyzer'),
            Tab(icon: Icon(Icons.qr_code_2_rounded, size: 20), text: 'QR Scanner'),
            Tab(icon: Icon(Icons.document_scanner_rounded, size: 20), text: 'OCR Image'),
            Tab(icon: Icon(Icons.android_rounded, size: 20), text: 'APK Scan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UpiScannerScreen(),
          UrlScannerScreen(),
          SmsScannerScreen(),
          QrScannerScreen(),
          OcrScannerScreen(),
          ApkScannerScreen(),
        ],
      ),
    );
  }
}
