import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Grid1 preview widget (balaca görünüş) - animasiyalı yol
class Grid1Preview extends StatefulWidget {
  final int rows;
  final int cols;

  const Grid1Preview({
    super.key,
    this.rows = 7,
    this.cols = 15,
  });

  @override
  State<Grid1Preview> createState() => _Grid1PreviewState();
}

class _Grid1PreviewState extends State<Grid1Preview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    // 3.2 saniyədə bir tam dövr
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pathRow = widget.rows ~/ 2;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x18101822),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0x261E293B),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
            return const SizedBox.shrink();
          }

          final cellSize =
              (constraints.maxWidth / widget.cols).clamp(2.0, 10.0);
          final cellHeight =
              (constraints.maxHeight / widget.rows).clamp(2.0, 10.0);
          final actualCellSize = cellSize < cellHeight ? cellSize : cellHeight;

          return SizedBox(
            width: actualCellSize * widget.cols,
            height: actualCellSize * widget.rows,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.cols,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                childAspectRatio: 1,
              ),
              itemCount: widget.rows * widget.cols,
              itemBuilder: (context, index) {
                final r = index ~/ widget.cols;
                final c = index % widget.cols;
                final isPath = r == pathRow;

                return _buildCell(isPath, c);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCell(bool isPath, int col) {
    // Sadece boş hüceyrələr - yol animasiyası ayrı path dosyalarında
    if (!isPath) {
      // Normal hüceyrə – 2 tonlu, içində kiçik işıq
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final t = _animationController.value;
          final breathe = 0.3 + 0.15 * sin((t + col * 0.03) * pi * 2);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                ],
              ),
              border: Border.all(
                color: const Color.fromRGBO(59, 130, 246, 0.12),
                width: 0.4,
              ),
            ),
            child: Stack(
              children: [
                // Daxili balaca işıq nöqtəsi
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    width: 2,
                    height: 2,
                    margin: const EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(breathe),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Nazik daxili çərçivə
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(0.6),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.015),
                          width: 0.3,
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
    
    // Yol hüceyrəsi - sadə görünüş (animasiya path dosyalarında)
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: const Color(0xFF030712),
        border: Border.all(
          color: const Color.fromRGBO(250, 204, 21, 0.45),
          width: 0.5,
        ),
      ),
    );
  }
}
