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
  final String? id; // Firestore or Local document ID
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

  ScanResult copyWith({
    String? id,
    String? type,
    String? input,
    RiskLevel? riskLevel,
    int? score,
    int? confidence,
    String? verdictTitle,
    List<String>? reasons,
    String? advice,
    DateTime? timestamp,
  }) {
    return ScanResult(
      id: id ?? this.id,
      type: type ?? this.type,
      input: input ?? this.input,
      riskLevel: riskLevel ?? this.riskLevel,
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      verdictTitle: verdictTitle ?? this.verdictTitle,
      reasons: reasons ?? this.reasons,
      advice: advice ?? this.advice,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
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

    final rawRisk = (map['riskLevel'] ?? map['status'] ?? '').toString().toLowerCase();
    RiskLevel parsedRisk = RiskLevel.low;
    if (rawRisk.contains('high') || rawRisk.contains('critical') || rawRisk.contains('danger')) {
      parsedRisk = RiskLevel.high;
    } else if (rawRisk.contains('medium') || rawRisk.contains('warn') || rawRisk.contains('suspicious')) {
      parsedRisk = RiskLevel.medium;
    }

    final docId = id ?? (map['id']?.toString());

    return ScanResult(
      id: docId,
      type: (map['type'] ?? 'message').toString(),
      input: (map['input'] ?? '').toString(),
      riskLevel: parsedRisk,
      score: (map['score'] as num?)?.toInt() ?? 0,
      confidence: (map['confidence'] as num?)?.toInt() ?? 95,
      verdictTitle: (map['verdictTitle'] ?? map['result'] ?? 'Scan Verdict').toString(),
      reasons: parsedReasons,
      advice: (map['advice'] ?? '').toString(),
      timestamp: parsedDate,
    );
  }
}
