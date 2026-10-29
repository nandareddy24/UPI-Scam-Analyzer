import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme.dart';

class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final int score;
  final bool showScore;
  final double fontSize;

  const RiskBadge({
    super.key,
    required this.level,
    required this.score,
    this.showScore = true,
    this.fontSize = 12,
  });

  Color get _color {
    switch (level) {
      case RiskLevel.high:
        return AppTheme.danger;
      case RiskLevel.medium:
        return AppTheme.warning;
      case RiskLevel.low:
        return AppTheme.safe;
    }
  }

  IconData get _icon {
    switch (level) {
      case RiskLevel.high:
        return Icons.gpp_bad_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.low:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: color, size: fontSize + 4),
          const SizedBox(width: 6),
          Text(
            showScore ? '${level.label.toUpperCase()} · $score/25' : level.label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: fontSize,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

