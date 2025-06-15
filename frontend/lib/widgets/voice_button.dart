// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../core/theme/app_theme.dart';

// class VoiceButton extends StatefulWidget {
//   final Function()? onTap;
//   final bool isListening;
//   final double? size;

//   const VoiceButton({
//     Key? key,
//     required this.onTap,
//     this.isListening = false,
//     this.size,
//   }) : super(key: key);

//   @override
//   State<VoiceButton> createState() => _VoiceButtonState();
// }

// class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
    
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.9,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );
    
//     if (widget.isListening) {
//       _startPulseAnimation();
//     }
//   }

//   @override
//   void didUpdateWidget(VoiceButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isListening != oldWidget.isListening) {
//       if (widget.isListening) {
//         _startPulseAnimation();
//       } else {
//         _animationController.stop();
//         _animationController.reset();
//       }
//     }
//   }

//   void _startPulseAnimation() {
//     _animationController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final buttonSize = widget.size ?? 70.w;
    
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _isPressed ? _scaleAnimation.value : 1.0,
//           child: GestureDetector(
//             onTapDown: (_) {
//               if (widget.onTap != null) {
//                 setState(() => _isPressed = true);
//                 _animationController.forward();
//               }
//             },
//             onTapUp: (_) {
//               setState(() => _isPressed = false);
//               _animationController.reverse();
//               if (widget.onTap != null) {
//                 widget.onTap!();
//               }
//             },
//             onTapCancel: () {
//               setState(() => _isPressed = false);
//               _animationController.reverse();
//             },
//             child: Container(
//               width: buttonSize,
//               height: buttonSize,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: widget.isListening
//                     ? [
//                         const Color(0xFFF44336),
//                         const Color(0xFFE53935),
//                       ]
//                     : [
//                         AppTheme.primaryColor,
//                         const Color(0xFF6A64F0),
//                       ],
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.isListening
//                       ? Colors.red.withOpacity(0.3)
//                       : AppTheme.primaryColor.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Pulse animation for listening state
//                   if (widget.isListening)
//                     ...List.generate(3, (index) {
//                       return Animate(
//                         autoPlay: true,
//                         onComplete: (controller) => controller.repeat(), // Use onComplete for looping
//                         effects: [
//                           ScaleEffect(
//                             begin: const Offset(0.8, 0.8),
//                             end: const Offset(1.2, 1.2),
//                             duration: Duration(milliseconds: 1500 + (index * 200)),
//                             curve: Curves.easeInOut,
//                           ),
//                           FadeEffect(
//                             begin: 0.7,
//                             end: 0.0, // Using end instead of opacity
//                             duration: Duration(milliseconds: 1500 + (index * 200)),
//                           ),
//                         ],
//                         child: Container(
//                           width: buttonSize * (1 + (index * 0.2)),
//                           height: buttonSize * (1 + (index * 0.2)),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.red.withOpacity(0.3 - (index * 0.1)),
//                           ),
//                         ),
//                       );
//                     }),
                  
//                   // Main icon
//                   Icon(
//                     widget.isListening ? Icons.stop_rounded : Icons.mic_rounded,
//                     color: Colors.white,
//                     size: buttonSize * 0.5,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

class VoiceButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isListening;
  final double size;
  final double? elevation;
  
  const VoiceButton({
    Key? key,
    required this.onTap,
    required this.isListening,
    this.size = 80.0,
    this.elevation,
  }) : super(key: key);

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _rippleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effect when listening
          if (widget.isListening)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: widget.size * _rippleAnimation.value,
                  height: widget.size * _rippleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                );
              },
            ),
          
          // Second ripple with delay
          if (widget.isListening)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: widget.size * (_rippleAnimation.value * 0.8),
                  height: widget.size * (_rippleAnimation.value * 0.8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentColor.withOpacity(0.15),
                  ),
                );
              },
            ),
          
          // Main button with mic icon
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isListening ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isListening
                          ? [
                              AppTheme.accentColor,
                              AppTheme.primaryColor,
                            ]
                          : [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withBlue(
                                AppTheme.primaryColor.blue + 30,
                              ),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: widget.isListening ? 2 : 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.size),
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(widget.size),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: widget.isListening
                              ? Icon(
                                  Icons.mic,
                                  color: Colors.white,
                                  size: widget.size * 0.5,
                                  key: const ValueKey('mic_on'),
                                )
                              : Icon(
                                  Icons.mic_none_rounded,
                                  color: Colors.white,
                                  size: widget.size * 0.5,
                                  key: const ValueKey('mic_off'),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Pulsing dot when active
          if (widget.isListening)
            Positioned(
              top: 15.h,
              right: 15.h,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.3, 1.3),
                  duration: const Duration(milliseconds: 600),
                ),
            ),
        ],
      ),
    );
  }
}