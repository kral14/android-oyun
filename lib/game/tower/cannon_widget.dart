import 'package:flutter/material.dart';
import 'dart:math';

// Neon top widget - HTML tasarımına əsasən
class CannonWidget extends StatefulWidget {
  final Color color;
  final double size;
  final double angle; // Lülə istiqaməti (radian)
  final bool isFiring; // Atəş edir?
  
  const CannonWidget({
    Key? key,
    required this.color,
    this.size = 90.0,
    this.angle = -pi / 2, // Yuxarı istiqamət
    this.isFiring = false,
  }) : super(key: key);
  
  @override
  State<CannonWidget> createState() => _CannonWidgetState();
}

class _CannonWidgetState extends State<CannonWidget> with SingleTickerProviderStateMixin {
  late AnimationController _barrelController;
  late Animation<double> _barrelAnimation;
  
  @override
  void initState() {
    super.initState();
    // Barrel pulse animasiyası
    _barrelController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    
    _barrelAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _barrelController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _barrelController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Güvenli hesaplamalar - NaN önleme
    final safeSize = widget.size > 0 ? widget.size : 90.0;
    
    // Görsel tasarıma göre: top hücrenin %90'ı, core topun %40'ı, barrel daha büyük ve görünür
    final cannonSize = safeSize * 0.9; // Top hücrenin %90'ı
    final baseSize = cannonSize; // Base topun tamamı
    final coreSize = cannonSize * 0.4; // Core topun %40'ı
    // Barrel görselde açıkça görünüyor - hap şeklinde, mavi, topun üstünde
    final barrelWidth = safeSize * 0.18; // Barrel hücrenin %18 genişlik (hap şeklinde)
    final barrelHeight = safeSize * 0.22; // Barrel hücrenin %22 yükseklik (küçük hap)
    
    // BorderRadius değerlerini güvenli hale getir
    final barrelRadius = (barrelWidth / 2).clamp(0.0, double.infinity);
    
    return AnimatedBuilder(
      animation: _barrelAnimation,
      builder: (context, child) {
        final v = _barrelAnimation.value;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Baza (cannon-base) - tam yuvarlak, hücrenin %90'ı (önce base, sonra lüle üstte)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: baseSize,
                height: baseSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  // Nüvə (cannon-core) - topun %40'ı
                  child: Container(
                    width: coreSize,
                    height: coreSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          Color(0xFF0F172A),
                          Colors.black,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.25),
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Lülə (barrel) - görseldeki kimi: hap şeklinde, mavi, topun üstünde
            Positioned(
              top: 2, // Hüceyrənin üstünden biraz
              left: safeSize / 2 - barrelWidth / 2, // Ortada
              child: Transform.rotate(
                angle: widget.angle + pi / 2, // HTML'de yuxarı istiqamət
                child: Container(
                  width: barrelWidth,
                  height: barrelHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(barrelHeight / 2), // Hap şekli (height/2)
                    color: widget.color.withValues(alpha: 0.9), // Solid, opak mavi (görseldeki gibi)
                    border: Border.all(
                      color: widget.color.withValues(alpha: 1.0), // Tam opak border
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.9), // Güçlü glow
                        blurRadius: 6 + 2 * v,
                        spreadRadius: 0.5,
                      ),
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Mermi widget - HTML tasarımına əsasən
class BulletWidget extends StatelessWidget {
  final Color color;
  final double x;
  final double y;
  
  const BulletWidget({
    Key? key,
    required this.color,
    required this.x,
    required this.y,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Stack(
        children: [
          // Mermi özü
          Container(
            width: 7,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // Mermi arxasındakı glow efekti
          Positioned(
            top: 10,
            left: -14,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.55),
                    Colors.white.withValues(alpha: 0.0),
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

// Muzzle flash efekti
class MuzzleFlashWidget extends StatefulWidget {
  final Color color;
  final double size;
  
  const MuzzleFlashWidget({
    Key? key,
    required this.color,
    this.size = 28.0,
  }) : super(key: key);
  
  @override
  State<MuzzleFlashWidget> createState() => _MuzzleFlashWidgetState();
}

class _MuzzleFlashWidgetState extends State<MuzzleFlashWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 190),
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(begin: 0.85, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.84, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.84, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color,
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color,
                    blurRadius: 13,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

