import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart' as tts;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/speech_service.dart';
import '../widgets/voice_button.dart';
import '../widgets/animated_wave.dart';
import '../widgets/gradient_border_container.dart';
import '../core/theme/app_theme.dart';
import '../core/error_handler.dart';
import 'dart:convert';

class ConversationItem {
  final String query;
  final String response;
  final DateTime timestamp;
  bool? isLiked; // null = no feedback, true = liked, false = disliked

  ConversationItem({
    required this.query, 
    required this.response, 
    required this.timestamp,
    this.isLiked,
  });

  Map<String, dynamic> toJson() => {
    'query': query,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
    'isLiked': isLiked,
  };

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    return ConversationItem(
      query: json['query'],
      response: json['response'],
      timestamp: DateTime.parse(json['timestamp']),
      isLiked: json['isLiked'],
    );
  }
}

class PollyVoice {
  final String id;
  final String gender;
  final String accent;
  final String language;

  PollyVoice({
    required this.id,
    required this.gender,
    required this.accent,
    required this.language,
  });
}

enum OutputFormat { mp3, pcm, ogg_vorbis }
enum TextType { text, ssml }

class PollyResponse {
  final List<int>? audioStream;
  final String? requestId;
  final String? contentType;

  PollyResponse({this.audioStream, this.requestId, this.contentType});
}

// Mock AWS Polly implementation
class AwsPolly {
  final String accessKey;
  final String secretKey;
  final String region;

  AwsPolly({
    required this.accessKey,
    required this.secretKey,
    required this.region,
    String? poolId,
  });

  Future<PollyResponse> synthesizeSpeech({
    required String text,
    required String voiceId,
    required dynamic outputFormat,
    required dynamic textType,
  }) async {
    // This is a mock implementation that just returns dummy audio
    // In a real app, this would call the AWS Polly API
    return PollyResponse(
      audioStream: [1, 2, 3, 4, 5], // Dummy audio data
      requestId: '123456',
      contentType: 'audio/mpeg',
    );
  }
}

class ResultPage extends StatefulWidget {
  final String response;

  const ResultPage({super.key, required this.response});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late IO.Socket _socket;
  bool _isConnected = false;
  String _botReply = "";
  String _currentQuery = ""; // Track the current query
  bool _processingCurrentQuery = false; // Flag to track if we're processing the initial query
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _loading = false;
  bool _hasSpokenText = false;
  String _spokenText = "";
  bool _showVoiceWaveform = false;
  List<ConversationItem> _conversationHistory = [];
  bool _isSpeaking = false;
  final tts.FlutterTts _flutterTts = tts.FlutterTts(); // Main TTS engine
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  String _selectedVoice = 'Aditi'; // Default to Indian English voice

  // Animation controllers
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  late AnimationController _headerController;
  
  // List of Polly voices including Indian ones
  final List<PollyVoice> voices = [
    // Indian Voices
    PollyVoice(id: 'Aditi', gender: 'Female', accent: 'Indian', language: 'English/Hindi'),
    PollyVoice(id: 'Kajal', gender: 'Female', accent: 'Indian', language: 'Hindi'),
    PollyVoice(id: 'Raveena', gender: 'Female', accent: 'Indian', language: 'English'),
    
    // American Voices
    PollyVoice(id: 'Joanna', gender: 'Female', accent: 'American', language: 'English'),
    PollyVoice(id: 'Matthew', gender: 'Male', accent: 'American', language: 'English'),
    PollyVoice(id: 'Salli', gender: 'Female', accent: 'American', language: 'English'),
    PollyVoice(id: 'Joey', gender: 'Male', accent: 'American', language: 'English'),
    PollyVoice(id: 'Kimberly', gender: 'Female', accent: 'American', language: 'English'),
    
    // British Voices
    PollyVoice(id: 'Amy', gender: 'Female', accent: 'British', language: 'English'),
    PollyVoice(id: 'Emma', gender: 'Female', accent: 'British', language: 'English'),
    PollyVoice(id: 'Brian', gender: 'Male', accent: 'British', language: 'English'),
  ];

