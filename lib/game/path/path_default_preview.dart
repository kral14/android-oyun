import 'package:flutter/material.dart';
import 'path_default.dart';

// PathDefault Preview - Mağazada göstərmək üçün tüm grid
class PathDefaultPreview extends StatelessWidget {
  final int rows;
  final int cols;

  const PathDefaultPreview({
    super.key,
    this.rows = 7,
    this.cols = 15,
  });

  @override
  Widget build(BuildContext context) {
    final pathRow = rows ~/ 2;

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

          final cellSize = (constraints.maxWidth / cols).clamp(2.0, 10.0);
          final cellHeight = (constraints.maxHeight / rows).clamp(2.0, 10.0);
          final actualCellSize = cellSize < cellHeight ? cellSize : cellHeight;

          return SizedBox(
            width: actualCellSize * cols,
            height: actualCellSize * rows,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 1,
                crossAxisSpacing: 1,
                childAspectRatio: 1,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                final r = index ~/ cols;
                final c = index % cols;
                final isPath = r == pathRow;

                if (!isPath) {
                  // Normal hüceyrə
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                  );
                }

                // Yol hüceyrəsi
                return PathDefaultWidget(
                  rows: rows,
                  cols: cols,
                  pathRow: pathRow,
                  pathCol: c,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

