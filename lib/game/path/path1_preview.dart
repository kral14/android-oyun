import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'path1.dart';

// Path1 Preview - Mağazada göstərmək üçün tüm grid
class Path1Preview extends StatefulWidget {
  final int rows;
  final int cols;

  const Path1Preview({
    super.key,
    this.rows = 7,
    this.cols = 15,
  });

  @override
  State<Path1Preview> createState() => _Path1PreviewState();
}

class _Path1PreviewState extends State<Path1Preview>
    with SingleTickerProviderStateMixin {
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
    if (!isPath) {
      // Normal hüceyrə
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
      );
    }

    // Yol hüceyrəsi - Path1Widget kullan
    return Path1Widget(
      rows: widget.rows,
      cols: widget.cols,
      pathRow: widget.rows ~/ 2,
      pathCol: col,
    );
  }
}

