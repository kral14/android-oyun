import 'package:flutter/material.dart';

// PathDefault - Klassik Yol (statik)
class PathDefaultWidget extends StatelessWidget {
  final int rows;
  final int cols;
  final int pathRow;
  final int pathCol;
  
  const PathDefaultWidget({
    super.key,
    required this.rows,
    required this.cols,
    required this.pathRow,
    required this.pathCol,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(250, 204, 21, 0.3),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: const Color.fromRGBO(250, 204, 21, 0.6),
          width: 0.5,
        ),
      ),
    );
  }
}

