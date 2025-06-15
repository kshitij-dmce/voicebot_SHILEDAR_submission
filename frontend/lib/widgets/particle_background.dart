import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Color color;
  final int numberOfParticles;
  
  const ParticleBackground({
    Key? key,
    required this.color,
    this.numberOfParticles = 40,
  }) : super(key: key);

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late List<ParticleModel> particles;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    particles = List.generate(widget.numberOfParticles, (_) => ParticleModel(random));
  }

  @override
  void didUpdateWidget(ParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.numberOfParticles != widget.numberOfParticles) {
      particles = List.generate(widget.numberOfParticles, (_) => ParticleModel(random));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: particles.map((particle) => _buildParticle(particle, widget.color)).toList(),
    );
  }

  Widget _buildParticle(ParticleModel particle, Color color) {
    return AnimatedPositioned(
      duration: Duration(seconds: particle.speed),
      left: particle.position.dx * MediaQuery.of(context).size.width,
      top: particle.position.dy * MediaQuery.of(context).size.height,
      child: AnimatedOpacity(
        duration: Duration(seconds: particle.speed ~/ 2),
        opacity: particle.opacity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: particle.size,
          height: particle.size,
          decoration: BoxDecoration(
            color: color,
            shape: particle.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: !particle.isCircle ? BorderRadius.circular(3) : null,
          ),
          onEnd: () {
            if (mounted) {
              setState(() {
                particle.recreate(random);
              });
            }
          },
        ),
      ),
    );
  }
}

class ParticleModel {
  late Offset position;
  late double size;
  late int speed;
  late double opacity;
  late bool isCircle;

  ParticleModel(Random random) {
    _initializeValues(random);
  }

  void _initializeValues(Random random) {
    position = Offset(
      random.nextDouble(),
      random.nextDouble(),
    );
    size = random.nextDouble() * 8 + 2; // Size between 2 and 10
    speed = random.nextInt(10) + 5; // Speed between 5 and 15 seconds
    opacity = random.nextDouble() * 0.6 + 0.1; // Opacity between 0.1 and 0.7
    isCircle = random.nextBool();
  }

  void recreate(Random random) {
    position = Offset(
      random.nextDouble(),
      random.nextDouble(),
    );
    opacity = random.nextDouble() * 0.6 + 0.1;
    speed = random.nextInt(10) + 5;
  }
}