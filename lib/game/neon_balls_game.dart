import 'package:flutter/material.dart';
import 'dart:math';

// Neon rənglər
class NeonColors {
  static const Color neonBlue = Color(0xFF00F0FF);
  static const Color neonPink = Color(0xFFFF00F0);
  static const Color neonGreen = Color(0xFF00FF00);
  static const Color neonYellow = Color(0xFFFFF000);
  static const Color neonPurple = Color(0xFFF000FF);
  static const Color neonOrange = Color(0xFFFF8000);
  
  static List<Color> get allColors => [
    neonBlue,
    neonPink,
    neonGreen,
    neonYellow,
    neonPurple,
    neonOrange,
  ];
}

// Top modeli
class Ball {
  final int id;
  final Color color;
  int row;
  int col;
  bool isSelected;
  
  Ball({
    required this.id,
    required this.color,
    required this.row,
    required this.col,
    this.isSelected = false,
  });
}

// Oyun ekranı
class NeonBallsGameScreen extends StatefulWidget {
  const NeonBallsGameScreen({super.key});

  @override
  State<NeonBallsGameScreen> createState() => _NeonBallsGameScreenState();
}

class _NeonBallsGameScreenState extends State<NeonBallsGameScreen> {
  // Grid ölçüləri
  static const int gridRows = 8;
  static const int gridCols = 8;
  
  // Oyun taxtası
  List<List<Ball?>> grid = [];
  
  // Seçilmiş toplar
  List<Ball> selectedBalls = [];
  
  // Xal
  int score = 0;
  
  // Səviyyə
  int level = 1;
  
  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }
  
  // Grid-i başlat
  void _initializeGrid() {
    grid = List.generate(
      gridRows,
      (row) => List.generate(
        gridCols,
        (col) => _createRandomBall(row, col),
      ),
    );
  }
  
  // Təsadüfi top yarat
  Ball _createRandomBall(int row, int col) {
    final random = Random();
    final colors = NeonColors.allColors;
    final color = colors[random.nextInt(colors.length)];
    
    return Ball(
      id: row * gridCols + col,
      color: color,
      row: row,
      col: col,
    );
  }
  
  // Topa klik
  void _onBallTap(Ball ball) {
    setState(() {
      if (ball.isSelected) {
        // Seçimi ləğv et
        ball.isSelected = false;
        selectedBalls.remove(ball);
      } else {
        // Topu seç
        ball.isSelected = true;
        selectedBalls.add(ball);
      }
    });
  }
  
  // Topları düzəlt (matching)
  void _matchBalls() {
    if (selectedBalls.length < 3) {
      // Minimum 3 top lazımdır
      _clearSelection();
      return;
    }
    
    // Eyni rəngli topları tap
    final colorGroups = <Color, List<Ball>>{};
    for (var ball in selectedBalls) {
      colorGroups.putIfAbsent(ball.color, () => []).add(ball);
    }
    
    // Hər rəng qrupunda 3+ top varsa, sil
    bool hasMatch = false;
    for (var group in colorGroups.values) {
      if (group.length >= 3) {
        hasMatch = true;
        for (var ball in group) {
          grid[ball.row][ball.col] = null;
        }
        score += group.length * 10;
      }
    }
    
    if (hasMatch) {
      _clearSelection();
      _dropBalls();
      _fillEmptySpaces();
    } else {
      _clearSelection();
    }
  }
  
  // Topları aşağı sal
  void _dropBalls() {
    for (int col = 0; col < gridCols; col++) {
      int writeIndex = gridRows - 1;
      for (int row = gridRows - 1; row >= 0; row--) {
        if (grid[row][col] != null) {
          if (writeIndex != row) {
            grid[writeIndex][col] = grid[row][col];
            grid[writeIndex][col]!.row = writeIndex;
            grid[row][col] = null;
          }
          writeIndex--;
        }
      }
    }
  }
  
  // Boş yerləri doldur
  void _fillEmptySpaces() {
    for (int col = 0; col < gridCols; col++) {
      for (int row = 0; row < gridRows; row++) {
        if (grid[row][col] == null) {
          grid[row][col] = _createRandomBall(row, col);
        }
      }
    }
  }
  
  // Seçimi təmizlə
  void _clearSelection() {
    for (var ball in selectedBalls) {
      ball.isSelected = false;
    }
    selectedBalls.clear();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Üst panel - xal və səviyyə
            _buildTopPanel(),
            
            // Oyun taxtası
            Expanded(
              child: Center(
                child: _buildGameGrid(),
              ),
            ),
            
            // Alt panel - düymələr
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }
  
  // Üst panel
  Widget _buildTopPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(
            color: NeonColors.neonBlue,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Xal', score.toString(), NeonColors.neonGreen),
          _buildStatCard('Səviyyə', level.toString(), NeonColors.neonYellow),
          _buildStatCard('Seçilmiş', selectedBalls.length.toString(), NeonColors.neonPink),
        ],
      ),
    );
  }
  
  // Statistik kartı
  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color,
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Oyun taxtası
  Widget _buildGameGrid() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCols,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: gridRows * gridCols,
          itemBuilder: (context, index) {
            final row = index ~/ gridCols;
            final col = index % gridCols;
            final ball = grid[row][col];
            
            if (ball == null) {
              return Container();
            }
            
            return _buildBall(ball);
          },
        ),
      ),
    );
  }
  
  // Top widget
  Widget _buildBall(Ball ball) {
    return GestureDetector(
      onTap: () => _onBallTap(ball),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ball.color,
          boxShadow: [
            BoxShadow(
              color: ball.color.withValues(alpha: 0.8),
              blurRadius: ball.isSelected ? 20 : 10,
              spreadRadius: ball.isSelected ? 5 : 0,
            ),
          ],
          border: ball.isSelected
              ? Border.all(
                  color: Colors.white,
                  width: 3,
                )
              : null,
        ),
        child: Center(
          child: ball.isSelected
              ? Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
  
  // Alt panel
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: NeonColors.neonBlue,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNeonButton(
            'Düzəlt',
            NeonColors.neonGreen,
            () => _matchBalls(),
          ),
          _buildNeonButton(
            'Təmizlə',
            NeonColors.neonPink,
            () => _clearSelection(),
          ),
          _buildNeonButton(
            'Yenidən',
            NeonColors.neonYellow,
            () {
              setState(() {
                _initializeGrid();
                score = 0;
                level = 1;
              });
            },
          ),
        ],
      ),
    );
  }
  
  // Neon düymə
  Widget _buildNeonButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(
            color: color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

