import 'package:flutter/material.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final LinearGradient gradient;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;

  const GradientBorderContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(16.0),
    required this.gradient,
    required this.backgroundColor,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: Stack(
        children: [
          // Gradient border using container under the main one
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          // Inner container with content
          Positioned(
            left: borderWidth,
            top: borderWidth,
            right: borderWidth,
            bottom: borderWidth,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius - borderWidth / 2),
              ),
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}