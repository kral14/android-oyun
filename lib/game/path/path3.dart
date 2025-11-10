import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Path3 - Pembe/Mor Neon Yol (sparkle animasiyası)
class Path3Widget extends StatefulWidget {
  final int rows;
  final int cols;
  final int pathRow;
  final int pathCol;
  
  const Path3Widget({
    super.key,
    required this.rows,
    required this.cols,
    required this.pathRow,
    required this.pathCol,
  });
  
  @override
  State<Path3Widget> createState() => _Path3WidgetState();
}

class _Path3WidgetState extends State<Path3Widget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 500),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final normalizedDelay = widget.cols > 0 ? widget.pathCol / widget.cols : 0.0;
    final totalDuration = 2.5;
    final delay = normalizedDelay * totalDuration;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final baseValue = (_animationController.value + delay / totalDuration) % 1.0;
        final sparkleValue = (sin(baseValue * 3 * 3.14159) + 1) / 2;
        final sparkleOpacity = 0.2 + (sparkleValue * 0.6);
        
        double waveOpacity = 0.0;
        double translateX = -1.2;
        
        if (baseValue >= 0.0 && baseValue < 0.2) {
          waveOpacity = baseValue / 0.2;
          translateX = -1.2 + (baseValue / 0.2) * 0.4;
        } else if (baseValue >= 0.2 && baseValue < 0.6) {
          waveOpacity = 1.0;
          translateX = -0.8 + ((baseValue - 0.2) / 0.4) * 2.0;
        } else if (baseValue >= 0.6 && baseValue < 0.8) {
          waveOpacity = 1.0 - ((baseValue - 0.6) / 0.2);
          translateX = 1.2 + ((baseValue - 0.6) / 0.2) * 0.8;
        } else {
          waveOpacity = 0.0;
          translateX = 2.0;
        }
        
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color.fromRGBO(236, 72, 153, 0.2),
                const Color.fromRGBO(168, 85, 247, 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color.fromRGBO(236, 72, 153, 0.9),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(236, 72, 153, 0.5),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sparkle glow effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        Color.fromRGBO(236, 72, 153, 0.0),
                        Color.fromRGBO(236, 72, 153, sparkleOpacity * 0.6),
                        Color.fromRGBO(168, 85, 247, sparkleOpacity * 0.4),
                        Color.fromRGBO(236, 72, 153, 0.0),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Wave animasiyası
              if (waveOpacity > 0)
                Positioned.fill(
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(translateX * 46, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              const Color.fromRGBO(236, 72, 153, 1.0).withValues(alpha: waveOpacity),
                              const Color.fromRGBO(168, 85, 247, 0.9).withValues(alpha: waveOpacity),
                              const Color.fromRGBO(236, 72, 153, 0.8).withValues(alpha: waveOpacity),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

