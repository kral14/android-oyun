import 'package:flutter/material.dart';

// Default grid preview widget (balaca görünüş)
class GridDefaultPreview extends StatelessWidget {
  final int rows;
  final int cols;
  
  const GridDefaultPreview({
    super.key,
    required this.rows,
    required this.cols,
  });
  
  @override
  Widget build(BuildContext context) {
    final pathRow = rows ~/ 2;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x26151E33),
        borderRadius: BorderRadius.circular(4),
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
          // GridView əvəzinə sadə CustomPaint və ya Row/Column istifadə edək
          final cellSize = (constraints.maxWidth / cols).clamp(0.5, 5.0);
          final cellHeight = (constraints.maxHeight / rows).clamp(0.5, 5.0);
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
                
                return Container(
                  decoration: BoxDecoration(
                    color: isPath 
                        ? const Color.fromRGBO(250, 204, 21, 0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isPath
                          ? const Color.fromRGBO(250, 204, 21, 0.6)
                          : const Color.fromRGBO(59, 130, 246, 0.2),
                      width: 0.5,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

