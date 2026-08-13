class ScanResultModel {
  final String status;
  final String result;
  final int score;
  final String reason;
  final String? inputData;
  final String? classification;
  final String? recommendation;
  final String? extractedText;
  final List<String>? upiDetected;
  final List<String>? urlDetected;
  final String? qrData;

  ScanResultModel({
    required this.status,
    required this.result,
    required this.score,
    required this.reason,
    this.inputData,
    this.classification,
    this.recommendation,
    this.extractedText,
    this.upiDetected,
    this.urlDetected,
    this.qrData,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      status: json['status'] ?? 'success',
      result: json['result'] ?? json['classification'] ?? 'Unknown',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 0,
      reason: json['reason'] ?? json['analysis'] ?? json['explanation'] ?? '',
      inputData: json['input_data'] ?? json['upi_id'] ?? json['phone'] ?? json['url'],
      classification: json['classification'],
      recommendation: json['recommendation'],
      extractedText: json['extracted_text'],
      upiDetected: json['upi_detected'] != null ? List<String>.from(json['upi_detected']) : null,
      urlDetected: json['url_detected'] != null ? List<String>.from(json['url_detected']) : null,
      qrData: json['qr_data'],
    );
  }
}
