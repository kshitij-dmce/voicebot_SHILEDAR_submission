

import 'dart:ui';
import 'analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:simple_animations/simple_animations.dart';

import '../widgets/voice_button.dart';
import '../widgets/animated_wave.dart';
import '../widgets/gradient_border_container.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/suggestion_chip.dart';
import '../widgets/particle_background.dart';
import '../core/speech_service.dart';
import '../services/api_service.dart';
import '../core/error_handler.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'result_page.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  String _spokenText = "";
  bool _loading = false;
  bool _isListening = false;
  bool _hasSpokenText = false;
  bool _showVoiceWaveform = false;
  String _currentLanguage = 'English';

  // Suggested queries
  final List<String> _suggestedQueries = [
    'How do I reset my password?',
    'Tell me about insurance plans',
    'What are the current interest rates?',
    'How to apply for a loan?',
  ];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _floatingController;
  late AnimationController _logoController;
  late PageController _pageController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.85);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Initialize with a small delay to ensure smooth entry animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _initSpeechService();
    });
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

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _rotationController.dispose();
    _floatingController.dispose();
    _logoController.dispose();
    _pageController.dispose();
    super.dispose();
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

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // If we have recognized text, navigate to ResultPage
    if (_spokenText.isNotEmpty) {
      // Navigate directly to ResultPage with the recognized query
      if (context.mounted) {
        // Navigate to ResultPage passing the spoken text
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              ResultPage(response: _spokenText),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.03);
              const end = Offset.zero;
              const curve = Curves.easeOutQuint;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              var fadeAnimation = CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
              );

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: fadeAnimation, child: child),
              );
            },
          ),
        );
      }
    }
  }

  void _handleSuggestionTap(String query) {
    setState(() {
      _spokenText = query;
      _hasSpokenText = true;
    });
    _fadeController.forward();

    // Navigate directly to ResultPage with the suggested query
    if (context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            ResultPage(response: query),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.03);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      );
    }
  }

  void _changeLanguage(String language) {
    setState(() {
      _currentLanguage = language;
    });

    // Show language change feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language changed to $language'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentColor,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.only(bottom: 70.h, left: 20.w, right: 20.w),
      ),
    );

    // Here you would implement actual language change in a real app
    // _speechService.setLanguage(language.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AppBar(
              backgroundColor:
                  isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
              elevation: 0,
              centerTitle: true,
              title: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_icon.png',
                            height: 28.h,
                            width: 28.h,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.mic,
                                size: 24.h,
                                color:
                                    isDark
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                              );
                            },
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'VoxGenie',
                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : AppTheme.primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              leading: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: CircleAvatar(
                  backgroundColor:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                  child: IconButton(
                    icon: Icon(
                      Icons.language,
                      color: isDark ? Colors.white70 : AppTheme.primaryColor,
                      size: 20.sp,
                    ),
                    onPressed: () => _showLanguageBottomSheet(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: CircleAvatar(
                    backgroundColor:
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                    child: IconButton(
                      icon: Icon(
                        Icons.bar_chart_rounded,
                        color: isDark ? Colors.white70 : AppTheme.primaryColor,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16.w),
                  child: CircleAvatar(
                    backgroundColor:
                        isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark ? Colors.white70 : AppTheme.primaryColor,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with particles and gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDark
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
            child: ParticleBackground(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.05)
                      : AppTheme.primaryColor.withOpacity(0.05),
            ),
          ),

          // Decorative elements
          Positioned(
            top: -100.h,
            right: -80.w,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          isDark
                              ? AppTheme.accentColor.withOpacity(0.3)
                              : AppTheme.primaryColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -120.h,
            left: -100.w,
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_rotationController.value * 2 * 3.14159,
                  child: Container(
                    width: 250.w,
                    height: 250.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          isDark
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : AppTheme.accentColor.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Welcome text animation
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: DefaultTextStyle(
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(
                          'How can I assist you today?',
                          speed: const Duration(milliseconds: 80),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                    ),
                  ),
                ),

                // Suggestion chips
                SizedBox(height: 24.h),
                _buildSuggestionChips(),
                SizedBox(height: 24.h),

                // Voice visualization or spoken text
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child:
                          _loading
                              ? _buildLoadingIndicator(isDark)
                              : _buildMainContent(isDark),
                    ),
                  ),
                ),

                // Bottom voice control section
                _buildVoiceControlSection(isDark),
              ],
            ),
          ),

          // Help button
          Positioned(
            bottom: 70.h,
            right: 24.w,
            child: FloatingActionButton(
                  heroTag: 'helpButton',
                  onPressed: () => _showHelpBottomSheet(),
                  backgroundColor:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.9),
                  elevation: 4,
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: isDark ? Colors.white : Colors.white,
                    size: 26.sp,
                  ),
                )
                .animate(
                  controller: _floatingController,
                  onInit: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    return SizedBox(
      height: 42.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _suggestedQueries.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: SuggestionChip(
                  label: _suggestedQueries[index],
                  onTap: () => _handleSuggestionTap(_suggestedQueries[index]),
                  color:
                      index % 2 == 0
                          ? AppTheme.primaryColor
                          : AppTheme.accentColor,
                )
                .animate(onInit: (controller) => controller.forward())
                .slideX(
                  begin: 1.0,
                  end: 0.0,
                  delay: Duration(milliseconds: 100 + (index * 100)),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutQuint,
                )
                .fadeIn(
                  delay: Duration(milliseconds: 100 + (index * 100)),
                  duration: const Duration(milliseconds: 400),
                ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    if (_isListening || _showVoiceWaveform) {
      return _buildVoiceWaveformWidget(isDark);
    } else if (_hasSpokenText) {
      return _buildSpokenTextWidget(isDark);
    } else {
      return _buildWelcomeCardsWidget(isDark);
    }
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
            padding: EdgeInsets.only(top: 30.h),
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
      child: GradientBorderContainer(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
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
                    size: 20.sp,
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
                  onPressed: () {
                    // Navigate to ResultPage with the current spoken text
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                          ResultPage(response: _spokenText),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 0.03);
                          const end = Offset.zero;
                          const curve = Curves.easeOutQuint;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          var fadeAnimation = CurvedAnimation(
                            parent: animation,
                            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
                          );

                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(opacity: fadeAnimation, child: child),
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.send_rounded, size: 20.sp),
                  label: Text(
                    'Submit',
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
    );
  }

  Widget _buildWelcomeCardsWidget(bool isDark) {
    // Feature cards
    final List<Map<String, dynamic>> features = [
      {
        'title': 'Multi-language Support',
        'description':
            'Speak in English, Hindi, or Marathi - I understand them all!',
        'icon': Icons.translate_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Banking Assistant',
        'description':
            'Ask about accounts, loans, credit cards, and more banking services.',
        'icon': Icons.account_balance_rounded,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Sales Support',
        'description':
            'Learn about different sales policies, prices, and benefits.',
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.teal,
      },
      {
        'title': 'Information Hub',
        'description':
            'Get answers on services, locations, timings, and documentation.',
        'icon': Icons.info_rounded,
        'color': Colors.indigo,
      },
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Welcome message
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: GlassmorphicContainer(
                width: double.infinity,
                height: 100.h,
                borderRadius: 20.r,
                blur: 20,
                alignment: Alignment.center,
                border: 1.5,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ]
                          : [
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0.6),
                          ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            AppTheme.primaryColor.withOpacity(0.5),
                            AppTheme.accentColor.withOpacity(0.5),
                          ]
                          : [
                            AppTheme.primaryColor.withOpacity(0.3),
                            AppTheme.accentColor.withOpacity(0.3),
                          ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppTheme.primaryColor.withOpacity(0.2)
                                      : AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: const Color.fromARGB(255, 231, 231, 239),
                              size: 24.sp,
                            ),
                          )
                          .animate(controller: _pulseController, autoPlay: true)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                          ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome to VoxGenie!',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              'Tap the mic button and start speaking',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .slideY(
                begin: 0.3,
                end: 0,
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutQuint,
              )
              .fadeIn(
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 500),
              ),
        ),

        SizedBox(height: 30.h),

        // Feature cards
        Expanded(
          child: Container(
            child: PageView.builder(
              controller: _pageController,
              itemCount: features.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index).abs();
                          value = (1 - (value * 0.3).clamp(0.0, 1.0));
                        }

                        return Transform.scale(
                          scale: Curves.easeOutQuint.transform(value),
                          child: child,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: 160.h,
                          borderRadius: 24.r,
                          blur: 20,
                          alignment: Alignment.center,
                          border: 1.5,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors:
                                isDark
                                    ? [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ]
                                    : [
                                      Colors.white.withOpacity(0.8),
                                      Colors.white.withOpacity(0.6),
                                    ],
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              features[index]['color'].withOpacity(0.5),
                              features[index]['color'].withOpacity(0.2),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: features[index]['color'].withOpacity(
                                      isDark ? 0.2 : 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    features[index]['icon'],
                                    color: features[index]['color'],
                                    size: 30.sp,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  features[index]['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  features[index]['description'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: Duration(milliseconds: 200 + (index * 100)),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutQuint,
                    )
                    .fadeIn(
                      delay: Duration(milliseconds: 200 + (index * 100)),
                      duration: const Duration(milliseconds: 600),
                    );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/genie_processing.json',
            width: 200.w,
            height: 200.w,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return SizedBox(
                width: 100.w,
                height: 100.w,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 6.w,
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(
            'Processing your request...',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Our AI is working on your answer',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControlSection(bool isDark) {
    return Container(
      padding: EdgeInsets.only(bottom: 40.h, top: 20.h),
      child: Column(
        children: [
          // Voice button
          VoiceButton(
            onTap: _loading ? null : _handleSpeech,
            isListening: _isListening,
            size: 80.w,
          ),
          SizedBox(height: 20.h),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child:
                _loading
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

  void _showLanguageBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final languages = [
      {'name': 'English', 'code': 'en', 'icon': '🇺🇸'},
      {'name': 'हिंदी (Hindi)', 'code': 'hi', 'icon': '🇮🇳'},
      {'name': 'मराठी (Marathi)', 'code': 'mr', 'icon': '🇮🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E3A) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 50.w,
                  height: 5.h,
                  margin: EdgeInsets.only(top: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Select Language',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                ),

                // Language options
                Container(
                  constraints: BoxConstraints(maxHeight: 300.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final isSelected = _currentLanguage == language['name'];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6.h,
                          horizontal: 16.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        tileColor:
                            isSelected
                                ? isDark
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                        leading: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              language['icon'] as String,
                              style: TextStyle(fontSize: 20.sp),
                            ),
                          ),
                        ),
                        title: Text(
                          language['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 24.sp,
                                )
                                : null,
                        onTap: () {
                          _changeLanguage(language['name'] as String);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
    );
  }

  void _showHelpBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: 500.h,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E3A) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle indicator
                Container(
                  width: 50.w,
                  height: 5.h,
                  margin: EdgeInsets.only(top: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        color: AppTheme.primaryColor,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'How to use VoxGenie',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Help tips
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: ListView(
                      children: [
                        _buildHelpItem(
                          icon: Icons.mic_rounded,
                          title: 'Tap the mic button',
                          description:
                              'Start speaking after tapping the microphone button at the bottom of the screen.',
                        ),
                        _buildHelpItem(
                          icon: Icons.record_voice_over_rounded,
                          title: 'Ask your question',
                          description:
                              'Speak clearly and ask any question related to banking, insurance, healthcare, etc.',
                        ),
                        _buildHelpItem(
                          icon: Icons.touch_app_rounded,
                          title: 'Tap again to stop',
                          description:
                              'When you\'re done speaking, tap the mic button again to process your question.',
                        ),
                        _buildHelpItem(
                          icon: Icons.translate_rounded,
                          title: 'Multiple languages',
                          description:
                              'You can speak in English, Hindi or Marathi - VoxGenie understands all three!',
                        ),
                        _buildHelpItem(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Example questions',
                          description:
                              '"How do I reset my net banking password?"\n"मेरा डेबिट कार्ड खो गया है, मुझे क्या करना चाहिए?"\n"मला पॅन कार्ड कसे मिळवावे?"',
                        ),
                        _buildHelpItem(
                          icon: Icons.info_outline_rounded,
                          title: 'Automatic detection',
                          description:
                              'If you pause for a moment, VoxGenie will automatically detect the end of your query and begin processing it.',
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 54.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Got it',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 24.sp, color: AppTheme.primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}