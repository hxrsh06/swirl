import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback? onComplete;

  const SuccessAnimationWidget({Key? key, this.onComplete}) : super(key: key);

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Initialize checkmark animation controller
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _checkmarkController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Checkmark with scale animation
        ScaleTransition(
          scale: _checkmarkAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        // Confetti effect
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Down
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
            shouldLoop: false,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Colors.amber,
              Colors.green,
              Colors.pink,
            ],
            createParticlePath: (size) {
              final path = Path();
              path.addOval(Rect.fromCircle(center: Offset.zero, radius: size.width / 2));
              return path;
            },
          ),
        ),
      ],
    );
  }
}
