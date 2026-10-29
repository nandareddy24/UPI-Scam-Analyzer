import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import '../widgets/threat_meter.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDanger = result.riskLevel == RiskLevel.high;
    final isWarn = result.riskLevel == RiskLevel.medium;

    final badgeColor = isDanger
        ? AppTheme.danger
        : isWarn
            ? AppTheme.warning
            : AppTheme.safe;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Threat Analysis Verdict', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Verdict Card with ThreatMeter
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: badgeColor.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ThreatMeter(
                      score: result.score,
                      riskLevel: result.riskLevel,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      result.verdictTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        'Payload: ${result.input}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'AI Detection Findings',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ...result.reasons.map(
                (reason) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppTheme.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Safety Guidance',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_moon_rounded, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        result.advice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy Verdict'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: 'Threat Level: ${result.riskLevel.label}\nScore: ${result.score}/25\nTarget: ${result.input}\nAdvice: ${result.advice}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verdict copied to clipboard.')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                      label: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
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

