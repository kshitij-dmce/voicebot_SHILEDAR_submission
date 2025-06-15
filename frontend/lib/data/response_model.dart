class ResponseModel {
  final String responseText;

  ResponseModel({required this.responseText});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(responseText: json['reply'] ?? "No response");
  }
}
