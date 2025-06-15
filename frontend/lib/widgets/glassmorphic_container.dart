import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final AlignmentGeometry alignment;
  final double border;
  final LinearGradient linearGradient;
  final LinearGradient borderGradient;
  final Widget child;

  const GlassmorphicContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.blur,
    required this.alignment,
    required this.border,
    required this.linearGradient,
    required this.borderGradient,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        alignment: alignment,
        child: Stack(
          children: [
            // Blurred background with gradient
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blur,
                sigmaY: blur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: linearGradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
            
            // Border with gradient
            if (border > 0)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    width: border,
                  ),
                  gradient: borderGradient,
                ),
              ),
            
            // Content
            Positioned.fill(
              child: Center(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}