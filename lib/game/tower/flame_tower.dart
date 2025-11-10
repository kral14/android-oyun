import 'package:flutter/material.dart';
import 'dart:math';

// Flame Tower - Sarı neon top, alev efekti animasyonu
class FlameTowerWidget extends StatefulWidget {
  final double size;
  final double angle;
  final bool isFiring;
  
  const FlameTowerWidget({
    super.key,
    this.size = 90.0,
    this.angle = -pi / 2,
    this.isFiring = false,
  });
  
  @override
  State<FlameTowerWidget> createState() => _FlameTowerWidgetState();
}

class _FlameTowerWidgetState extends State<FlameTowerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;
  
  @override
  void initState() {
    super.initState();
    // Alev efekti animasyonu (0.9 saniye)
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    
    _pulse = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final baseColor = Colors.orange; // Alev efekti için orange
    
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = _pulse.value;
          final bool firing = widget.isFiring;
          
          final barrelWidth = s * 0.2;
          final barrelHeight = s * 0.35;
          
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // arxa halə
              Container(
                width: s * 0.95,
                height: s * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withOpacity(0.4 * glow),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.6),
                      blurRadius: 18 * glow,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              
              // yan neon halqa
              Container(
                width: s * 0.86,
                height: s * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              
              // əsas gövdə
              Container(
                width: s * 0.82,
                height: s * 0.82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF0A0F1C),
                      Colors.black,
                    ],
                    stops: [0.12, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              
              // iç parlaq nüvə
              Container(
                width: s * 0.38,
                height: s * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3 + 0.2 * glow),
                      baseColor.withOpacity(0.9),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              
              // atəş parıltısı
              if (firing)
                Positioned(
                  top: s * 0.02,
                  child: Container(
                    width: s * 0.34,
                    height: s * 0.34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.7),
                          baseColor.withOpacity(0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // LÜLƏ — ən sonda ki, örtülməsin
              Positioned(
                top: s * 0.03,
                child: Transform.rotate(
                  angle: widget.angle + pi / 2,
                  child: Container(
                    width: barrelWidth,
                    height: barrelHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(barrelWidth),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          baseColor.withOpacity(0.05),
                          baseColor.withOpacity(0.9),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.85),
                          blurRadius: 8,
                          spreadRadius: 0.2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
