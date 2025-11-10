import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Path1 - Sarı Neon Yol (qığılcım animasiyası)
class Path1Widget extends StatefulWidget {
  final int rows;
  final int cols;
  final int pathRow;
  final int pathCol;
  
  const Path1Widget({
    super.key,
    required this.rows,
    required this.cols,
    required this.pathRow,
    required this.pathCol,
  });
  
  @override
  State<Path1Widget> createState() => _Path1WidgetState();
}

class _Path1WidgetState extends State<Path1Widget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final t = _animationController.value;
        final sparkPos = t * widget.cols;
        final dist = (sparkPos - widget.pathCol).abs();
        final isSparkHere = dist < 0.9;
        final sparkStrength = (1 - (dist / 0.9)).clamp(0.0, 1.0);
        final breathe = 0.25 + 0.25 * sin((t + widget.pathCol * 0.05) * pi * 2);
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: const Color(0xFF030712),
            border: Border.all(
              color: const Color.fromRGBO(250, 204, 21, 0.45),
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              // Yol xətti (nazik sarı zolaq)
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 1.2,
                  margin: const EdgeInsets.symmetric(horizontal: 0.3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromRGBO(250, 204, 21, 0.05),
                        Color.fromRGBO(250, 204, 21, 0.35 + breathe),
                        const Color.fromRGBO(250, 204, 21, 0.05),
                      ],
                    ),
                  ),
                ),
              ),
              // Qığılcım dairəsi
              if (isSparkHere)
                Center(
                  child: Container(
                    width: 4.4,
                    height: 4.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color.fromRGBO(255, 241, 190, 1.0)
                              .withOpacity(0.6 + sparkStrength * 0.4),
                          const Color.fromRGBO(250, 204, 21, 1.0)
                              .withOpacity(0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(250, 204, 21, 1.0)
                              .withOpacity(0.4 + sparkStrength * 0.4),
                          blurRadius: 5 + 4 * sparkStrength,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              // Üst nazik çərçivə
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(0.45),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: const Color.fromRGBO(250, 204, 21, 0.08),
                        width: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              // Hüceyrənin yüngül nəfəsi
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        const Color.fromRGBO(250, 204, 21, 0.0),
                        Color.fromRGBO(250, 204, 21, 0.07 + breathe * 0.2),
                      ],
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