  @override
  void initState() {
    super.initState();
    // Set the current query from the widget
    _currentQuery = widget.response;
    _connectSocket();
    _initTts();
    _loadConversationHistory();
    _loadVoicePreference();

    // Initialize animation controllers
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Initialize speech service
    Future.delayed(const Duration(milliseconds: 300), () {
      _initSpeechService();
    });

    // Emit the initial message from previous screen
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isConnected) {
        _processingCurrentQuery = true; // Mark that we're processing the initial query
        _sendQuery(_currentQuery);
      }
    });
    
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
    
    _isInitialized = true;
  }
  
  Future<void> _loadVoicePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final voice = prefs.getString('tts_voice');
      if (voice != null) {
        setState(() {
          _selectedVoice = voice;
        });
      }
    } catch (e) {
      debugPrint('Error loading voice preference: $e');
    }
  }
  
  Future<void> _saveVoicePreference(String voice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tts_voice', voice);
    } catch (e) {
      debugPrint('Error saving voice preference: $e');
    }
  }

  Future<void> _initTts() async {
    // Configure Flutter TTS
    await _flutterTts.setLanguage("en-IN"); // Default to Indian English
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    try {
      final voices = await _flutterTts.getVoices;
      debugPrint("Available TTS voices: $voices");
      
      // Try to find a voice matching the selected voice ID
      // This only works if the device has voices with matching names
      if (voices != null && voices is List) {
        for (var voice in voices) {
          if (voice is Map && voice['name'].toString().contains(_selectedVoice)) {
            await _flutterTts.setVoice({"name": voice['name'], "locale": voice['locale']});
            debugPrint("Set voice to ${voice['name']}");
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Error setting voice: $e");
    }

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((message) {
      setState(() {
        _isSpeaking = false;
      });
      debugPrint("TTS Error: $message");
    });
  }
  
  Future<void> _speakText(String text) async {
    // Stop any current playback
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }
    
    if (text.isEmpty) return;
    
    try {
      setState(() {
        _isSpeaking = true;
      });
      
      // Clean text for better speech - add pauses at punctuation
      String enhancedText = text
          .replaceAll(". ", ". ... ")
          .replaceAll("? ", "? ... ")
          .replaceAll("! ", "! ... ")
          .replaceAll(", ", ", ... ");
          
      // Set language based on selected voice
      PollyVoice? selectedVoiceObj;
      for (var voice in voices) {
        if (voice.id == _selectedVoice) {
          selectedVoiceObj = voice;
          break;
        }
      }
      
      if (selectedVoiceObj != null) {
        if (selectedVoiceObj.language.contains('Hindi')) {
          await _flutterTts.setLanguage("hi-IN");
        } else if (selectedVoiceObj.accent == 'Indian') {
          await _flutterTts.setLanguage("en-IN");
        } else if (selectedVoiceObj.accent == 'British') {
          await _flutterTts.setLanguage("en-GB");
        } else {
          await _flutterTts.setLanguage("en-US");
        }
      }
      
      // Configure voice characteristics based on gender
      if (selectedVoiceObj?.gender == 'Female') {
        await _flutterTts.setPitch(1.1);  // Slightly higher pitch for female voices
      } else {
        await _flutterTts.setPitch(0.9);  // Slightly lower pitch for male voices
      }
      
      // Set speech rate slightly slower for Indian accents for clarity
      if (selectedVoiceObj?.accent == 'Indian') {
        await _flutterTts.setSpeechRate(0.45);
      } else {
        await _flutterTts.setSpeechRate(0.5);
      }
      
      // Display speaking indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16.w),
              Text('Speaking with $_selectedVoice...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
        ),
      );
      
      // Speak the text
      await _flutterTts.speak(enhancedText);
      
      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint("Error with TTS: $e");
      setState(() {
        _isSpeaking = false;
      });
      
      // Show error notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to speak text'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
        ),
      );
    }
  }

  void _showVoiceSelectionBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E3A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Select Voice',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ),
            
            // Voice categories tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.black.withOpacity(0.2) 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Row(
                    children: [
                      _buildVoiceCategoryTab('Indian', isDark),
                      _buildVoiceCategoryTab('American', isDark),
                      _buildVoiceCategoryTab('British', isDark),
                    ],
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: voices.length,
                itemBuilder: (context, index) {
                  final voice = voices[index];
                  final isSelected = _selectedVoice == voice.id;
                  
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    tileColor: isSelected
                        ? (isDark
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.primaryColor.withOpacity(0.1))
                        : Colors.transparent,
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1)),
                      child: Icon(
                        voice.gender == 'Female' ? Icons.woman : Icons.man,
                        color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                    title: Text(
                      voice.id,
                      style: GoogleFonts.poppins(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      '${voice.gender} • ${voice.accent} • ${voice.language}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                    onTap: () async {
                      setState(() {
                        _selectedVoice = voice.id;
                      });
                      await _saveVoicePreference(_selectedVoice);
                      
                      // Play a sample to demonstrate the voice
                      String sampleText;
                      
                      if (voice.language.contains('Hindi')) {
                        sampleText = "नमस्ते, मैं ${voice.id} हूं। मैं आपका वॉक्सजीनी सहायक बनूंगा।";
                      } else {
                        sampleText = "Hello, I'm ${voice.id}. I'll be your VoxGenie assistant.";
                      }
                      
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                      
                      _speakText(sampleText);
                    },
                  );
                },
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16.r),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVoiceCategoryTab(String category, bool isDark) {
    bool isSelected = false;
    
    // Check if selected voice is in this category
    for (var voice in voices) {
      if (voice.id == _selectedVoice && voice.accent == category) {
        isSelected = true;
        break;
      }
    }
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Filter voice list by category
          _showVoicesByCategory(category);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.primaryColor.withOpacity(0.5) : AppTheme.primaryColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showVoicesByCategory(String category) {
    // This would filter voices by category in a full implementation
    // For now, we're just showing all voices
    setState(() {
      // Could filter voices here if desired
    });
  }

  Future<void> _loadConversationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getString('conversation_history');
      
      if (history != null) {
        final List<dynamic> decoded = jsonDecode(history);
        setState(() {
          _conversationHistory = decoded
              .map((item) => ConversationItem.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading conversation history: $e');
    }
  }

  Future<void> _saveConversationHistory() async {
    try {
      // Keep only the last 20 conversations to prevent storage issues
      final conversationsToSave = _conversationHistory.length > 20 
          ? _conversationHistory.sublist(_conversationHistory.length - 20) 
          : _conversationHistory;
          
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'conversation_history',
        jsonEncode(conversationsToSave.map((c) => c.toJson()).toList())
      );
    } catch (e) {
      debugPrint('Error saving conversation history: $e');
    }
  }

  Future<void> _initSpeechService() async {
    bool available = await _speechService.initSpeech();
    if (!available && mounted) {
      ErrorHandler.showSnackbar(
        context,
        "Speech recognition isn't available on this device.",
        icon: Icons.mic_off_rounded,
      );
    }
  }

  void _connectSocket() {
    _socket = IO.io(
      'http://192.168.7.36:7000', // Change to your server's IP
      IO.OptionBuilder()
          .setTransports(['websocket']) // Flutter requires websocket
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('✅ Socket connected');
      setState(() {
        _isConnected = true;
      });
    });

    _socket.onDisconnect((_) {
      debugPrint('❌ Socket disconnected');
      setState(() {
        _isConnected = false;
      });
    });

    _socket.on('bot_response', (data) {
      debugPrint("📥 Bot responded: $data");

      if (data is Map && data.containsKey('response')) {
        setState(() {
          _botReply = data['response'];
          _loading = false;
          
          // Only add to conversation history if we're processing a new query
          // and not the initial query that was already added
          if (_processingCurrentQuery) {
            // Add to conversation history with the current query
            _conversationHistory.add(
              ConversationItem(
                query: _currentQuery,
                response: _botReply,
                timestamp: DateTime.now(),
              )
            );
            
            _processingCurrentQuery = false; // Reset the flag
            
            // Save updated history
            _saveConversationHistory();
          }
        });
      } else {
        debugPrint("⚠️ Unexpected socket response: $data");
        setState(() {
          _loading = false;
        });
      }
    });

    _socket.onConnectError((data) => debugPrint("❌ Connect Error: $data"));
    _socket.onError((data) => debugPrint("❌ Error: $data"));
  }

  void _sendQuery(String query) {
    if (_isConnected) {
      debugPrint("📤 Sending query: $query");
      _socket.emit('user_query', {'query': query});
      setState(() {
        _loading = true;
        _currentQuery = query; // Update the current query
      });
    } else {
      debugPrint("⚠️ Cannot send, socket not connected.");
      if (mounted) {
        ErrorHandler.showSnackbar(
          context,
          "Not connected to server. Please try again.",
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  void _provideFeedback(int index, bool liked) {
    setState(() {
      _feedbackController.forward(from: 0.0);
      _conversationHistory[index].isLiked = liked;
      // Save updated history with feedback
      _saveConversationHistory();
    });
    
    // Here you could also send feedback to your server
    if (_isConnected) {
      _socket.emit('feedback', {
        'query': _conversationHistory[index].query,
        'response': _conversationHistory[index].response,
        'liked': liked,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }

    // Show confirmation
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(liked ? 'Thank you for your feedback!' : 'We\'ll improve our responses.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
      ),
    );
  }

  void _handleSpeech() async {
    if (_isListening) {
      _stopListening();
      return;
    }

    setState(() => _loading = true);
    bool available = await _speechService.initSpeech();
    setState(() => _loading = false);

    if (!available) {
      ErrorHandler.showSnackbar(
        context,
        "Speech recognition isn't available on this device.",
        icon: Icons.mic_off_rounded,
      );
      return;
    }

    // Start listening animation
    _startListening();

    _speechService.startListening((text) {
      setState(() {
        _spokenText = text;
        _hasSpokenText = text.isNotEmpty;
        if (_hasSpokenText) {
          _fadeController.forward();
          _showVoiceWaveform = true;
        }
      });
    });
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _spokenText = "";
      _hasSpokenText = false;
      _showVoiceWaveform = true;
    });
    _fadeController.reset();
    _waveController.repeat();

    // Add haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _stopListening() async {
    _speechService.stopListening();
    _waveController.stop();

    setState(() {
      _isListening = false;
      _showVoiceWaveform = false;
    });
    if (_spokenText.isNotEmpty) {
      _processingCurrentQuery = true; // Mark that we're processing a new query
      _sendQuery(_spokenText);
      setState(() {
        _spokenText = "";
        _hasSpokenText = false;
      });
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _feedbackController.dispose();
    _headerController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor: isDark 
                ? Colors.black.withOpacity(0.2) 
                : Colors.white.withOpacity(0.2),
              elevation: 0,
              flexibleSpace: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 60.h),
                  // Header section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.accentColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.assistant_rounded,
                            color: Colors.white,
                            size: 24.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "VoxGenie Assistant",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                "Voice: $_selectedVoice",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Voice selection button
                        IconButton(
                          icon: Icon(
                            Icons.record_voice_over_rounded,
                            size: 22.w,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          tooltip: "Select voice",
                          onPressed: _showVoiceSelectionBottomSheet,
                        ),
                        // History clear button
                        if (_conversationHistory.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 22.w,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            tooltip: "Clear conversation history",
                            onPressed: () {
                              _showClearHistoryDialog();
                            },
                          ),
                      ],
                    )
                    .animate(controller: _headerController)
                    .fadeIn(duration: const Duration(milliseconds: 400))
                    .slideY(begin: -0.1, end: 0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutQuad),
                  ),
                ],
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 24.w,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? [
                  const Color(0xFF121212),
                  const Color(0xFF1E1E3A),
                  const Color(0xFF262650),
                ]
              : [
                  const Color(0xFFF0F4FF),
                  const Color(0xFFE6EDFF),
                  const Color(0xFFD8E5FF),
                ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content area - shows either conversation history, bot response, or voice UI
              Expanded(
                child: _isListening || _showVoiceWaveform
                    ? _buildVoiceWaveformWidget(isDark)
                    : _hasSpokenText
                    ? _buildSpokenTextWidget(isDark)
                    : _loading
                    ? _buildLoadingIndicator(isDark)
                    : _buildConversationWidget(isDark),
              ),
    
              // Voice control button at the bottom
              _buildVoiceControlSection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationWidget(bool isDark) {
    // If no history or current response, show waiting message
    if (_conversationHistory.isEmpty && _botReply.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 60.w,
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              "Waiting for response...",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Your conversation will appear here",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }
    
    // Build the list with conversation history plus current response if it exists
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Build all past conversation items
        ..._conversationHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final conversation = entry.value;
          return _buildConversationItem(conversation, index, isDark);
        }).toList(),
        
        // Add the current query and response if we have one that's not saved yet
        if (_botReply.isNotEmpty && _processingCurrentQuery)
          _buildCurrentConversationItem(isDark),
      ],
    );
  }

  Widget _buildCurrentConversationItem(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header if needed
          if (_conversationHistory.isEmpty || 
              !_isSameDay(DateTime.now(), 
                        _conversationHistory.last.timestamp))
            Padding(
              padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Today',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          
          // User query
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        _currentQuery, // Use the tracked current query
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    // Time stamp
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        _formatTime(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Bot response
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assistant_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "VoxGenie • $_selectedVoice",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black12
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _botReply,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Time stamp
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        _formatTime(DateTime.now()),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                    
                    // Feedback and TTS buttons
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 4.w),
                      child: Row(
                        children: [
                          // TTS Button
                          _buildActionButton(
                            icon: _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                            color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                            tooltip: _isSpeaking ? "Stop speaking" : "Read aloud",
                            onPressed: () => _speakText(_botReply),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Copy Button
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: "Copy to clipboard",
                            onPressed: () => _copyToClipboard(_botReply),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Thumbs up
                          _buildActionButton(
                            icon: Icons.thumb_up_outlined,
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: "Helpful response",
                            onPressed: () {
                              setState(() {
                                // Create a conversation item for the current query/response
                                ConversationItem newItem = ConversationItem(
                                  query: _currentQuery,
                                  response: _botReply,
                                  timestamp: DateTime.now(),
                                  isLiked: true, // Set to liked
                                );
                                
                                // Add to history
                                _conversationHistory.add(newItem);
                                
                                // Reset current state
                                _botReply = "";
                                _processingCurrentQuery = false;
                                
                                // Save updated history
                                _saveConversationHistory();
                                
                                // Show feedback
                                _feedbackController.forward(from: 0.0);
                              });
                              
                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Thank you for your feedback!'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 16.w),
                          
                          // Thumbs down
                          _buildActionButton(
                            icon: Icons.thumb_down_outlined,
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: "Not helpful",
                            onPressed: () {
                              setState(() {
                                // Create a conversation item for the current query/response
                                ConversationItem newItem = ConversationItem(
                                  query: _currentQuery,
                                  response: _botReply,
                                  timestamp: DateTime.now(),
                                  isLiked: false, // Set to disliked
                                );
                                
                                // Add to history
                                _conversationHistory.add(newItem);
                                
                                // Reset current state
                                _botReply = "";
                                _processingCurrentQuery = false;
                                
                                // Save updated history
                                _saveConversationHistory();
                                
                                // Show feedback
                                _feedbackController.forward(from: 0.0);
                              });
                              
                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('We\'ll improve our responses.'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                      .animate(controller: _feedbackController)
                      .scale(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 20.w,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // Show confirmation
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Response copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
      ),
    );
  }

  Widget _buildConversationItem(ConversationItem conversation, int index, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header if needed
          if (index == 0 || 
              !_isSameDay(_conversationHistory[index].timestamp, 
                        _conversationHistory[index - 1].timestamp))
            Padding(
              padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    _formatDate(conversation.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
            
          // User query
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "You",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        conversation.query,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    // Time stamp
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        _formatTime(conversation.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Bot response
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assistant_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "VoxGenie • $_selectedVoice",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black12
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        conversation.response,
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          height: 1.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    
                    // Time stamp
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 4.w),
                      child: Text(
                        _formatTime(conversation.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ),
                    
                    // Feedback and TTS buttons
                    Padding(
                      padding: EdgeInsets.only(top: 8.h, left: 4.w),
                      child: Row(
                        children: [
                          // TTS Button
                          _buildActionButton(
                            icon: _isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                            color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
                            tooltip: _isSpeaking ? "Stop speaking" : "Read aloud",
                            onPressed: () => _speakText(conversation.response),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Copy Button
                          _buildActionButton(
                            icon: Icons.copy_rounded,
                            color: isDark ? Colors.white70 : Colors.black54,
                            tooltip: "Copy to clipboard",
                            onPressed: () => _copyToClipboard(conversation.response),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Thumbs up
                          _buildActionButton(
                            icon: conversation.isLiked == true
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            color: conversation.isLiked == true
                                ? AppTheme.accentColor
                                : (isDark ? Colors.white70 : Colors.black54),
                            tooltip: "Helpful response",
                            onPressed: () => _provideFeedback(index, true),
                          ),
                          SizedBox(width: 16.w),
                          
                          // Thumbs down
                          _buildActionButton(
                            icon: conversation.isLiked == false
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            color: conversation.isLiked == false
                                ? Colors.redAccent
                                : (isDark ? Colors.white70 : Colors.black54),
                            tooltip: "Not helpful",
                            onPressed: () => _provideFeedback(index, false),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceWaveformWidget(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Voice visualization
        SizedBox(height: 20.h),
        AnimatedWave(
          isListening: _isListening,
          color: isDark ? AppTheme.accentColor : AppTheme.primaryColor,
          height: 120.h,
          amplitude: 30.h,
          duration: const Duration(seconds: 2),
        ),
        SizedBox(height: 30.h),

        // Listening indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor,
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.5, 1.5),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                ),
            SizedBox(width: 10.w),
            Text(
              "I'm listening...",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),

        // Text that has been recognized so far
        if (_spokenText.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: GradientBorderContainer(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 24.w,
                  ),
                  borderRadius: 20.r,
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [
                              AppTheme.primaryColor.withOpacity(0.3),
                              AppTheme.accentColor.withOpacity(0.3),
                            ]
                            : [
                              AppTheme.primaryColor.withOpacity(0.2),
                              AppTheme.accentColor.withOpacity(0.2),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  backgroundColor:
                      isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.6),
                  child: Text(
                    _spokenText,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                .animate(controller: _fadeController)
                .fade(duration: const Duration(milliseconds: 300)),
          ),
      ],
    );
  }

  Widget _buildSpokenTextWidget(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: GradientBorderContainer(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          borderRadius: 24.r,
          borderWidth: 2,
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.7),
              AppTheme.accentColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          backgroundColor:
              isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? Colors.black12
                      : AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your request:',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _spokenText,
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _spokenText = "";
                        _hasSpokenText = false;
                      });
                
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      side: BorderSide(
                        color:
                            isDark
                                ? Colors.white60
                                : AppTheme.primaryColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.w,
                      color: isDark ? Colors.white70 : AppTheme.primaryColor,
                    ),
                    label: Text(
                      'Try again',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ElevatedButton.icon(
                    onPressed: _stopListening,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(Icons.send, size: 20.w),
                    label: Text(
                      'Send',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fade(duration: const Duration(milliseconds: 300)),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50.w,
            height: 50.w,
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 4.w,
              backgroundColor: isDark 
                ? Colors.white.withOpacity(0.1) 
                : AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Processing your request...',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark 
                ? Colors.white.withOpacity(0.05) 
                : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  
                    
                  'My assistant is thinking...',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            )
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .fadeIn(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControlSection(bool isDark) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h, top: 20.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Voice button - exactly like in HomePage
          VoiceButton(
            onTap: _loading && !_isListening ? null : _handleSpeech,
            isListening: _isListening,
            size: 80.w,
          ),
          SizedBox(height: 16.h),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                _loading && !_isListening
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryColor,
                            backgroundColor:
                                isDark
                                    ? Colors.white24
                                    : AppTheme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Processing...',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _isListening
                                    ? AppTheme.accentColor
                                    : isDark
                                    ? Colors.white38
                                    : Colors.black38,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isListening
                              ? "I'm listening to you..."
                              : 'Tap mic to speak',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Clear Conversation History?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppTheme.primaryColor,
          ),
        ),
        content: Text(
          'This will delete all your conversation history. This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear conversation history
              setState(() {
                _conversationHistory.clear();
              });
              
              // Clear from storage
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('conversation_history');
              
              // Close dialog
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Conversation history cleared'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 80.h, left: 20.w, right: 20.w),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for date formatting
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

extension on AwsPolly {
  synthesizeSpeech({required String text, required String voiceId, required outputFormat, required textType}) {}
}