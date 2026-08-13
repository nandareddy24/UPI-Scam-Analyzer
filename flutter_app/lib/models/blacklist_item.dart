class BlacklistItemModel {
  final int id;
  final String data;
  final String type;
  final String reason;

  BlacklistItemModel({
    required this.id,
    required this.data,
    required this.type,
    required this.reason,
  });

  factory BlacklistItemModel.fromJson(Map<String, dynamic> json) {
    return BlacklistItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      data: json['data'] ?? '',
      type: json['type'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}
