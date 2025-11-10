import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'path2.dart';

// Path2 Preview - Mağazada göstərmək üçün tüm grid
class Path2Preview extends StatefulWidget {
  final int rows;
  final int cols;

  const Path2Preview({
    super.key,
    this.rows = 7,
    this.cols = 15,
  });

  @override
  State<Path2Preview> createState() => _Path2PreviewState();
}

class _Path2PreviewState extends State<Path2Preview>
    with SingleTickerProviderStateMixin {
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: const Color.fromRGBO(59, 130, 246, 0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(59, 130, 246, 0.1),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ],
        ),
      );
    }

    // Yol hüceyrəsi - Path2Widget kullan
    return Path2Widget(
      rows: widget.rows,
      cols: widget.cols,
      pathRow: widget.rows ~/ 2,
      pathCol: col,
    );
  }
}

