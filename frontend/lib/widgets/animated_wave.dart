import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedWave extends StatefulWidget {
  final bool isListening;
  final Color color;
  final double height;
  final double amplitude;
  final Duration duration;

  const AnimatedWave({
    Key? key,
    required this.isListening,
    required this.color,
    required this.height,
    required this.amplitude,
    required this.duration,
  }) : super(key: key);

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _heightFactors;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _heightFactors = List.generate(30, (_) => _random.nextDouble() * 0.6 + 0.2);
    
    if (widget.isListening) {
      _controller.repeat();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(30, (index) {
              // Calculate dynamic height for each bar
              double phase = (_controller.value * 6.28) + (index * 0.2);
              double sinValue = sin(phase).abs();
              double baseHeight = widget.isListening
                  ? (sinValue * widget.amplitude + 5.h)
                  : 5.h;
              
              // Apply additional random factor for more natural look
              double waveHeight = baseHeight * _heightFactors[index];
              
              return Container(
                width: 4.w,
                height: widget.isListening 
                    ? waveHeight.clamp(5.h, widget.amplitude * 2) 
                    : 5.h,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(
                    widget.isListening ? 0.7 : 0.3,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                effects: [
                  if (!widget.isListening)
                    ScaleEffect(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.0, 1.5),
                      duration: Duration(milliseconds: 600 + (index * 50) % 400),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}