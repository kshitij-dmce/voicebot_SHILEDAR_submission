// import 'package:flutter/foundation.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// class TTSService extends ChangeNotifier {
//   final FlutterTts _flutterTts = FlutterTts();
//   bool _isInitialized = false;
//   bool _isSpeaking = false;
//   double _pitch = 1.0;
//   double _rate = 0.5;
//   String _voice = 'en-US-language';
  
//   bool get isInitialized => _isInitialized;
//   bool get isSpeaking => _isSpeaking;
//   double get pitch => _pitch;
//   double get rate => _rate;
  
//   Future<void> initialize() async {
//     try {
//       await _flutterTts.setLanguage('en-US');
//       await _flutterTts.setPitch(_pitch);
//       await _flutterTts.setSpeechRate(_rate);
      
//       _flutterTts.setStartHandler(() {
//         _isSpeaking = true;
//         notifyListeners();
//       });
      
//       _flutterTts.setCompletionHandler(() {
//         _isSpeaking = false;
//         notifyListeners();
//       });
      
//       _flutterTts.setErrorHandler((message) {
//         _isSpeaking = false;
//         if (kDebugMode) {
//           print('TTS Error: $message');
//         }
//         notifyListeners();
//       });
      
//       _isInitialized = true;
//       notifyListeners();
//     } catch (e) {
//       if (kDebugMode) {
//         print('TTS initialization failed: $e');
//       }
//     }
//   }
  
//   Future<void> speak(String text) async {
//     if (!_isInitialized) await initialize();
    
//     if (text.isNotEmpty) {
//       await _flutterTts.speak(text);
//     }
//   }
  
//   Future<void> stop() async {
//     await _flutterTts.stop();
//     _isSpeaking = false;
//     notifyListeners();
//   }
  
//   Future<void> setPitch(double pitch) async {
//     _pitch = pitch;
//     await _flutterTts.setPitch(pitch);
//     notifyListeners();
//   }
//   // 
//   Future<void> setRate(double rate) async {
//     _rate = rate;
//     await _flutterTts.setSpeechRate(rate);
//     notifyListeners();
//   }
  
//   Future<void> setVoice(String voice) async {
//     _voice = voice;
//     // Implementation depends on platform support
//     notifyListeners();
//   }
  
//   @override
//   void dispose() {
//     _flutterTts.stop();
//     super.dispose();
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isEnabled = true;
  double _pitch = 1.0;
  double _rate = 0.5;
  String _voice = 'default';
  String _language = 'en-US';
  TtsState _ttsState = TtsState.stopped;
  List<String> _availableVoices = [];
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isEnabled => _isEnabled;
  double get pitch => _pitch;
  double get rate => _rate;
  String get voice => _voice;
  String get language => _language;
  TtsState get ttsState => _ttsState;
  List<String> get availableVoices => _availableVoices;

  TTSService() {
    initialize();
  }
  
  Future<void> initialize() async {
    try {
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_rate);
      
      // Set handlers for speech events
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _ttsState = TtsState.playing;
        notifyListeners();
      });
      
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _ttsState = TtsState.stopped;
        notifyListeners();
      });
      
      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _ttsState = TtsState.stopped;
        notifyListeners();
      });
      
      _flutterTts.setPauseHandler(() {
        _isSpeaking = false;
        _ttsState = TtsState.paused;
        notifyListeners();
      });
      
      _flutterTts.setContinueHandler(() {
        _isSpeaking = true;
        _ttsState = TtsState.continued;
        notifyListeners();
      });
      
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        _ttsState = TtsState.stopped;
        if (kDebugMode) {
          print('TTS Error: $message');
        }
        notifyListeners();
      });
      
      // Load available voices
      await _loadVoices();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('TTS initialization failed: $e');
      }
    }
  }
  
  Future<void> _loadVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null && voices is List) {
        // This is platform-specific - format depends on platform
        _availableVoices = voices
            .map((voice) => voice.toString())
            .toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load voices: $e');
      }
    }
  }
  
  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    if (!_isInitialized) await initialize();
    
    if (_isSpeaking) {
      await stop();
    }
    
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }
  
  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      _ttsState = TtsState.stopped;
      notifyListeners();
    }
  }
  
  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
      _ttsState = TtsState.paused;
      notifyListeners();
    }
  }
  
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (!enabled && _isSpeaking) {
      await stop();
    }
    notifyListeners();
  }
  
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
    notifyListeners();
  }
  
  Future<void> setRate(double rate) async {
    _rate = rate;
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }
  
  Future<void> setVoice(String voice) async {
    _voice = voice;
    
    // Implementation depends on platform
    try {
      switch (voice.toLowerCase()) {
        case 'male':
          // Set to a male voice if available
          await _setVoiceByGender('male');
          break;
        case 'female':
          // Set to a female voice if available
          await _setVoiceByGender('female');
          break;
        case 'premium':
          // Set to a premium voice if available (implementation varies)
          await _setVoiceByQuality('premium');
          break;
        case 'default':
        default:
          // Use system default
          break;
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set voice: $e');
      }
    }
  }
  
  Future<void> _setVoiceByGender(String gender) async {
    // This is an example implementation - adjust based on your TTS engine
    try {
      if (_availableVoices.isNotEmpty) {
        final voicesWithGender = _availableVoices.where((v) => 
          v.toLowerCase().contains(gender.toLowerCase())).toList();
        
        if (voicesWithGender.isNotEmpty) {
          await _flutterTts.setVoice({"name": voicesWithGender.first, "locale": _language});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting voice by gender: $e');
      }
    }
  }
  
  Future<void> _setVoiceByQuality(String quality) async {
    // This is an example implementation - adjust based on your TTS engine
    try {
      if (_availableVoices.isNotEmpty) {
        final premiumVoices = _availableVoices.where((v) => 
          v.toLowerCase().contains('enhanced') || 
          v.toLowerCase().contains('premium') ||
          v.toLowerCase().contains('neural')).toList();
        
        if (premiumVoices.isNotEmpty) {
          await _flutterTts.setVoice({"name": premiumVoices.first, "locale": _language});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting voice by quality: $e');
      }
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    _language = languageCode;
    try {
      await _flutterTts.setLanguage(languageCode);
      
      // After language change, reload available voices for this language
      await _loadVoices();
      
      // Reset voice to default for this language
      await setVoice('default');
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to set language: $e');
      }
    }
  }
  
  Future<bool> isLanguageAvailable(String languageCode) async {
    final available = await _flutterTts.isLanguageAvailable(languageCode);
    return available ?? false;
  }
  
  // Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get languages: $e');
      }
      return [];
    }
  }
  
  // Test current settings
  Future<void> speakTestMessage() async {
    switch (_language) {
      case 'hi-IN':
        await speak('नमस्ते, यह टेक्स्ट-टू-स्पीच का एक परीक्षण है।');
        break;
      case 'mr-IN':
        await speak('नमस्कार, ही टेक्स्ट-टू-स्पीच ची चाचणी आहे.');
        break;
      default:
        await speak('Hello, this is a test of text-to-speech functionality.');
    }
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}