import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/response_parser.dart';

class ResponseController extends ChangeNotifier {
  String _response = "";
  bool _loading = false;

  String get response => _response;
  bool get loading => _loading;

  Future<void> fetchResponse(String queryText) async {
    _loading = true;
    notifyListeners();

    try {
      final raw = await ApiService.sendVoiceQuery(queryText);
      _response = ResponseParser.sanitize(raw as String);
    } catch (e) {
      _response = "Something went wrong: $e";
    }

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _response = "";
    _loading = false;
    notifyListeners();
  }
}
