import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Path2 - Mavi Neon Yol (dalğa animasiyası)
class Path2Widget extends StatefulWidget {
  final int rows;
  final int cols;
  final int pathRow;
  final int pathCol;
  
  const Path2Widget({
    super.key,
    required this.rows,
    required this.cols,
    required this.pathRow,
    required this.pathCol,
  });
  
  @override
  State<Path2Widget> createState() => _Path2WidgetState();
}

class _Path2WidgetState extends State<Path2Widget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3, milliseconds: 600),
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
    final totalDuration = 3.6;
    final delay = normalizedDelay * totalDuration;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final baseValue = (_animationController.value + delay / totalDuration) % 1.0;
        final pulseValue = (sin(baseValue * 2 * 3.14159) + 1) / 2;
        final pulseOpacity = 0.3 + (pulseValue * 0.4);
        
        double waveOpacity = 0.0;
        double translateX = -1.2;
        
        if (baseValue >= 0.0 && baseValue < 0.15) {
          waveOpacity = baseValue / 0.15;
          translateX = -1.2 + (baseValue / 0.15) * 0.3;
        } else if (baseValue >= 0.15 && baseValue < 0.5) {
          waveOpacity = 1.0;
          translateX = -0.9 + ((baseValue - 0.15) / 0.35) * 2.1;
        } else if (baseValue >= 0.5 && baseValue < 0.7) {
          waveOpacity = 1.0 - ((baseValue - 0.5) / 0.2);
          translateX = 1.2 + ((baseValue - 0.5) / 0.2) * 0.8;
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
                const Color.fromRGBO(59, 130, 246, 0.15),
                const Color.fromRGBO(59, 130, 246, 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color.fromRGBO(59, 130, 246, 0.9),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromRGBO(59, 130, 246, 0.4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Pulse glow effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Color.fromRGBO(59, 130, 246, 0.0),
                        Color.fromRGBO(59, 130, 246, pulseOpacity),
                        Color.fromRGBO(59, 130, 246, 0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
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
                              const Color.fromRGBO(59, 130, 246, 1.0).withValues(alpha: waveOpacity),
                              const Color.fromRGBO(147, 197, 253, 0.8).withValues(alpha: waveOpacity),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
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

