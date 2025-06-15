import 'package:flutter/material.dart';
import '../core/speech_service.dart';

class VoiceController extends ChangeNotifier {
  final SpeechService _speechService = SpeechService();

  bool _isListening = false;
  String _spokenText = "";

  bool get isListening => _isListening;
  String get spokenText => _spokenText;

  Future<void> startListening() async {
    final available = await _speechService.initSpeech();
    if (!available) return;

    _isListening = true;
    notifyListeners();

    _speechService.startListening((text) {
      _spokenText = text;
      notifyListeners();
    });
  }

  void stopListening() {
    _speechService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  void reset() {
    _spokenText = "";
    _isListening = false;
    notifyListeners();
  }
}
