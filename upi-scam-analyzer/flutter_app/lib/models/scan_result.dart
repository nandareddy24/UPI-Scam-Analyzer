import 'package:cloud_firestore/cloud_firestore.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'VERIFIED SAFE';
      case RiskLevel.medium:
        return 'SUSPICIOUS WARNING';
      case RiskLevel.high:
        return 'CRITICAL THREAT';
    }
  }
}

class ScanResult {
  final String? id; // Firestore document ID
  final String type; // 'message' | 'upi' | 'url' | 'ocr'
  final String input;
  final RiskLevel riskLevel;
  final int score; // 0-25
  final int confidence; // 85-99
  final String verdictTitle;
  final List<String> reasons;
  final String advice;
  final DateTime timestamp;

  ScanResult({
    this.id,
    required this.type,
    required this.input,
    required this.riskLevel,
    required this.score,
    required this.confidence,
    required this.verdictTitle,
    required this.reasons,
    required this.advice,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'input': input,
      'riskLevel': riskLevel.name,
      'score': score,
      'confidence': confidence,
      'verdictTitle': verdictTitle,
      'reasons': reasons,
      'advice': advice,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate = DateTime.now();
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      parsedDate = rawTs.toDate();
    } else if (rawTs is String) {
      parsedDate = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else if (rawTs is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawTs);
    }

    final rawReasons = map['reasons'];
    List<String> parsedReasons = const [];
    if (rawReasons is List) {
      parsedReasons = rawReasons.map((e) => e.toString()).toList();
    }

    final rawRisk = (map['riskLevel'] ?? '').toString().toLowerCase();
    final parsedRisk = RiskLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == rawRisk,
      orElse: () => RiskLevel.low,
    );

    return ScanResult(
      id: id,
      type: (map['type'] ?? 'message').toString(),
      input: (map['input'] ?? '').toString(),
      riskLevel: parsedRisk,
      score: (map['score'] as num?)?.toInt() ?? 0,
      confidence: (map['confidence'] as num?)?.toInt() ?? 95,
      verdictTitle: (map['verdictTitle'] ?? 'Scan Verdict').toString(),
      reasons: parsedReasons,
      advice: (map['advice'] ?? '').toString(),
      timestamp: parsedDate,
    );
  }
}
