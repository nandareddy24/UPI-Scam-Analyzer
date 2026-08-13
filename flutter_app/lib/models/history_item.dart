class HistoryItemModel {
  final String type;
  final String inputData;
  final int score;
  final String result;
  final String date;

  HistoryItemModel({
    required this.type,
    required this.inputData,
    required this.score,
    required this.result,
    required this.date,
  });

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      type: json['type'] ?? 'Unknown',
      inputData: json['data'] ?? json['input_data'] ?? '',
      score: json['score'] is int ? json['score'] : int.tryParse(json['score'].toString()) ?? 0,
      result: json['result'] ?? 'Unknown',
      date: json['date'] ?? json['created_at'] ?? '',
    );
  }
}
