import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  String _lastWords = '';
  bool _isAvailable = false;
  
  String get lastWords => _lastWords;
  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;
  
  Future<bool> initSpeech() async {
    _isAvailable = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );
    notifyListeners();
    return _isAvailable;
  }
  
  void startListening(Function(String) onResult) async {
    if (!_isAvailable) return;
    
    await _speechToText.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onResult(_lastWords);
        notifyListeners();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
    
    notifyListeners();
  }
  
  void stopListening() async {
    await _speechToText.stop();
    notifyListeners();
  }
  
  void _onSpeechStatus(String status) {
    debugPrint('Speech recognition status: $status');
    notifyListeners();
  }
  
  void _onSpeechError(dynamic error) {
    if (kDebugMode) {
      print('Speech recognition error: $error');
    }
    notifyListeners();
  }
}