import 'package:flutter/material.dart';
import 'dart:math';

class BeautifulCannonWidget extends StatefulWidget {
  final double size;
  final double angle;    // radian
  final bool isFiring;
  final Color color;

  const BeautifulCannonWidget({
    super.key,
    this.size = 90.0,
    this.angle = -pi / 2,
    this.isFiring = false,
    this.color = const Color(0xFF38BDF8),
  });

  @override
  State<BeautifulCannonWidget> createState() => _BeautifulCannonWidgetState();
}

class _BeautifulCannonWidgetState extends State<BeautifulCannonWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
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
    final baseColor = widget.color;

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final glow = _pulse.value;
          final firing = widget.isFiring;

          // HTML-dəki kimi: lülə mərkəzli, 1 az yuxarı
          final barrelWidth = s * 0.16;
          final barrelHeight = s * 0.34;
          // mərkəzdən nə qədər yuxarı çəkək (0.0 = mərkəz)
          final centerLift = s * 0.06;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // arxa neon halo
              Container(
                width: s * 0.98,
                height: s * 0.98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      baseColor.withOpacity(0.35 * glow),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.55),
                      blurRadius: 20 * glow,
                    ),
                  ],
                ),
              ),

              // incə neon halqa
              Container(
                width: s * 0.86,
                height: s * 0.86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: baseColor.withOpacity(0.4),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),

              // əsas tünd bədən
              Container(
                width: s * 0.82,
                height: s * 0.82,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF0A0F1C),
                      Colors.black,
                    ],
                    stops: [0.15, 1.0],
                  ),
                ),
              ),

              // parlayan core
              Container(
                width: s * 0.38,
                height: s * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.28 + glow * 0.1),
                      baseColor.withOpacity(0.95),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),

              // atəş flash
              if (firing)
                Container(
                  width: s * 0.38,
                  height: s * 0.38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.7),
                        baseColor.withOpacity(0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: baseColor.withOpacity(0.85),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

              // LÜLƏ – mərkəzdən azca yuxarı, amma fırlanma mərkəzdə
              Transform.translate(
                offset: Offset(0, -centerLift),
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
                          baseColor.withOpacity(0.02),
                          baseColor.withOpacity(0.85),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.28),
                        width: 0.7,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: baseColor.withOpacity(0.8),
                          blurRadius: 8,
                          spreadRadius: 0.3,
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

// sadə alias
class BasicTowerWidget extends StatelessWidget {
  final double size;
  final double angle;
  final bool isFiring;

  const BasicTowerWidget({
    super.key,
    this.size = 90,
    this.angle = -pi / 2,
    this.isFiring = false,
  });

  @override
  Widget build(BuildContext context) {
    return BeautifulCannonWidget(
      size: size,
      angle: angle,
      isFiring: isFiring,
      color: const Color(0xFF38BDF8),
    );
  }
}
