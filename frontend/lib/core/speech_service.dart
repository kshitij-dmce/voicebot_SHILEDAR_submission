import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/constants/app_constants.dart';

class SpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  Locale? _currentLocale;
  Timer? _listenTimeout;
  
  // Initialize the speech recognition service
  Future<bool> initSpeech() async {
    if (_isInitialized) {
      return true;
    }
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => debugPrint('Speech recognition error: $error'),
        onStatus: (status) => debugPrint('Speech recognition status: $status'),
        debugLogging: false,
      );
      
      return _isInitialized;
    } catch (e) {
      debugPrint('Failed to initialize speech recognition: $e');
      _isInitialized = false;
      return false;
    }
  }
  
  // Start listening for speech
  void startListening(Function(String) onResult, {Locale? locale}) async {
    if (!_isInitialized) {
      bool available = await initSpeech();
      if (!available) {
        return;
      }
    }
    
    // Stop any previous listening session
    if (_speech.isListening) {
      stopListening();
    }
    
    // Set the locale for speech recognition
    _currentLocale = locale;
    
    try {
      // Start listening with timeout
      await _speech.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            onResult(recognizedWords);
          }
        },
        localeId: _currentLocale?.languageCode,
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
      
      // Set a timeout for listening
      _listenTimeout = Timer(
        const Duration(seconds: AppConstants.listeningTimeoutSeconds),
        () => stopListening(),
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      stopListening();
    }
  }
  
  // Stop listening for speech
  void stopListening() {
    _listenTimeout?.cancel();
    if (_speech.isListening) {
      _speech.stop();
    }
  }
  
  // Get a list of available locales for speech recognition
  Future<List<Locale>> getAvailableLocales() async {
    if (!_isInitialized) {
      bool available = await initSpeech();
      if (!available) {
        return [];
      }
    }
    
    try {
      final availableLocales = await _speech.locales();
      return availableLocales
          .map((loc) => Locale(loc.localeId.split('_')[0], ''))
          .where((locale) => 
              AppConstants.supportedLocales.contains(locale))
          .toList();
    } catch (e) {
      debugPrint('Error getting available locales: $e');
      return [];
    }
  }
  
  // Check if the speech recognition service is listening
  bool get isListening => _speech.isListening;
  
  // Check if the speech recognition service is available
  bool get isAvailable => _isInitialized;
}