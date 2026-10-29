import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme.dart';

class ThreatMeter extends StatelessWidget {
  final int score;
  final int maxScore;
  final RiskLevel riskLevel;

  const ThreatMeter({
    super.key,
    required this.score,
    this.maxScore = 25,
    required this.riskLevel,
  });

  Color get _color {
    switch (riskLevel) {
      case RiskLevel.high:
        return AppTheme.danger;
      case RiskLevel.medium:
        return AppTheme.warning;
      case RiskLevel.low:
        return AppTheme.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (score / maxScore).clamp(0.0, 1.0);
    final color = _color;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: const Color(0xFF1E293B),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF151D2A),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '/ $maxScore SCORE',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          riskLevel.label.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
