import 'package:flutter/material.dart';

class AppConstants {
  // App information
  static const String appName = 'VoxGenie';
  static const String appVersion = '1.0.0';
  static const String appSlogan = 'Your Multilingual FAQ Assistant';
  
  // API endpoints
  static const String apiBaseUrl = 'https://api.voxgenie.com';
  static const String faqEndpoint = '/faq';
  static const String chatEndpoint = '/chat';
  static const String voiceEndpoint = '/voice';
  static const String feedbackEndpoint = '/feedback';
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('mr'), // Marathi
  ];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी (Hindi)',
    'mr': 'मराठी (Marathi)',
  };
  
  // FAQ categories
  static const List<Map<String, dynamic>> faqCategories = [
    {
      'id': 'banking',
      'name': 'Banking',
      'icon': Icons.account_balance,
      'color': Color(0xFF4E48E0),
    },
    {
      'id': 'insurance',
      'name': 'Insurance',
      'icon': Icons.security,
      'color': Color(0xFF00BCD4),
    },
    {
      'id': 'healthcare',
      'name': 'Healthcare',
      'icon': Icons.medical_services,
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'education',
      'name': 'Education',
      'icon': Icons.school,
      'color': Color(0xFFFFA726),
    },
    {
      'id': 'government',
      'name': 'Government',
      'icon': Icons.account_balance,
      'color': Color(0xFF7E57C2),
    },
    {
      'id': 'utilities',
      'name': 'Utilities',
      'icon': Icons.power,
      'color': Color(0xFFEF5350),
    },
    {
      'id': 'travel',
      'name': 'Travel',
      'icon': Icons.flight,
      'color': Color(0xFF26A69A),
    },
    {
      'id': 'telecom',
      'name': 'Telecom',
      'icon': Icons.phone_android,
      'color': Color(0xFF5C6BC0),
    },
    {
      'id': 'ecommerce',
      'name': 'E-commerce',
      'icon': Icons.shopping_cart,
      'color': Color(0xFFEC407A),
    },
    {
      'id': 'general',
      'name': 'General',
      'icon': Icons.info,
      'color': Color(0xFF78909C),
    },
  ];
  
  // Speech recognition settings
  static const int listeningTimeoutSeconds = 10;
  static const int maxResponseDisplayLines = 15;
  
  // Storage keys
  static const String languagePreferenceKey = 'language_preference';
  static const String darkModeKey = 'dark_mode';
  static const String userHistoryKey = 'user_history';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Assets paths
  static const String logoPath = 'assets/images/logo.png';
  static const String splashAnimation = 'assets/animations/splash.json';
  static const String voiceWavesAnimation = 'assets/animations/voice_waves.json';
  static const String emptyStateImage = 'assets/images/empty_state.png';
  static const String errorStateImage = 'assets/images/error_state.png';
  static const String successAnimation = 'assets/animations/success.json';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String soundWavesImage = 'assets/images/sound_waves.png';
  
  // Error messages
  static const String networkErrorMessage = 'Unable to connect. Please check your internet connection and try again.';
  static const String generalErrorMessage = 'Something went wrong. Please try again later.';
  static const String speechNotAvailableMessage = 'Speech recognition is not available on your device.';
  static const String emptyQueryMessage = 'Please speak something to search.';
}