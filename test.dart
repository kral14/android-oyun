import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const NeonCannonsApp());
}

class NeonCannonsApp extends StatelessWidget {
  const NeonCannonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Toplar',
      debugShowCheckedModeBanner: false,
      home: const NeonCannonsPage(),
    );
  }
}

class NeonCannonsPage extends StatefulWidget {
  const NeonCannonsPage({super.key});

  @override
  State<NeonCannonsPage> createState() => _NeonCannonsPageState();
}

class _NeonCannonsPageState extends State<NeonCannonsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ticker;

  // səhnənin ölçüsünü LayoutBuilder-dən alacağıq
  Size _sceneSize = Size.zero;

  // güllələr
  final List<_Bullet> _bullets = [];

  // hər top üçün timer
  Timer? _timer1;
  Timer? _timer2;
  Timer? _timer3;

  @override
  void initState() {
    super.initState();
    // 60fps-lik axın – hər frame-də güllə koordinatlarını yeniləyirik
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onTick)
     ..repeat();

    // fərqli tezliklərlə atəş
    _timer1 = Timer.periodic(const Duration(milliseconds: 480), (_) {
      _spawnBullet(0.12, const Color(0xFF38BDF8));
    });
    _timer2 = Timer.periodic(const Duration(milliseconds: 360), (_) {
      _spawnBullet(0.45, const Color(0xFFFACC15));
    });
    _timer3 = Timer.periodic(const Duration(milliseconds: 520), (_) {
      _spawnBullet(0.78, const Color(0xFFF472B6));
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _timer1?.cancel();
    _timer2?.cancel();
    _timer3?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (_sceneSize == Size.zero) return;

    // yuxarı hərəkət → hər frame y azaldırıq
    const double speedPerSecond = 420; // px/s
    final double dt = 1 / 60; // təxmini

    setState(() {
      _bullets.removeWhere((b) => b.position.dy + b.height < 0);
      for (final b in _bullets) {
        b.position = Offset(
          b.position.dx,
          b.position.dy - speedPerSecond * dt,
        );
      }
    });
  }

  void _spawnBullet(double xPercent, Color color) {
    if (_sceneSize == Size.zero) return;

    final double x = _sceneSize.width * xPercent;
    final double barrelTopY = _sceneSize.height - 90; // topları dibdə yerləşdirəcəyik

    setState(() {
      _bullets.add(
        _Bullet(
          position: Offset(x - 3.5, barrelTopY - 10),
          color: color,
          width: 7,
          height: 16,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Szenanı max 900px enində saxlayırıq
            final double width = min(constraints.maxWidth * 0.96, 900);
            final double height = 420;

            _sceneSize = Size(width, height);

            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x261E293B)),
                gradient: const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Color(0x330F172A),
                    Colors.black,
                  ],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 40,
                    spreadRadius: -12,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // HUD
                  const Positioned(
                    top: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Neon müdafiə topları — auto fire',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 13,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  // yer xətti
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 26,
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x000F76B2),
                            Color(0xFF38BDF8),
                            Color(0xFFE64899),
                            Color(0x000F76B2),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // güllələr
                  ..._bullets.map((b) {
                    return Positioned(
                      left: b.position.dx,
                      top: b.position.dy,
                      child: _BulletWidget(bullet: b),
                    );
                  }).toList(),

                  // toplar
                  Positioned(
                    bottom: 36,
                    left: width * 0.12 - 45,
                    child: const _Cannon(
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  Positioned(
                    bottom: 36,
                    left: width * 0.45 - 45,
                    child: const _Cannon(
                      color: Color(0xFFFACC15),
                    ),
                  ),
                  Positioned(
                    bottom: 36,
                    left: width * 0.78 - 45,
                    child: const _Cannon(
                      color: Color(0xFFF472B6),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Bullet {
  Offset position;
  final Color color;
  final double width;
  final double height;

  _Bullet({
    required this.position,
    required this.color,
    required this.width,
    required this.height,
  });
}

class _BulletWidget extends StatelessWidget {
  final _Bullet bullet;
  const _BulletWidget({required this.bullet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: bullet.width,
      height: bullet.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // əsas mermi
          Container(
            width: bullet.width,
            height: bullet.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bullet.color,
                  bullet.color.withOpacity(0),
                ],
              ),
            ),
          ),
          // parıltı
          Positioned(
            top: 8,
            left: -12,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    bullet.color.withOpacity(.4),
                    bullet.color.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cannon extends StatefulWidget {
  final Color color;
  const _Cannon({required this.color});

  @override
  State<_Cannon> createState() => _CannonState();
}

class _CannonState extends State<_Cannon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final v = _pulse.value;
        return SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // barrel
              Positioned(
                top: -32,
                left: 90 / 2 - 8,
                child: Container(
                  width: 16,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.color.withOpacity(0),
                        widget.color.withOpacity(.6 + v * 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: widget.color.withOpacity(.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(.6),
                        blurRadius: 10 + 4 * v,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // base
              Center(
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withOpacity(.7),
                        Colors.black.withOpacity(0),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Colors.black,
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(.16),
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
