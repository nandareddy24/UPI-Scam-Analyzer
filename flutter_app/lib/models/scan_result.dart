class ScanResult {
  final String id;
  final String type; // UPI, URL, SMS, QR, PHONE, IMAGE
  final String inputData;
  final int rawScore;
  final int displayScore; // 0 - 100
  final String result; // Safe, Warning, Dangerous
  final String reason;
  final int confidence;
  final String advice;
  final Map<String, dynamic>? qrPayload;
  final Map<String, dynamic>? virustotal;
  final Map<String, dynamic>? safebrowsing;
  final DateTime timestamp;

  ScanResult({
    required this.id,
    required this.type,
    required this.inputData,
    required this.rawScore,
    required this.displayScore,
    required this.result,
    required this.reason,
    required this.confidence,
    required this.advice,
    this.qrPayload,
    this.virustotal,
    this.safebrowsing,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  static int calculateDisplayScore(int rawScore, String result) {
    if (result.toLowerCase() == 'dangerous') {
      return (rawScore * 10).clamp(75, 100);
    } else if (result.toLowerCase() == 'warning') {
      return (rawScore * 8).clamp(45, 70);
    } else {
      return (rawScore * 5).clamp(5, 35);
    }
  }

  factory ScanResult.fromJson(Map<String, dynamic> json, {String defaultType = 'UPI', String defaultInput = ''}) {
    final rawScoreVal = json['score'] is int
        ? json['score']
        : int.tryParse(json['score']?.toString() ?? '0') ?? 0;
    
    final resultVal = json['result'] ?? json['classification'] ?? 'Safe';
    final calcScore = calculateDisplayScore(rawScoreVal, resultVal.toString());

    final rawReason = json['reason'] ?? json['explanation'] ?? json['message'] ?? '';
    final reasonStr = rawReason.toString().isEmpty ? 'No suspicious anomalies detected.' : rawReason.toString();

    return ScanResult(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? defaultType,
      inputData: json['input_data'] ?? json['data'] ?? json['upi'] ?? json['url'] ?? json['sms'] ?? json['phone'] ?? defaultInput,
      rawScore: rawScoreVal,
      displayScore: json['display_score'] is int ? json['display_score'] : calcScore,
      result: resultVal.toString(),
      reason: reasonStr,
      confidence: json['confidence'] is int
          ? json['confidence']
          : int.tryParse(json['confidence']?.toString() ?? '90') ?? 90,
      advice: json['advice'] ?? 'Always verify recipient identity before finalizing transactions.',
      qrPayload: json['qr_payload'] is Map<String, dynamic> ? json['qr_payload'] : null,
      virustotal: json['virustotal'] is Map<String, dynamic> ? json['virustotal'] : null,
      safebrowsing: json['safebrowsing'] is Map<String, dynamic> ? json['safebrowsing'] : null,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'input_data': inputData,
      'score': rawScore,
      'display_score': displayScore,
      'result': result,
      'reason': reason,
      'confidence': confidence,
      'advice': advice,
      'qr_payload': qrPayload,
      'virustotal': virustotal,
      'safebrowsing': safebrowsing,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  List<String> get reasonList {
    if (reason.isEmpty) return [];
    if (reason.contains(' | ')) {
      return reason.split(' | ').where((s) => s.trim().isNotEmpty).toList();
    }
    if (reason.contains(', ')) {
      return reason.split(', ').where((s) => s.trim().isNotEmpty).toList();
    }
    return [reason];
  }
}

typedef ScanResultModel = ScanResult;
