class ReportModel {
  final int id;
  final String type;
  final String inputData;
  final String reason;
  final String status;
  final String createdAt;
  final String? proofData;

  ReportModel({
    required this.id,
    required this.type,
    required this.inputData,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.proofData,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] ?? '',
      inputData: json['input_data'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['created_at'] ?? '',
      proofData: json['proof_data'],
    );
  }
}
