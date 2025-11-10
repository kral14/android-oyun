import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'gift_code_service.dart';
import 'grid/grid1.dart';
import 'grid/grid2.dart';
import 'grid/grid3.dart';
import 'grid/grid_default.dart';
import 'path/path1.dart';
import 'path/path2.dart';
import 'path/path3.dart';
import 'path/path_default.dart';
import 'path/path1_preview.dart';
import 'path/path2_preview.dart';
import 'path/path3_preview.dart';
import 'path/path_default_preview.dart';
import 'tower/cannon_widget.dart';
import 'tower/basic_tower.dart';
import 'tower/rapid_tower.dart';
import 'tower/heavy_tower.dart';
import 'tower/ice_tower.dart';
import 'tower/flame_tower.dart';
import 'tower/laser_tower.dart';
import 'tower/plasma_tower.dart';

// Neon rənglər
class NeonColors {
  static const Color neonBlue = Color(0xFF00F0FF);
  static const Color neonPink = Color(0xFFFF00F0);
  static const Color neonGreen = Color(0xFF00FF00);
  static const Color neonYellow = Color(0xFFFFF000);
  static const Color neonPurple = Color(0xFFF000FF);
  static const Color neonOrange = Color(0xFFFF8000);
  static const Color neonRed = Color(0xFFFF0000);
  static const Color neonCyan = Color(0xFF00FFFF);
}

// Grid ölçüləri
const int gridRows = 7;
const int gridCols = 15;

// Grid konfiqurasiyası modeli
class GridConfig {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final int emeraldCost;
  final bool isDefault;
  final String? gridPreviewPath; // Grid preview widget-inin yolu (nullable)
  bool isOwned;
  bool isActive;
  
  GridConfig({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    this.emeraldCost = 0,
    this.gridPreviewPath = 'default',
    this.isDefault = false,
    this.isOwned = false,
    this.isActive = false,
  });
  
  // Grid preview widget-ini qaytar
  Widget buildPreview() {
    final path = gridPreviewPath;
    if (path == null || path.isEmpty) {
      return GridDefaultPreview(rows: rows, cols: cols);
    }
    switch (path) {
      case 'grid1':
        return Grid1Preview(rows: rows, cols: cols);
      case 'grid2':
        return Grid2Preview(rows: rows, cols: cols);
      case 'grid3':
        return Grid3Preview(rows: rows, cols: cols);
      default:
        // Default preview
        return GridDefaultPreview(rows: rows, cols: cols);
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rows': rows,
      'cols': cols,
      'emeraldCost': emeraldCost,
      'gridPreviewPath': gridPreviewPath ?? 'default',
      'isDefault': isDefault,
      'isOwned': isOwned,
      'isActive': isActive,
    };
  }
  
  factory GridConfig.fromJson(Map<String, dynamic> json) {
    return GridConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      emeraldCost: json['emeraldCost'] as int? ?? 0,
      gridPreviewPath: json['gridPreviewPath'] as String? ?? 'default',
      isDefault: json['isDefault'] as bool? ?? false,
      isOwned: json['isOwned'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

// Yol konfiqurasiyası modeli
class PathConfig {
  final String id;
  final String name;
  final int emeraldCost;
  final bool isDefault;
  final String? pathPreviewPath; // Path preview widget-inin yolu (nullable)
  bool isOwned;
  bool isActive;
  
  PathConfig({
    required this.id,
    required this.name,
    this.emeraldCost = 0,
    this.pathPreviewPath = 'default',
    this.isDefault = false,
    this.isOwned = false,
    this.isActive = false,
  });
  
  // Path preview widget-ini qaytar (mağazada istifadə üçün - tüm grid)
  Widget buildPreview() {
    final path = pathPreviewPath;
    if (path == null || path.isEmpty) {
      return PathDefaultPreview(rows: 7, cols: 15);
    }
    switch (path) {
      case 'path1':
        return Path1Preview(rows: 7, cols: 15);
      case 'path2':
        return Path2Preview(rows: 7, cols: 15);
      case 'path3':
        return Path3Preview(rows: 7, cols: 15);
      default:
        return PathDefaultPreview(rows: 7, cols: 15);
    }
  }
  
  // Path widget-ini qaytar (oyun taxtasında istifadə üçün - tek hüceyrə)
  Widget buildPathWidget({required int rows, required int cols, required int pathRow, required int pathCol}) {
    final path = pathPreviewPath;
    if (path == null || path.isEmpty) {
      return PathDefaultWidget(rows: rows, cols: cols, pathRow: pathRow, pathCol: pathCol);
    }
    switch (path) {
      case 'path1':
        return Path1Widget(rows: rows, cols: cols, pathRow: pathRow, pathCol: pathCol);
      case 'path2':
        return Path2Widget(rows: rows, cols: cols, pathRow: pathRow, pathCol: pathCol);
      case 'path3':
        return Path3Widget(rows: rows, cols: cols, pathRow: pathRow, pathCol: pathCol);
      default:
        return PathDefaultWidget(rows: rows, cols: cols, pathRow: pathRow, pathCol: pathCol);
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emeraldCost': emeraldCost,
      'pathPreviewPath': pathPreviewPath ?? 'default',
      'isDefault': isDefault,
      'isOwned': isOwned,
      'isActive': isActive,
    };
  }
  
  factory PathConfig.fromJson(Map<String, dynamic> json) {
    return PathConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      emeraldCost: json['emeraldCost'] as int? ?? 0,
      pathPreviewPath: json['pathPreviewPath'] as String? ?? 'default',
      isDefault: json['isDefault'] as bool? ?? false,
      isOwned: json['isOwned'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

// Cell növləri
enum CellType {
  empty,    // Boş
  path,     // Yol
  tower,    // Qüllə
}

// Düşmən növləri
enum EnemyType {
  square,   // Kvadrat
  triangle, // Üçbucaq
}

// Düşmən modeli
class Enemy {
  final int id;
  final EnemyType type;
  double x; // Grid koordinatları (0-14)
  double y; // Grid koordinatları (0-8)
  double health;
  double maxHealth;
  double speed;
  final Color color;
  int pathIndex; // Yolda hansı nöqtədədir
  int level; // Düşmən səviyyəsi (her wave'de artar)
  double attackDamage; // Toplara verdiği zarar (tipine göre 1-2-3)
  bool isGoingBackward; // Geriye doğru gidiyor mu? (varsayılan: false)
  List<Point<double>>? tempPath; // Geçici yol (yoldan ayrılmış düşmanlar için)
  int tempPathIndex; // Geçici yolda hangi noktada
  Set<String> tempPathVisited; // Geçici yolda geçtiği noktalar (dama dama yok olması için)
  bool isBurning; // Yanırmı? (alov mərmisi üçün)
  double burnEndTime; // Yanma bitmə vaxtı
  double burnDamage; // Yanma zamanı alınan zərər (saniyədə)
  
  Enemy({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.health,
    required this.maxHealth,
    required this.speed,
    required this.color,
    this.pathIndex = 0,
    this.level = 1,
    this.attackDamage = 1.0,
    bool? isGoingBackward,
    this.tempPath,
    this.tempPathIndex = 0,
    Set<String>? tempPathVisited,
    this.isBurning = false,
    this.burnEndTime = 0.0,
    this.burnDamage = 0.0,
  }) : isGoingBackward = isGoingBackward ?? false,
       tempPathVisited = tempPathVisited ?? <String>{};
}

// Qüllə tipləri
enum TowerType {
  basic,   // Sadə qüllə - $50
  rapid,   // Sürətli qüllə - $100
  heavy,   // Ağır qüllə - $200
  ice,     // Buz qülləsi - ⭐1
  flame,   // Alov qülləsi - ⭐2
  laser,   // Lazer qülləsi - ⭐3
  plasma,  // Plazma qülləsi - ⭐4
}

// Qüllə modeli
class Tower {
  final int id;
  int row;
  int col;
  TowerType type;
  double damage;
  double range;
  double fireRate; // Saniyədə atəş sayı
  double lastFireTime;
  Color color;
  int level; // Qüllə səviyyəsi
  double health; // Qüllə canı
  double maxHealth; // Maksimum can
  bool autoHeal; // Avtomatik can yeniləmə
  int autoHealThreshold; // Avtomatik can yeniləmə həddi
  // Hər özellik üçün ayrı upgrade səviyyəsi (0-3 arası)
  int damageUpgradeLevel = 0;
  int fireRateUpgradeLevel = 0;
  int rangeUpgradeLevel = 0;
  // Tower can ve auto heal
  double currentHealth = 100.0;
  bool autoHealEnabled = false;
  // Lüle açıları
  double currentAngle; // Lülenin mevcut açısı
  double targetAngle; // Lülenin hedef açısı
  bool hasRotated; // Lüle düşmana döndü mü?
  
  Tower({
    required this.id,
    required this.row,
    required this.col,
    this.type = TowerType.basic,
    this.damage = 20.0,
    this.range = 2.0,
    this.fireRate = 1.0,
    this.lastFireTime = 0.0,
    this.color = NeonColors.neonGreen,
    this.level = 1,
    this.health = 100.0,
    this.maxHealth = 100.0,
    this.autoHeal = false,
    this.autoHealThreshold = 5,
    this.currentHealth = 100.0,
    this.currentAngle = -pi / 2, // Default: yuxarı istiqamət
    this.targetAngle = -pi / 2,
    this.hasRotated = false,
  });
  
  // Qüllə tiplərinə görə parametrlər
  static Map<String, dynamic> getTowerStats(TowerType type) {
    switch (type) {
      case TowerType.basic:
        return {
          'damage': 20.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 1.0,
          'cost': 50,
          'maxHealth': 100.0,
          'color': const Color(0xFF38BDF8), // Neon mavi (#38bdf8)
        };
      case TowerType.rapid:
        return {
          'damage': 10.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 3.0,
          'cost': 100,
          'maxHealth': 150.0,
          'color': const Color(0xFFFACC15), // Neon sarı (#facc15)
        };
      case TowerType.heavy:
        return {
          'damage': 50.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 0.5,
          'cost': 200,
          'maxHealth': 200.0,
          'color': const Color(0xFFF472B6), // Neon pink (#f472b6)
        };
      case TowerType.ice:
        return {
          'damage': 15.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 1.25,
          'starCost': 1,
          'maxHealth': 120.0,
          'color': const Color(0xFF38BDF8), // Mavi
        };
      case TowerType.flame:
        return {
          'damage': 25.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 1.0,
          'starCost': 2,
          'maxHealth': 350.0,
          'color': const Color(0xFFFACC15), // Sarı
        };
      case TowerType.laser:
        return {
          'damage': 30.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 2.0,
          'starCost': 3,
          'maxHealth': 350.0,
          'color': const Color(0xFFF472B6), // Pink
        };
      case TowerType.plasma:
        return {
          'damage': 60.0,
          'range': 1.5, // 3x3 sahə (9 dama) əhatə edir
          'fireRate': 0.67,
          'starCost': 4,
          'maxHealth': 400.0,
          'color': const Color(0xFFF472B6), // Pink
        };
    }
  }
  
  // Tam dolum maliyetini hesapla (her 50 can için 10 pul)
  static int getFullRepairCost(double maxHealth) {
    return ((maxHealth / 50.0) * 10.0).round();
  }
}

// Mərmi modeli
class Bullet {
  final int id;
  double x;
  double y;
  double targetX;
  double targetY;
  double speed;
  double damage;
  Color color;
  TowerType? towerType; // Hansı topdan atıldı (alov mərmisi üçün)
  
  Bullet({
    required this.id,
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    this.speed = 0.3,
    required this.damage,
    this.color = NeonColors.neonBlue,
    this.towerType,
  });
}

// Oyun ekranı
class NeonDefenderGameScreen extends StatefulWidget {
  const NeonDefenderGameScreen({super.key});

  @override
  State<NeonDefenderGameScreen> createState() => _NeonDefenderGameScreenState();
}

class _NeonDefenderGameScreenState extends State<NeonDefenderGameScreen> {
  // Oyun taxtası
  List<List<CellType>> grid = [];
  
  // Yol nöqtələri (ortadan keçir)
  List<Point<double>> pathPoints = [];
  
  // Oyun obyektləri
  List<Enemy> enemies = [];
  List<Tower> towers = [];
  List<Bullet> bullets = [];
  
  // Geçici yolları takip et (hücre koordinatı -> düşman ID'leri)
  Map<String, Set<int>> tempPathCells = {};
  
  // Oyun parametrləri
  int health = 100;
  int money = 500;
  int score = 0;
  int wave = 1;
  int enemiesKilled = 0;
  int diamonds = 0; // Almazlar
  int stars = 0; // Ulduzlar
  int emeralds = 0; // Zümrüd
  int level = 1; // Oyun səviyyəsi
  
  // Grid konfiqurasiyaları
  List<GridConfig> gridConfigs = [];
  GridConfig? activeGridConfig;
  
  // Yol konfiqurasiyaları
  List<PathConfig> pathConfigs = [];
  PathConfig? activePathConfig;
  
  // Oyun vəziyyəti
  bool isGameRunning = false;
  bool isGamePaused = false;
  Timer? gameTimer;
  double gameTime = 0.0;
  TowerType selectedTowerType = TowerType.basic; // Seçilmiş qüllə tipi
  
  // Device performance detection
  int _targetFPS = 60; // Default: 60fps (güclü telefonlar üçün)
  int _gameLoopInterval = 16; // Default: 16ms (60fps)
  double _deltaTimeMultiplier = 0.016; // Default: 60fps üçün
  bool _performanceDetected = false;
  
  // FPS getter (UI üçün)
  int get targetFPS => _targetFPS;
  
  // Tower selection and context menu
  Tower? _selectedTower;
  bool _showTowerContextMenu = false;
  // Context menu drag state
  Offset _menuDragOffset = Offset.zero;
  bool _isDraggingMenu = false;
  Enemy? _selectedEnemy; // Seçili düşman (tooltip için)
  // Auto heal editing state
  bool _isEditingAutoHeal = false;
  final TextEditingController _autoHealThresholdController = TextEditingController();
  
  // Global auto heal settings (bütün toplar üçün)
  Set<TowerType> _globalAutoHealEnabledTypes = {}; // Hansı top növlərində avto can aktivdir
  int _globalAutoHealThreshold = 5; // Global minimum dəyər
  
  // Yol bağlanır mesajı
  bool _showPathBlockedMessage = false;
  int? _blockedMessageRow;
  int? _blockedMessageCol;
  Timer? _pathBlockedMessageTimer;
  
  // Düşmən ID counter
  int enemyIdCounter = 0;
  int towerIdCounter = 0;
  int bulletIdCounter = 0;
  
  @override
  void initState() {
    super.initState();
    _detectDevicePerformance();
    _initializeAsync();
  }
  
  // Device performance detection - telefon modelinə görə optimallaşdırma
  void _detectDevicePerformance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final context = this.context;
      if (context == null) return;
      
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      final pixelRatio = mediaQuery.devicePixelRatio;
      
      // Device performance tier-ləri
      // Low-end: Poco M3, Redmi Note və s. (30fps)
      // Medium: Orta səviyyəli telefonlar (45fps)
      // High-end: Güclü telefonlar (60fps)
      
      // Pixel ratio və screen size-a görə performance təyin et
      final totalPixels = screenWidth * screenHeight * pixelRatio;
      
      if (totalPixels < 2000000) {
        // Low-end device (Poco M3 və s.)
        _targetFPS = 30;
        _gameLoopInterval = 33;
        _deltaTimeMultiplier = 0.033;
        debugPrint('Device Performance: LOW-END (30fps)');
      } else if (totalPixels < 5000000) {
        // Medium device
        _targetFPS = 45;
        _gameLoopInterval = 22;
        _deltaTimeMultiplier = 0.022;
        debugPrint('Device Performance: MEDIUM (45fps)');
      } else {
        // High-end device
        _targetFPS = 60;
        _gameLoopInterval = 16;
        _deltaTimeMultiplier = 0.016;
        debugPrint('Device Performance: HIGH-END (60fps)');
      }
      
      _performanceDetected = true;
    });
  }
  
  // Asinxron başlatma
  Future<void> _initializeAsync() async {
    try {
      await _loadGameData();
      _initializeGridConfigs();
      await _loadActiveGrid();
      _initializePathConfigs();
      await _loadActivePath();
      // İlk kez oyun başlatıldığında test kaynakları ver (sadece değerler 0 ise)
      await _giveTestResourcesIfNeeded();
      if (mounted) {
        setState(() {
          _initializeGrid();
          _createPath();
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _initializeAsync: $e');
      debugPrint('Stack trace: $stackTrace');
      // Xəta baş verərsə də, ən azı grid və path-i başlat
      if (mounted) {
        setState(() {
          _initializeGrid();
          _createPath();
        });
      }
    }
  }
  
  // Test üçün resurslar ver (sadece ilk kez)
  Future<void> _giveTestResourcesIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInitialized = prefs.getBool('game_initialized') ?? false;
    
    // İlk kez oyun başlatıldığında ve değerler 0 ise test kaynakları ver
    if (!hasInitialized && money == 500 && diamonds == 0 && stars == 0 && emeralds == 0) {
      if (mounted) {
        setState(() {
          money = 10000;
          diamonds = 10000;
          stars = 10000;
          emeralds = 1000;
        });
      }
      await _saveGameData();
      await prefs.setBool('game_initialized', true);
    }
  }
  
  // Oyun məlumatlarını yüklə
  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        money = prefs.getInt('money') ?? 500;
        diamonds = prefs.getInt('diamonds') ?? 0;
        stars = prefs.getInt('stars') ?? 0;
        emeralds = prefs.getInt('emeralds') ?? 0;
        
        // FPS dəyərini yüklə
        final savedFPS = prefs.getInt('targetFPS');
        if (savedFPS != null && (savedFPS == 30 || savedFPS == 60 || savedFPS == 90 || savedFPS == 120)) {
          setFPS(savedFPS, save: false); // Yükləndiyi üçün yenidən saxlama
        }
      });
    }
  }
  
  // Oyun məlumatlarını saxla
  Future<void> _saveGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('money', money);
    await prefs.setInt('diamonds', diamonds);
    await prefs.setInt('stars', stars);
    await prefs.setInt('emeralds', emeralds);
    await prefs.setInt('targetFPS', _targetFPS);
  }
  
  // FPS təyin et və game loop-u yenidən başlat
  void setFPS(int fps, {bool save = true}) {
    if (fps != 30 && fps != 60 && fps != 90 && fps != 120) return;
    
    setState(() {
      _targetFPS = fps;
      
      // FPS-ə görə interval və delta time hesabla
      switch (fps) {
        case 30:
          _gameLoopInterval = 33;
          _deltaTimeMultiplier = 0.033;
          break;
        case 60:
          _gameLoopInterval = 16;
          _deltaTimeMultiplier = 0.016;
          break;
        case 90:
          _gameLoopInterval = 11;
          _deltaTimeMultiplier = 0.011;
          break;
        case 120:
          _gameLoopInterval = 8;
          _deltaTimeMultiplier = 0.008;
          break;
      }
      
      _performanceDetected = true; // Manual seçim olduğu üçün
      
      // Game loop-u yenidən başlat
      if (isGameRunning) {
        _startGameLoop();
      }
    });
    
    if (save) {
      _saveGameData();
    }
    
    debugPrint('FPS changed to: ${_targetFPS}fps (${_gameLoopInterval}ms interval)');
  }
  
  // Grid konfiqurasiyalarını başlat
  void _initializeGridConfigs() {
    gridConfigs = [
      GridConfig(
        id: 'default',
        name: 'Sarı Neon Grid',
        rows: 7,
        cols: 15,
        gridPreviewPath: 'grid1',
        isDefault: true,
        isOwned: true,
        isActive: true,
      ),
      GridConfig(
        id: 'blue',
        name: 'Mavi Neon Grid',
        rows: 7,
        cols: 15,
        emeraldCost: 300,
        gridPreviewPath: 'grid2',
        isOwned: false,
      ),
      GridConfig(
        id: 'pink',
        name: 'Pembe Neon Grid',
        rows: 7,
        cols: 15,
        emeraldCost: 400,
        gridPreviewPath: 'grid3',
        isOwned: false,
      ),
      GridConfig(
        id: 'classic',
        name: 'Klassik Grid',
        rows: 7,
        cols: 15,
        emeraldCost: 200,
        gridPreviewPath: 'default',
        isOwned: false,
      ),
    ];
    activeGridConfig = gridConfigs.firstWhere((g) => g.isActive);
  }
  
  // Aktiv grid-i yüklə
  Future<void> _loadActiveGrid() async {
    final prefs = await SharedPreferences.getInstance();
    final activeGridId = prefs.getString('activeGridId') ?? 'default';
    final ownedGridsJson = prefs.getString('ownedGrids') ?? '[]';
    final ownedGrids = (jsonDecode(ownedGridsJson) as List).map((e) => e as String).toList();
    
    for (var i = 0; i < gridConfigs.length; i++) {
      if (ownedGrids.contains(gridConfigs[i].id)) {
        gridConfigs[i].isOwned = true;
      }
      if (gridConfigs[i].id == activeGridId) {
        gridConfigs[i].isActive = true;
        activeGridConfig = gridConfigs[i];
      } else {
        gridConfigs[i].isActive = false;
      }
    }
  }
  
  // Aktiv grid-i saxla
  Future<void> _saveActiveGrid() async {
    final prefs = await SharedPreferences.getInstance();
    if (activeGridConfig != null) {
      await prefs.setString('activeGridId', activeGridConfig!.id);
    }
  }
  
  // Alınmış gridləri saxla
  Future<void> _saveOwnedGrids() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedGrids = gridConfigs.where((g) => g.isOwned).map((g) => g.id).toList();
    await prefs.setString('ownedGrids', jsonEncode(ownedGrids));
  }
  
  // Yol konfiqurasiyalarını başlat
  void _initializePathConfigs() {
    pathConfigs = [
      PathConfig(
        id: 'default',
        name: 'Klassik Yol',
        pathPreviewPath: 'default',
        isDefault: true,
        isOwned: true,
        isActive: true,
      ),
      PathConfig(
        id: 'path1',
        name: 'Sarı Neon Yol',
        emeraldCost: 250,
        pathPreviewPath: 'path1',
        isOwned: false,
      ),
      PathConfig(
        id: 'path2',
        name: 'Mavi Neon Yol',
        emeraldCost: 350,
        pathPreviewPath: 'path2',
        isOwned: false,
      ),
      PathConfig(
        id: 'path3',
        name: 'Pembe Neon Yol',
        emeraldCost: 450,
        pathPreviewPath: 'path3',
        isOwned: false,
      ),
    ];
    // activePathConfig'i güvenli şekilde ayarla
    try {
      activePathConfig = pathConfigs.firstWhere((p) => p.isActive);
    } catch (e) {
      // Eğer aktif yol yoksa, default'u aktif et
      if (pathConfigs.isNotEmpty) {
        pathConfigs[0].isActive = true;
        activePathConfig = pathConfigs[0];
      }
    }
  }
  
  // Aktiv yolu yüklə
  Future<void> _loadActivePath() async {
    final prefs = await SharedPreferences.getInstance();
    final activePathId = prefs.getString('activePathId') ?? 'default';
    final ownedPathsJson = prefs.getString('ownedPaths') ?? '[]';
    final ownedPaths = (jsonDecode(ownedPathsJson) as List).map((e) => e as String).toList();
    
    for (var i = 0; i < pathConfigs.length; i++) {
      if (ownedPaths.contains(pathConfigs[i].id)) {
        pathConfigs[i].isOwned = true;
      }
      if (pathConfigs[i].id == activePathId) {
        pathConfigs[i].isActive = true;
        activePathConfig = pathConfigs[i];
      } else {
        pathConfigs[i].isActive = false;
      }
    }
  }
  
  // Aktiv yolu saxla
  Future<void> _saveActivePath() async {
    final prefs = await SharedPreferences.getInstance();
    if (activePathConfig != null) {
      await prefs.setString('activePathId', activePathConfig!.id);
    }
  }
  
  // Alınmış yolları saxla
  Future<void> _saveOwnedPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final ownedPaths = pathConfigs.where((p) => p.isOwned).map((p) => p.id).toList();
    await prefs.setString('ownedPaths', jsonEncode(ownedPaths));
  }
  
  // Yol al
  void _buyPath(PathConfig config) {
    if (emeralds >= config.emeraldCost) {
      setState(() {
        emeralds -= config.emeraldCost;
        final index = pathConfigs.indexWhere((p) => p.id == config.id);
        if (index != -1) {
          pathConfigs[index].isOwned = true;
        }
      });
      _saveGameData();
      _saveOwnedPaths();
    }
  }
  
  // Yolu aktiv et (qalıcı)
  void _activatePath(PathConfig config) {
    setState(() {
      // Bütün yolları deaktiv et
      for (var i = 0; i < pathConfigs.length; i++) {
        pathConfigs[i].isActive = false;
      }
      
      // Yeni yolu aktiv et
      final index = pathConfigs.indexWhere((p) => p.id == config.id);
      if (index != -1) {
        pathConfigs[index].isActive = true;
        activePathConfig = pathConfigs[index];
      }
      
      // Yalnız görünüş dəyişsin
    });
    _saveActivePath();
    _saveOwnedPaths();
  }
  
  // Grid al
  void _buyGrid(GridConfig config) {
    if (emeralds >= config.emeraldCost) {
      setState(() {
        emeralds -= config.emeraldCost;
        final index = gridConfigs.indexWhere((g) => g.id == config.id);
        if (index != -1) {
          gridConfigs[index].isOwned = true;
        }
      });
      _saveGameData();
      _saveOwnedGrids();
    }
  }
  
  // Grid preview (qalıcı deyil)
  GridConfig? previewGridConfig;
  GridConfig? originalGridConfig; // Mağaza açılanda aktiv grid-i saxla
  
  void _previewGrid(GridConfig config) {
    setState(() {
      // İlk dəfə preview ediləndə aktiv grid-i saxla
      if (previewGridConfig == null) {
        originalGridConfig = activeGridConfig;
      }
      previewGridConfig = config;
      // Preview üçün yalnız görünüşü dəyiş (ölçüləri dəyişmə)
      activeGridConfig = config;
      // Grid ölçüləri dəyişməsin, yalnız görünüş dəyişsin
    });
  }
  
  // Grid-i aktiv et (qalıcı)
  void _activateGrid(GridConfig config) {
    setState(() {
      // Bütün gridləri deaktiv et
      for (var i = 0; i < gridConfigs.length; i++) {
        gridConfigs[i].isActive = false;
      }
      
      // Yeni grid-i aktiv et
      final index = gridConfigs.indexWhere((g) => g.id == config.id);
      if (index != -1) {
        gridConfigs[index].isActive = true;
        activeGridConfig = gridConfigs[index];
        previewGridConfig = null; // Preview-i sil
      }
      
      // Grid ölçüləri dəyişməsin, yalnız görünüş dəyişsin
      // Oyun taxtası yenilənməsi üçün setState kifayətdir
      // _restartGame() çağırılmayacaq - yalnız görünüş dəyişir
    });
    _saveActiveGrid();
    _saveOwnedGrids();
  }
  
  // Mağaza bağlananda preview-i geri qaytar
  void _restoreGridFromPreview() {
    if (previewGridConfig != null && originalGridConfig != null) {
      setState(() {
        // Köhnə aktiv grid-ə qayıt
        activeGridConfig = originalGridConfig;
        previewGridConfig = null;
        originalGridConfig = null;
        _initializeGrid();
        _createPath();
      });
    }
  }
  
  // Oyunu yenidən başlat
  void _restartGame() {
    setState(() {
      isGameRunning = false;
      isGamePaused = false;
      health = 100;
      score = 0;
      wave = 1;
      enemiesKilled = 0;
      enemies.clear();
      towers.clear();
      bullets.clear();
      _initializeGrid();
      _createPath();
    });
    gameTimer?.cancel();
    // Oyun verilerini kaydet (money, diamonds, stars, emeralds korunmalı)
    _saveGameData();
  }
  
  // Grid-i başlat
  void _initializeGrid() {
    final rows = activeGridConfig?.rows ?? gridRows;
    final cols = activeGridConfig?.cols ?? gridCols;
    grid = List.generate(
      rows,
      (row) => List.generate(cols, (col) => CellType.empty),
    );
  }
  
  // Yol yarat - düz xətlə ortadan keçir (1-ci sütundan axırıncı sütuna)
  void _createPath() {
    pathPoints = [];
    
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    
    // Orta sətir hesabla (həmişə ortada)
    int middleRow = rows ~/ 2;
    
    // Düz xətlə 1-ci sütundan axırıncı sütuna (ortadan keçir)
    for (int col = 0; col < cols; col++) {
      if (grid[middleRow][col] != CellType.tower) {
        pathPoints.add(Point(col.toDouble(), middleRow.toDouble()));
        grid[middleRow][col] = CellType.path;
      }
    }
  }
  
  // Yolu yenidən hesabla - qüllələri nəzərə alaraq
  void _recalculatePath() {
    // Köhnə yolu saxla (yol tapılmadıqda geri qaytarmaq üçün)
    final oldPathPoints = List<Point<double>>.from(pathPoints);
    
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    
    // Köhnə yolu sil
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (grid[row][col] == CellType.path) {
          grid[row][col] = CellType.empty;
        }
      }
    }
    
    // Yeni yolu hesabla (A* pathfinding)
    pathPoints = _findPathToCastle();
    
    // Əgər yol tapılmadısa, köhnə yolu geri qaytar
    if (pathPoints.isEmpty) {
      pathPoints = oldPathPoints;
      // Köhnə yolu grid-ə çək
      for (var point in pathPoints) {
        int row = point.y.toInt();
        int col = point.x.toInt();
        if (row >= 0 && row < rows && col >= 0 && col < cols) {
          if (grid[row][col] != CellType.tower) {
            grid[row][col] = CellType.path;
          }
        }
      }
      return;
    }
    
    // Yolu grid-ə çək
    for (var point in pathPoints) {
      int row = point.y.toInt();
      int col = point.x.toInt();
      if (row >= 0 && row < rows && col >= 0 && col < cols) {
        if (grid[row][col] != CellType.tower) {
          grid[row][col] = CellType.path;
        }
      }
    }
    
    // Düşmanları yola taşıma - düşmanlar kendileri yola doğru hareket edecek
  }
  
  // Qalaya doğru yol tap (Optimized BFS pathfinding)
  List<Point<double>> _findPathToCastle() {
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    
    // Başlanğıc nöqtə (sol tərəf, ortadan)
    int startX = 0;
    int startY = rows ~/ 2; // Orta sətir
    
    // Qala mövqeyi (sağ tərəf, orta sətirin sonunda)
    int castleX = cols - 1;
    int castleY = rows ~/ 2; // Orta sətir
    
    // Optimized BFS pathfinding
    List<Point<double>> path = [];
    List<List<bool>> visited = List.generate(
      rows,
      (row) => List.generate(cols, (col) => false),
    );
    
    // Queue'yu optimize etmek için List yerine daha hızlı bir yapı kullan
    // removeAt(0) yerine queue başını takip edelim
    int queueStart = 0;
    List<Point<int>> queue = [Point(startX, startY)];
    Map<Point<int>, Point<int>> parent = {};
    visited[startY][startX] = true;
    
    while (queueStart < queue.length) {
      final current = queue[queueStart++];
      
      if (current.x == castleX && current.y == castleY) {
        // Yolu qur
        Point<int>? node = current;
        while (node != null) {
          path.insert(0, Point(node.x.toDouble(), node.y.toDouble()));
          node = parent[node];
        }
        break;
      }
      
      // Qonşu cell-ləri yoxla - hedefe yakın olanları önce kontrol et
      final dxToCastle = castleX - current.x;
      final dyToCastle = castleY - current.y;
      
      // Hedefe yakın olan yönleri önce kontrol et (heuristic - daha kısa yol bulmak için)
      List<Point<int>> neighbors = [];
      
      // Hedefe doğru olan yönleri önce ekle
      if (dxToCastle.abs() >= dyToCastle.abs()) {
        // Yatay yönde daha fazla ilerleme var
        if (dxToCastle > 0) {
          neighbors.add(Point(current.x + 1, current.y)); // Sağa
        } else {
          neighbors.add(Point(current.x - 1, current.y)); // Sola
        }
        // Dikey yönleri de ekle
        neighbors.add(Point(current.x, current.y + 1)); // Aşağı
        neighbors.add(Point(current.x, current.y - 1)); // Yuxarı
        // Diğer yatay yönü ekle
        if (dxToCastle > 0) {
          neighbors.add(Point(current.x - 1, current.y)); // Sola
        } else {
          neighbors.add(Point(current.x + 1, current.y)); // Sağa
        }
      } else {
        // Dikey yönde daha fazla ilerleme var
        if (dyToCastle > 0) {
          neighbors.add(Point(current.x, current.y + 1)); // Aşağı
        } else {
          neighbors.add(Point(current.x, current.y - 1)); // Yuxarı
        }
        // Yatay yönleri de ekle
        neighbors.add(Point(current.x + 1, current.y)); // Sağa
        neighbors.add(Point(current.x - 1, current.y)); // Sola
        // Diğer dikey yönü ekle
        if (dyToCastle > 0) {
          neighbors.add(Point(current.x, current.y - 1)); // Yuxarı
        } else {
          neighbors.add(Point(current.x, current.y + 1)); // Aşağı
        }
      }
      
      for (var neighbor in neighbors) {
        if (neighbor.x >= 0 && neighbor.x < cols &&
            neighbor.y >= 0 && neighbor.y < rows &&
            !visited[neighbor.y][neighbor.x] &&
            grid[neighbor.y][neighbor.x] != CellType.tower) {
          // Empty cell'lere de yol bulabilir (yolun boşluğa doğru bükülmesi için)
          visited[neighbor.y][neighbor.x] = true;
          parent[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }
    
    // Əgər yol tapılmadısa, boş list qaytar
    return path;
  }
  
  // Oyunu başlat
  void _startGame() {
    setState(() {
      isGameRunning = true;
      isGamePaused = false;
      health = 100;
      // money, diamonds, stars, emeralds korunmalı - gift kod ödülleri kaybolmamalı
      score = 0;
      wave = 1;
      enemiesKilled = 0;
      level = 1;
      // selectedTowerType korunmalı - kullanıcının seçtiği tower tipi kaybolmamalı
      // selectedTowerType = TowerType.basic; // Kaldırıldı - kullanıcının seçimi korunur
      enemies.clear();
      // towers.clear(); // Kaldırıldı - tahtaya dizilen toplar korunmalı
      bullets.clear();
      gameTime = 0.0;
      
      // Tüm topların lastFireTime'ını sıfırla (oyun başladığında hemen ateş edebilsinler)
      for (var tower in towers) {
        final fireInterval = 1.0 / tower.fireRate;
        tower.lastFireTime = -fireInterval; // Mənfi dəyər ver ki, ilk mərmi dərhal atılsın
      }
    });
    
    _startWave();
    _startGameLoop();
  }
  
  // Dalğa başlat
  void _startWave() {
    // Hər dalğada daha çox düşmən
    int enemyCount = 5 + wave * 2;
    
    for (int i = 0; i < enemyCount; i++) {
      Future.delayed(Duration(milliseconds: i * 1000), () {
        if (mounted && isGameRunning) {
          _spawnEnemy();
        }
      });
    }
  }
  
  // Düşmən yarat
  void _spawnEnemy() {
    if (pathPoints.isEmpty) return;
    
    final random = Random();
    final enemyType = random.nextBool() ? EnemyType.square : EnemyType.triangle;
    
    // Wave'e göre düşman seviyesi ve güçlenme
    final enemyLevel = wave; // Her wave'de level artar
    final levelMultiplier = 1.0 + (enemyLevel - 1) * 0.2; // Her level %20 güçlenme
    
    Color enemyColor;
    double baseHealth;
    double baseSpeed;
    double attackDamage;
    
    if (enemyType == EnemyType.square) {
      enemyColor = NeonColors.neonRed;
      baseHealth = 50.0;
      baseSpeed = 0.015; // Düşman hızı azaltıldı (0.02 -> 0.015)
      attackDamage = 1.0; // Square düşman 1 can zarar verir
    } else {
      enemyColor = NeonColors.neonOrange;
      baseHealth = 30.0;
      baseSpeed = 0.02; // Düşman hızı azaltıldı (0.03 -> 0.02)
      attackDamage = 2.0; // Triangle düşman 2 can zarar verir
    }
    
    // Wave'e göre güçlenme
    final health = baseHealth * levelMultiplier;
    final speed = baseSpeed * (1.0 + (enemyLevel - 1) * 0.1); // Hız da artar ama daha az
    
    final startPoint = pathPoints[0];
    final enemy = Enemy(
      id: enemyIdCounter++,
      type: enemyType,
      x: startPoint.x,
      y: startPoint.y,
      health: health,
      maxHealth: health,
      speed: speed,
      color: enemyColor,
      pathIndex: 0,
      level: enemyLevel,
      attackDamage: attackDamage,
      isGoingBackward: false,
    );
    
    setState(() {
      enemies.add(enemy);
    });
  }
  
  // Oyun döngüsü - device performance-ə görə dinamik optimallaşdırma
  void _startGameLoop() {
    gameTimer?.cancel();
    
    // Performance detect olunmayıbsa, default dəyərləri istifadə et
    if (!_performanceDetected) {
      _targetFPS = 30; // Təhlükəsiz default: 30fps
      _gameLoopInterval = 33;
      _deltaTimeMultiplier = 0.033;
    }
    
    debugPrint('Starting game loop: ${_targetFPS}fps (${_gameLoopInterval}ms interval)');
    
    gameTimer = Timer.periodic(Duration(milliseconds: _gameLoopInterval), (timer) {
      if (!isGameRunning || isGamePaused || !mounted) return;
      
      try {
        setState(() {
          final deltaTime = _deltaTimeMultiplier; // Device performance-ə görə
          gameTime += deltaTime;
          _updateEnemies();
          _updateTowers();
          _updateBullets();
          _updateTowerAutoHeal();
          _checkGameOver();
        });
      } catch (e, stackTrace) {
        // Xəta baş verərsə, log et və davam et
        debugPrint('Game loop error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    });
  }
  
  // Qüllələrin avtomatik can yeniləməsi
  void _updateTowerAutoHeal() {
    for (var tower in towers) {
      if (tower.autoHeal && tower.currentHealth < tower.maxHealth) {
        // Minimum değere ulaştığında para karşılığında canı yenile
        if (tower.currentHealth <= tower.autoHealThreshold) {
          final repairCost = Tower.getFullRepairCost(tower.maxHealth);
          if (money >= repairCost) {
            setState(() {
              tower.currentHealth = tower.maxHealth;
              money -= repairCost;
              // Rengi orijinal haline qaytar
              final stats = Tower.getTowerStats(tower.type);
              tower.color = stats['color'] as Color;
            });
          }
        }
      }
    }
  }
  
  // Düşmənləri yenilə
  void _updateEnemies() {
    for (var enemy in List.from(enemies)) {
      // Yanma effektini yoxla
      if (enemy.isBurning && gameTime < enemy.burnEndTime) {
        // Yanma davam edir - can azalt
        final burnDamageThisFrame = enemy.burnDamage * _deltaTimeMultiplier;
        if (!burnDamageThisFrame.isNaN && !burnDamageThisFrame.isInfinite && burnDamageThisFrame > 0) {
          enemy.health -= burnDamageThisFrame;
          if (enemy.health < 0) {
            enemy.health = 0.0;
          }
        }
        if (enemy.health <= 0) {
          setState(() {
            enemies.remove(enemy);
            enemiesKilled++;
            score += 10;
            money += 5;
            // Bəzən ulduz və ya almaz ver
            final random = Random();
            if (random.nextDouble() < 0.1) {
              stars += 1;
            }
            if (random.nextDouble() < 0.05) {
              diamonds += 1;
            }
          });
          continue;
        }
      } else if (enemy.isBurning && gameTime >= enemy.burnEndTime) {
        // Yanma bitdi
        enemy.isBurning = false;
        enemy.burnEndTime = 0.0;
        enemy.burnDamage = 0.0;
      }
      
      // Geriye giden düşmanlar için kontrol yok, sadece ileriye gidenler için
      if (!enemy.isGoingBackward && enemy.pathIndex >= pathPoints.length - 1 && enemy.tempPath == null) {
        // Yolu bitirdi - sağlamlıq azalır
        setState(() {
          health -= 10;
          enemies.remove(enemy);
        });
        continue;
      }
      
      // Düşman toplara saldırıyor mu kontrol et
      for (var tower in List.from(towers)) {
        final dx = enemy.x - tower.col;
        final dy = enemy.y - tower.row;
        final distance = sqrt(dx * dx + dy * dy);
        
        // Eğer düşman topun yanındaysa (1 hücre mesafede), saldır
        if (distance <= 1.0) {
          // Topa zarar ver
          tower.currentHealth -= enemy.attackDamage.toDouble();
          if (tower.currentHealth < 0) {
            tower.currentHealth = 0.0;
          }
          
          // Eğer topun canı 0'a düştüyse, topu yok et
          if (tower.currentHealth <= 0) {
            setState(() {
              towers.remove(tower);
              grid[tower.row][tower.col] = CellType.empty;
              _recalculatePath();
            });
          }
        }
      }
      
      // Düşmanın yola yakın olup olmadığını kontrol et
      bool isOnPath = _isEnemyOnPath(enemy);
      
      // Eğer düşman yoldan uzaksa ve geçici yolu yoksa, geçici yol oluştur
      if (!isOnPath && enemy.tempPath == null) {
        enemy.tempPath = _createTempPathToMainPath(enemy);
        enemy.tempPathIndex = 0;
        if (enemy.tempPath == null || enemy.tempPath!.isEmpty) {
          // Geçici yol oluşturulamadı, düşmanı yok et
          setState(() {
            enemies.remove(enemy);
          });
          continue;
        }
        // Geçici yolu tempPathCells'e ekle
        _addTempPathToCells(enemy);
      }
      
      // Düşman geçici yolda ilerlerken geçtiği noktaları işaretle
      if (enemy.tempPath != null && enemy.tempPathIndex < enemy.tempPath!.length) {
        // Eğer tempPathVisited null ise, başlat
        if (enemy.tempPathVisited == null) {
          enemy.tempPathVisited = <String>{};
        }
        final currentPoint = enemy.tempPath![enemy.tempPathIndex];
        final cellKey = '${currentPoint.x.round()},${currentPoint.y.round()}';
        enemy.tempPathVisited.add(cellKey);
      }
      
      // Geçici yolu takip et veya ana yolu takip et
      Point<double> targetPoint;
      if (enemy.tempPath != null && enemy.tempPathIndex < enemy.tempPath!.length) {
        // Geçici yolu takip et
        if (enemy.tempPathIndex >= enemy.tempPath!.length - 1) {
          // Geçici yolun sonuna ulaştı, ana yola geç
          _removeTempPathFromCells(enemy);
          enemy.tempPath = null;
          enemy.tempPathIndex = 0;
          enemy.tempPathVisited.clear();
          // Ana yola en yakın noktayı bul
          int closestIndex = _findClosestPathPoint(enemy);
          enemy.pathIndex = closestIndex;
          if (enemy.pathIndex >= pathPoints.length - 1) {
            continue;
          }
          targetPoint = pathPoints[enemy.pathIndex + 1];
        } else {
          // Geçici yolda ilerle
          targetPoint = enemy.tempPath![enemy.tempPathIndex + 1];
        }
      } else {
        // Ana yolu takip et
        if (enemy.isGoingBackward) {
          // Geriye doğru git
          if (enemy.pathIndex <= 0) {
            // Başlangıca çatdı, artık ileriye git
            enemy.isGoingBackward = false;
            enemy.pathIndex = 0;
            targetPoint = pathPoints[0];
          } else {
            // Bir önceki noktaya git
            targetPoint = pathPoints[enemy.pathIndex - 1];
          }
        } else {
          // İleriye doğru git
          if (enemy.pathIndex >= pathPoints.length - 1) {
            // Yolu bitirdi
            continue;
          }
          targetPoint = pathPoints[enemy.pathIndex + 1];
        }
      }
      
      final dx = targetPoint.x - enemy.x;
      final dy = targetPoint.y - enemy.y;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < 0.1) {
        // Hedef noktaya çatdı
        if (enemy.tempPath != null && enemy.tempPathIndex < enemy.tempPath!.length - 1) {
          // Geçici yolda ilerle
          enemy.tempPathIndex++;
        } else if (enemy.isGoingBackward) {
          // Geriye gidiyor - pathIndex'i azalt
          enemy.pathIndex--;
          if (enemy.pathIndex < 0) {
            enemy.pathIndex = 0;
            enemy.isGoingBackward = false;
          }
        } else {
          // İleriye gidiyor - pathIndex'i artır
          enemy.pathIndex++;
          if (enemy.pathIndex >= pathPoints.length) {
            enemy.pathIndex = pathPoints.length - 1;
          }
        }
        
        // Pozisyonu güncelle
        if (enemy.tempPath != null && enemy.tempPathIndex < enemy.tempPath!.length) {
          enemy.x = enemy.tempPath![enemy.tempPathIndex].x;
          enemy.y = enemy.tempPath![enemy.tempPathIndex].y;
        } else if (enemy.pathIndex >= 0 && enemy.pathIndex < pathPoints.length) {
          enemy.x = pathPoints[enemy.pathIndex].x;
          enemy.y = pathPoints[enemy.pathIndex].y;
        }
      } else {
        // Hərəkət et
        final moveDistance = enemy.speed;
        enemy.x += (dx / distance) * moveDistance;
        enemy.y += (dy / distance) * moveDistance;
      }
    }
  }
  
  // Düşmanın yola yakın olup olmadığını kontrol et
  bool _isEnemyOnPath(Enemy enemy) {
    if (pathPoints.isEmpty) return false;
    
    for (var point in pathPoints) {
      final dx = enemy.x - point.x;
      final dy = enemy.y - point.y;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance < 0.5) {
        return true;
      }
    }
    return false;
  }
  
  // Ana yola en yakın noktayı bul (kaleye doğru gitmek için)
  int _findClosestPathPoint(Enemy enemy) {
    if (pathPoints.isEmpty) return 0;
    
    // Başlangıç ve kalenin pozisyonunu al
    final startPoint = pathPoints[0];
    final castlePoint = pathPoints[pathPoints.length - 1];
    
    // Düşmanın başlangıç ve kaleye mesafesini hesapla
    final dxToStart = enemy.x - startPoint.x;
    final dyToStart = enemy.y - startPoint.y;
    final distanceToStart = sqrt(dxToStart * dxToStart + dyToStart * dyToStart);
    
    final dxToCastle = enemy.x - castlePoint.x;
    final dyToCastle = enemy.y - castlePoint.y;
    final distanceToCastle = sqrt(dxToCastle * dxToCastle + dyToCastle * dyToCastle);
    
    // En yakın noktayı bul
    int closestIndex = 0;
    double closestDistance = double.infinity;
    
    for (int i = 0; i < pathPoints.length; i++) {
      final point = pathPoints[i];
      final dx = enemy.x - point.x;
      final dy = enemy.y - point.y;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }
    
    // Düşmanın pozisyonuna göre kaleye doğru olan noktayı tercih et
    // Eğer düşman başlangıca yakınsa, başlangıçtan başla
    // Eğer düşman kaleye yakınsa, kaleye doğru devam et
    if (distanceToStart < distanceToCastle) {
      // Başlangıca yakın - başlangıçtan başla
      // En yakın nokta başlangıca yakınsa, onu kullan
      if (closestIndex <= pathPoints.length / 2) {
        return closestIndex;
      } else {
        // En yakın nokta kaleye yakın, daha geri bir nokta bul
        for (int i = closestIndex - 1; i >= 0; i--) {
          final point = pathPoints[i];
          final dx = enemy.x - point.x;
          final dy = enemy.y - point.y;
          final distance = sqrt(dx * dx + dy * dy);
          
          // Eğer bu nokta da yakınsa, onu kullan
          if (distance < closestDistance * 1.5) {
            return i;
          }
        }
      }
    } else {
      // Kaleye yakın - kaleye doğru devam et
      // En yakın nokta kaleye yakınsa, onu kullan
      if (closestIndex >= pathPoints.length / 2) {
        return closestIndex;
      } else {
        // En yakın nokta başlangıca yakın, daha ileri bir nokta bul
        for (int i = closestIndex + 1; i < pathPoints.length; i++) {
          final point = pathPoints[i];
          final dx = enemy.x - point.x;
          final dy = enemy.y - point.y;
          final distance = sqrt(dx * dx + dy * dy);
          
          // Eğer bu nokta da yakınsa, onu kullan
          if (distance < closestDistance * 1.5) {
            return i;
          }
        }
      }
    }
    
    return closestIndex;
  }
  
  // Düşman için geçici yol oluştur (ana yola en kısa yol)
  List<Point<double>>? _createTempPathToMainPath(Enemy enemy) {
    if (pathPoints.isEmpty) return null;
    
    // Ana yola en yakın noktayı bul
    int closestPathIndex = _findClosestPathPoint(enemy);
    final targetPoint = pathPoints[closestPathIndex];
    
    // Düşmanın pozisyonundan hedef noktaya A* pathfinding ile yol bul
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    
    int startX = enemy.x.round().clamp(0, cols - 1);
    int startY = enemy.y.round().clamp(0, rows - 1);
    int endX = targetPoint.x.round().clamp(0, cols - 1);
    int endY = targetPoint.y.round().clamp(0, rows - 1);
    
    // A* pathfinding
    List<Point<double>> path = [];
    List<List<bool>> visited = List.generate(
      rows,
      (row) => List.generate(cols, (col) => false),
    );
    
    int queueStart = 0;
    List<Point<int>> queue = [Point(startX, startY)];
    Map<Point<int>, Point<int>> parent = {};
    visited[startY][startX] = true;
    
    while (queueStart < queue.length) {
      final current = queue[queueStart++];
      
      if (current.x == endX && current.y == endY) {
        // Yolu qur
        Point<int>? node = current;
        while (node != null) {
          path.insert(0, Point(node.x.toDouble(), node.y.toDouble()));
          node = parent[node];
        }
        break;
      }
      
      // Qonşu cell-ləri yoxla
      final neighbors = [
        Point(current.x + 1, current.y),
        Point(current.x - 1, current.y),
        Point(current.x, current.y + 1),
        Point(current.x, current.y - 1),
      ];
      
      for (var neighbor in neighbors) {
        if (neighbor.x >= 0 && neighbor.x < cols &&
            neighbor.y >= 0 && neighbor.y < rows &&
            !visited[neighbor.y][neighbor.x] &&
            grid[neighbor.y][neighbor.x] != CellType.tower) {
          // Topların üzerinden geçemez
          visited[neighbor.y][neighbor.x] = true;
          parent[neighbor] = current;
          queue.add(neighbor);
        }
      }
    }
    
    return path.isEmpty ? null : path;
  }
  
  // Geçici yolu tempPathCells'e ekle
  void _addTempPathToCells(Enemy enemy) {
    if (enemy.tempPath == null) return;
    
    for (var point in enemy.tempPath!) {
      final cellKey = '${point.x.round()},${point.y.round()}';
      tempPathCells.putIfAbsent(cellKey, () => <int>{}).add(enemy.id);
    }
  }
  
  // Geçici yolu tempPathCells'den kaldır
  void _removeTempPathFromCells(Enemy enemy) {
    if (enemy.tempPath == null) return;
    
    for (var point in enemy.tempPath!) {
      final cellKey = '${point.x.round()},${point.y.round()}';
      final enemySet = tempPathCells[cellKey];
      if (enemySet != null) {
        enemySet.remove(enemy.id);
        if (enemySet.isEmpty) {
          tempPathCells.remove(cellKey);
        }
      }
    }
  }
  
  // Hücrede geçici yol var mı kontrol et (dama dama yok olması için)
  bool _isTempPathCell(int row, int col) {
    final cellKey = '$col,$row';
    final enemySet = tempPathCells[cellKey];
    if (enemySet == null || enemySet.isEmpty) return false;
    
    // Eğer tüm düşmanlar bu noktayı geçtiyse, geçici yol yok olur
    bool hasUnvisited = false;
    Set<int> toRemove = {};
    
    for (var enemyId in enemySet) {
      final enemy = enemies.firstWhere(
        (e) => e.id == enemyId,
        orElse: () => Enemy(
          id: -1,
          type: EnemyType.square,
          x: 0,
          y: 0,
          health: 0,
          maxHealth: 0,
          speed: 0,
          color: Colors.red,
        ),
      );
      
      // Düşman yoksa veya geçici yolu yoksa, listeden kaldır
      if (enemy.id == -1 || enemy.tempPath == null) {
        toRemove.add(enemyId);
        continue;
      }
      
      // Eğer tempPathVisited null ise, başlat
      if (enemy.tempPathVisited == null) {
        enemy.tempPathVisited = <String>{};
      }
      
      final pointKey = '$col,$row';
      if (!enemy.tempPathVisited!.contains(pointKey)) {
        hasUnvisited = true; // Henüz geçilmemiş, geçici yol var
      }
    }
    
    // Geçersiz düşmanları kaldır
    for (var enemyId in toRemove) {
      enemySet.remove(enemyId);
    }
    
    // Eğer tüm düşmanlar geçtiyse veya liste boşsa, geçici yol yok olur
    if (!hasUnvisited || enemySet.isEmpty) {
      tempPathCells.remove(cellKey);
      return false;
    }
    
    return true;
  }
  
  // Qüllələri yenilə
  void _updateTowers() {
    for (var tower in towers) {
      // Ən yaxın düşməni tap
      Enemy? nearestEnemy;
      double nearestDistance = double.infinity;
      
      for (var enemy in List.from(enemies)) {
        final dx = enemy.x - tower.col;
        final dy = enemy.y - tower.row;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance <= tower.range && distance < nearestDistance) {
          nearestEnemy = enemy;
          nearestDistance = distance;
        }
      }
      
      // Eğer menzilde düşman varsa, lüleyi düşmana doğru döndür
      if (nearestEnemy != null) {
        final dx = nearestEnemy.x - tower.col;
        final dy = nearestEnemy.y - tower.row;
        tower.targetAngle = atan2(dy, dx);
        
        // Lüle dönüşü (yumuşak geçiş)
        final angleDiff = tower.targetAngle - tower.currentAngle;
        // Açı farkını -pi ile pi arasına normalize et
        double normalizedDiff = angleDiff;
        while (normalizedDiff > pi) normalizedDiff -= 2 * pi;
        while (normalizedDiff < -pi) normalizedDiff += 2 * pi;
        
        // Lüle dönüş hızı (radyan/saniye)
        const rotationSpeed = 3.0; // 3 radyan/saniye
        final rotationStep = rotationSpeed * 0.016; // Delta time ile çarp
        
        if (normalizedDiff.abs() > rotationStep) {
          // Lüle henüz hedefe dönmedi
          tower.currentAngle += normalizedDiff > 0 ? rotationStep : -rotationStep;
          tower.hasRotated = false;
        } else {
          // Lüle hedefe döndü
          tower.currentAngle = tower.targetAngle;
          tower.hasRotated = true;
        }
        
        // Lüle döndükten sonra ateş et
        // hasRotated kontrolünü kaldırdık - lüle döndükten sonra veya dönmüşse ateş et
        if (tower.hasRotated || (tower.currentAngle - tower.targetAngle).abs() < 0.1) {
          final timeSinceLastFire = gameTime - tower.lastFireTime;
          final fireInterval = 1.0 / tower.fireRate;
          
          if (timeSinceLastFire >= fireInterval) {
            tower.lastFireTime = gameTime;
            _fireBullet(tower, nearestEnemy);
          }
        }
      } else {
        // Menzilde düşman yok - yolda düşman var mı kontrol et
        Enemy? pathEnemy;
        double pathEnemyDistance = double.infinity;
        
        // Yolda düşman var mı kontrol et (pathPoints üzerinde)
        for (var enemy in List.from(enemies)) {
          // Düşmanın yol üzerinde olup olmadığını kontrol et
          for (var pathPoint in pathPoints) {
            final dx = enemy.x - pathPoint.x;
            final dy = enemy.y - pathPoint.y;
            final distance = sqrt(dx * dx + dy * dy);
            
            // Eğer düşman yola yakınsa ve menzile girebilecekse
            if (distance < 0.5) {
              final towerToEnemyDx = enemy.x - tower.col;
              final towerToEnemyDy = enemy.y - tower.row;
              final towerToEnemyDistance = sqrt(towerToEnemyDx * towerToEnemyDx + towerToEnemyDy * towerToEnemyDy);
              
              // Düşman menzile girebilecek mi? (gelecek pozisyonu tahmin et)
              if (towerToEnemyDistance <= tower.range * 1.5 && towerToEnemyDistance < pathEnemyDistance) {
                pathEnemy = enemy;
                pathEnemyDistance = towerToEnemyDistance;
              }
            }
          }
        }
        
        if (pathEnemy != null) {
          // Yolda düşman var - düşmanın geldiği pozisyona doğru dön
          final dx = pathEnemy.x - tower.col;
          final dy = pathEnemy.y - tower.row;
          tower.targetAngle = atan2(dy, dx);
          
          // Lüle dönüşü
          final angleDiff = tower.targetAngle - tower.currentAngle;
          double normalizedDiff = angleDiff;
          while (normalizedDiff > pi) normalizedDiff -= 2 * pi;
          while (normalizedDiff < -pi) normalizedDiff += 2 * pi;
          
          const rotationSpeed = 3.0;
          final rotationStep = rotationSpeed * 0.016;
          
          if (normalizedDiff.abs() > rotationStep) {
            tower.currentAngle += normalizedDiff > 0 ? rotationStep : -rotationStep;
          } else {
            tower.currentAngle = tower.targetAngle;
          }
        } else {
          // Yolda hiç düşman yok - sabit pozisyona geri dön
          tower.targetAngle = -pi / 2; // Yuxarı istiqamət
          
          final angleDiff = tower.targetAngle - tower.currentAngle;
          double normalizedDiff = angleDiff;
          while (normalizedDiff > pi) normalizedDiff -= 2 * pi;
          while (normalizedDiff < -pi) normalizedDiff += 2 * pi;
          
          const rotationSpeed = 3.0;
          final rotationStep = rotationSpeed * 0.016;
          
          if (normalizedDiff.abs() > rotationStep) {
            tower.currentAngle += normalizedDiff > 0 ? rotationStep : -rotationStep;
          } else {
            tower.currentAngle = tower.targetAngle;
          }
          
          tower.hasRotated = false;
        }
      }
    }
  }
  
  // Mərmi at - lülə istiqamətindən
  void _fireBullet(Tower tower, Enemy target) {
    // Lülə istiqaməti hesabla
    final dx = target.x - tower.col;
    final dy = target.y - tower.row;
    final angle = atan2(dy, dx);
    
    // Lülə mövqeyindən başla (qüllənin kənarından)
    const barrelLength = 0.3; // Küçültüldü (0.5 -> 0.3)
    final startX = tower.col + cos(angle) * barrelLength;
    final startY = tower.row + sin(angle) * barrelLength;
    
    final bullet = Bullet(
      id: bulletIdCounter++,
      x: startX,
      y: startY,
      targetX: target.x,
      targetY: target.y,
      damage: tower.damage,
      color: tower.color,
      speed: 4.8, // Mermi hızı 2x artırıldı (2.4 -> 4.8) - düşmanlara daha sürətli çatır
      towerType: tower.type, // Top növü (alov mərmisi üçün)
    );
    
    bullets.add(bullet);
  }
  
  // Mərmiləri yenilə
  void _updateBullets() {
    for (var bullet in List.from(bullets)) {
      final dx = bullet.targetX - bullet.x;
      final dy = bullet.targetY - bullet.y;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < 0.3) {
        // Hədəfə çatdı - düşmanı vur (radius artırıldı: 0.25 -> 0.3)
        _hitEnemy(bullet);
        bullets.remove(bullet);
      } else {
        // Hərəkət et
        final moveDistance = bullet.speed * 0.016; // Delta time ile çarp
        if (distance > 0) {
          bullet.x += (dx / distance) * moveDistance;
          bullet.y += (dy / distance) * moveDistance;
        }
      }
    }
  }
  
  // Düşməni vur
  void _hitEnemy(Bullet bullet) {
    Enemy? hitEnemy;
    double minDistance = 0.5; // Radius artırıldı (0.3 -> 0.5) - mermi hedefi daha kolay vurur
    
    // Önce hedef pozisyonuna yakın düşmanları kontrol et
    for (var enemy in List.from(enemies)) {
      // Merminin hedef pozisyonuna göre kontrol et
      final dx = enemy.x - bullet.targetX;
      final dy = enemy.y - bullet.targetY;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < minDistance) {
        hitEnemy = enemy;
        minDistance = distance;
      }
    }
    
    // Eğer hedef pozisyonunda düşman bulunamadıysa, merminin mevcut pozisyonuna göre kontrol et
    if (hitEnemy == null) {
      for (var enemy in List.from(enemies)) {
        final dx = enemy.x - bullet.x;
        final dy = enemy.y - bullet.y;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance < minDistance) {
          hitEnemy = enemy;
          minDistance = distance;
        }
      }
    }
    
    if (hitEnemy != null) {
      hitEnemy.health -= bullet.damage;
      
      // Alov mərmisi vurduqda yanma effektini aktiv et
      if (bullet.towerType == TowerType.flame) {
        hitEnemy.isBurning = true;
        hitEnemy.burnEndTime = gameTime + 5.0; // 5 saniyə yanacaq
        hitEnemy.burnDamage = bullet.damage * 0.1; // Saniyədə 10% zərər
      }
      
      if (hitEnemy.health <= 0) {
        setState(() {
          enemies.remove(hitEnemy);
          enemiesKilled++;
          score += 10;
          money += 5;
          // Bəzən ulduz və ya almaz ver
          final random = Random();
          if (random.nextDouble() < 0.1) {
            stars += 1;
          }
          if (random.nextDouble() < 0.05) {
            diamonds += 1;
          }
        });
      }
    }
  }
  
  // Oyun bitdi yoxla
  void _checkGameOver() {
    if (health <= 0) {
      _gameOver();
    } else if (enemies.isEmpty && enemiesKilled >= (5 + wave * 2)) {
      // Dalğa bitdi
      setState(() {
        wave++;
        money += 50;
        // Hər 5 dalğadan sonra səviyyə artır
        if (wave % 5 == 0) {
          level++;
        }
      });
      _startWave();
    }
  }
  
  // Oyun bitdi
  void _gameOver() {
    setState(() {
      isGameRunning = false;
    });
    gameTimer?.cancel();
  }
  // Qüllə qoy - yolun üstünə və ya kənarına
  void _placeTower(int row, int col) {
    print('[DEBUG] _placeTower called: row=$row, col=$col');
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : 0;
    print('[DEBUG] Grid size: rows=$rows, cols=$cols');
    if (row < 0 || row >= rows || col < 0 || col >= cols) {
      print('[DEBUG] Invalid coordinates, returning');
      return;
    }
    if (grid[row][col] == CellType.tower) {
      print('[DEBUG] Cell already has a tower, returning');
      return; // Artıq qüllə var
    }
    
    // Geçici yolun üzerine kule yerleştirilemez
    if (_isTempPathCell(row, col)) {
      print('[DEBUG] Cannot place tower on temp path');
      return;
    }
    
    // Başlanğıc və bitiş nöqtələrinə qüllə qoyula bilməz
    final startX = 0;
    final startY = rows ~/ 2; // Orta sətir
    final castleX = cols - 1;
    final castleY = rows ~/ 2; // Orta sətir
    
    if ((col == startX && row == startY) || (col == castleX && row == castleY)) {
      print('[DEBUG] Cannot place tower on start or castle position');
      // Başlanğıc və ya bitiş nöqtəsinə qüllə qoyula bilməz
      return;
    }
    
    final stats = Tower.getTowerStats(selectedTowerType);
    final cost = stats['cost'] as int? ?? 0;
    final starCost = stats['starCost'] as int? ?? 0;
    
    print('[DEBUG] Tower cost: cost=$cost, starCost=$starCost, money=$money, stars=$stars');
    
    // Pul və ya ulduz yoxla
    if (cost > 0 && money < cost) {
      print('[DEBUG] Not enough money, returning');
      return;
    }
    if (starCost > 0 && stars < starCost) {
      print('[DEBUG] Not enough stars, returning');
      return;
    }
    
    // Qülləni müvəqqəti olaraq qoy və yolu yoxla
    final originalCellType = grid[row][col];
    
    // Köhnə yolu müvəqqəti olaraq sil
    final oldPathCells = <Point<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == CellType.path) {
          oldPathCells.add(Point(c, r));
          grid[r][c] = CellType.empty;
        }
      }
    }
    
    // Qülləni müvəqqəti olaraq qoy
    grid[row][col] = CellType.tower;
    
    // Yolu yenidən hesabla və yoxla
    print('[DEBUG] Finding new path to castle...');
    final newPath = _findPathToCastle();
    print('[DEBUG] New path found: ${newPath.length} points');
    
    // Əgər yol tapılmadısa, qülləni və köhnə yolu geri qaytar
    if (newPath.isEmpty) {
      print('[DEBUG] No path found, reverting tower placement');
      grid[row][col] = originalCellType;
      // Köhnə yolu geri qaytar
      for (var point in oldPathCells) {
        grid[point.y][point.x] = CellType.path;
      }
      // İstifadəçiyə bildir - yol bağlanır, qüllə qoyula bilməz
      if (mounted) {
        setState(() {
          _showPathBlockedMessage = true;
          _blockedMessageRow = row;
          _blockedMessageCol = col;
        });
        
        // Mesajı 2 saniye sonra kaldır
        _pathBlockedMessageTimer?.cancel();
        _pathBlockedMessageTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showPathBlockedMessage = false;
              _blockedMessageRow = null;
              _blockedMessageCol = null;
            });
          }
        });
      }
      return;
    }
    
    print('[DEBUG] Path found, placing tower...');
    
    setState(() {
      // Qülləni qoy (artıq qoyulub, amma yenidən təmin edirik)
      grid[row][col] = CellType.tower;
      
      final towerMaxHealth = (stats['maxHealth'] as double?) ?? 100.0;
      final tower = Tower(
        id: towerIdCounter++,
        row: row,
        col: col,
        type: selectedTowerType,
        damage: stats['damage'] as double,
        range: stats['range'] as double,
        fireRate: stats['fireRate'] as double,
        color: stats['color'] as Color,
        level: 1,
        maxHealth: towerMaxHealth,
        currentHealth: towerMaxHealth,
        currentAngle: -pi / 2, // Başlangıç açısı
        targetAngle: -pi / 2,
        hasRotated: false,
      );
      
      // Yeni yolu grid-ə çək
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (grid[r][c] == CellType.path) {
            grid[r][c] = CellType.empty;
          }
        }
      }
      
      // Yeni yolu grid-ə çək
      for (var point in newPath) {
        final pathRow = point.y.toInt();
        final pathCol = point.x.toInt();
        if (pathRow >= 0 && pathRow < rows && pathCol >= 0 && pathCol < cols) {
          if (grid[pathRow][pathCol] != CellType.tower) {
            grid[pathRow][pathCol] = CellType.path;
          }
        }
      }
      
      // Yolu yenilə
      pathPoints = newPath;
      
      // Düşmanları yola taşıma - düşmanlar kendileri yola doğru hareket edecek
      
      towers.add(tower);
      
      // Global avto can ayarlarını yoxla - yeni top qoyulduqda avtomatik aktiv et
      if (_globalAutoHealEnabledTypes.contains(tower.type)) {
        tower.autoHeal = true;
        tower.autoHealThreshold = _globalAutoHealThreshold;
      }
      
      // Pul və ya ulduz çıx
      if (cost > 0) {
        money -= cost;
      } else if (starCost > 0) {
        stars -= starCost;
      }
    });
  }
  
  @override
  void dispose() {
    gameTimer?.cancel();
    _pathBlockedMessageTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol sidebar
                _buildSidebar(),
                
                // Oyun taxtası
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildGameGrid(),
                        ),
                      ),
                      // Alt panel
                      _buildBottomPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Sol sidebar - incə versiya
  Widget _buildSidebar() {
    return Container(
      width: 45,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Oyun məlumatları (yuxarıda)
          _buildSidebarStat('🌊', wave.toString()),
          const SizedBox(height: 12),
          _buildSidebarStat('👾', enemies.length.toString()), // Düşmən sayı
          
          const SizedBox(height: 16),
          
          // Resurslar
          _buildSidebarStat('💰', money.toString()),
          const SizedBox(height: 12),
          _buildSidebarStat('💎', diamonds.toString()),
          const SizedBox(height: 12),
          _buildSidebarStat('⭐', stars.toString()),
          const SizedBox(height: 12),
          _buildSidebarStat('💚', emeralds.toString()), // Zümrüd
        ],
      ),
    );
  }
  
  // Sidebar stat widget
  Widget _buildSidebarStat(String icon, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: NeonColors.neonBlue,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Oyun taxtası - HTML/CSS v2 stilində neon görünüş
  Widget _buildGameGrid() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.4),
            const Color(0xFF020617).withValues(alpha: 0),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = grid.length;
          final cols = grid.isNotEmpty ? grid[0].length : 1;
          // AspectRatio üçün təhlükəsiz hesablama
          final aspectRatio = (rows > 0 && cols > 0) 
              ? (cols / rows.toDouble()).clamp(0.1, 10.0)
              : 1.0;
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                // Grid arxa overlay (board::before)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.0,
                        colors: [
                          const Color(0xFF3B82F6).withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.65],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          blurRadius: 26,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                // Grid
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    final row = index ~/ cols;
                    final col = index % cols;
                    if (row >= rows || col >= cols) return const SizedBox.shrink();
                    final cellType = grid[row][col];
                    
                    // Cell size hesabla: ekran genişliği / sütun sayısı - spacing
                    final screenWidth = MediaQuery.of(context).size.width;
                    final padding = 24.0; // Ekran kenarlarındaki padding
                    final spacing = 6.0 * (cols - 1); // Sütunlar arası spacing
                    final cellSize = (screenWidth - padding - spacing) / cols;
                    
                    // Seçili tower'ın range'ini göster
                    bool isInRange = false;
                    if (_selectedTower != null) {
                      final dx = col - _selectedTower!.col;
                      final dy = row - _selectedTower!.row;
                      final distance = sqrt(dx * dx + dy * dy);
                      isInRange = distance <= _selectedTower!.range;
                    }
                    
                    return Stack(
                      children: [
                        _buildCell(cellType, row, col, cellSize),
                        // Range görünümü
                        if (isInRange && cellType != CellType.tower)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: _selectedTower!.color.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // Düşmənlər və mərmilər
                _buildOverlay(),
                // Tower context menu overlay (dışına tıklanınca kapanır)
                if (_showTowerContextMenu && _selectedTower != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTower = null;
                          _showTowerContextMenu = false;
                          _menuDragOffset = Offset.zero;
                          _isEditingAutoHeal = false;
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                // Tower context menu
                if (_showTowerContextMenu && _selectedTower != null)
                  _buildTowerContextMenu(context),
                // Enemy context menu
                if (_selectedEnemy != null)
                  _buildEnemyContextMenu(context, _selectedEnemy!),
                // Yol bağlanır mesajı
                if (_showPathBlockedMessage && _blockedMessageRow != null && _blockedMessageCol != null)
                  _buildPathBlockedMessage(context),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Oyun taxtası - HTML/CSS v2 stilində neon görünüş
  Widget _buildGameBoard() {
    return Builder(
      builder: (context) {
        final rows = grid.length;
        final cols = grid.isNotEmpty ? grid[0].length : 1;
        // AspectRatio üçün təhlükəsiz hesablama
        final aspectRatio = (rows > 0 && cols > 0) 
            ? (cols / rows.toDouble()).clamp(0.1, 10.0)
            : 1.0;
        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            children: [
              // Grid arxa overlay (board::before)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.65],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        blurRadius: 26,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              // Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final row = index ~/ cols;
                  final col = index % cols;
                  if (row >= rows || col >= cols) return const SizedBox.shrink();
                  final cellType = grid[row][col];
                  
                  // Cell size hesabla: ekran genişliği / sütun sayısı - spacing
                  final screenWidth = MediaQuery.of(context).size.width;
                  final padding = 24.0; // Ekran kenarlarındaki padding
                  final spacing = 6.0 * (cols - 1); // Sütunlar arası spacing
                  final cellSize = (screenWidth - padding - spacing) / cols;
                  
                  // Seçili tower'ın range'ini göster
                  bool isInRange = false;
                  if (_selectedTower != null) {
                    final dx = col - _selectedTower!.col;
                    final dy = row - _selectedTower!.row;
                    final distance = sqrt(dx * dx + dy * dy);
                    isInRange = distance <= _selectedTower!.range;
                  }
                  
                  return Stack(
                    children: [
                      _buildCell(cellType, row, col, cellSize),
                      // Range görünümü
                      if (isInRange && cellType != CellType.tower)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: _selectedTower!.color.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // Düşmənlər və mərmilər (düşmanlara tıklama için IgnorePointer kaldırıldı)
              _buildOverlay(),
              // Tower context menu overlay (dışına tıklanınca kapanır)
              if (_showTowerContextMenu && _selectedTower != null)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTower = null;
                        _showTowerContextMenu = false;
                        _menuDragOffset = Offset.zero;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              // Tower context menu
              if (_showTowerContextMenu && _selectedTower != null)
                _buildTowerContextMenu(context),
              // Enemy context menu
              if (_selectedEnemy != null)
                _buildEnemyContextMenu(context, _selectedEnemy!),
            ],
          ),
        );
      },
    );
  }
  
  // Yol bağlanır mesajı widget'ı
  Widget _buildPathBlockedMessage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 24.0;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    final spacing = 6.0 * (cols - 1);
    final cellSize = (screenWidth - padding - spacing) / cols;
    
    final row = _blockedMessageRow!;
    final col = _blockedMessageCol!;
    
    // Hücrenin pozisyonunu hesapla (GridView'in içindeki pozisyon)
    final cellX = col * (cellSize + 6);
    final cellY = row * (cellSize + 6);
    
    return Positioned(
      left: cellX,
      top: cellY,
      child: IgnorePointer(
        child: Container(
          width: cellSize,
          height: cellSize,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.9),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'Yol bağlanır!',
                  style: TextStyle(
                    color: Colors.red.shade300,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.red.withOpacity(0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Cell widget - HTML/CSS v2 stilində neon görünüş
  Widget _buildCell(CellType cellType, int row, int col, double cellSize) {
    Color borderColor;
    Gradient? gradient;
    List<BoxShadow>? shadows;
    Widget? child;
    bool isPath = cellType == CellType.path;
    bool isTempPath = _isTempPathCell(row, col);
    
    // Aktiv grid konfiqurasiyasına görə dizayn
    final gridStyle = activeGridConfig?.gridPreviewPath ?? 'default';
    
    switch (cellType) {
      case CellType.empty:
        // Geçici yol kontrolü
        if (isTempPath) {
          // Geçici yol - farklı renkle göster (mavi/mor tonları)
          borderColor = const Color(0xFF8B5CF6).withValues(alpha: 0.6);
          gradient = RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              const Color(0xFF020617).withValues(alpha: 0),
            ],
          );
          shadows = [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ];
          break;
        }
        // Boş hüceyrə - grid dizaynına görə fərqli rənglər
        switch (gridStyle) {
          case 'grid1': // Sarı Neon - mavi tonları
            borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.25);
            gradient = RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.35),
                const Color(0xFF020617).withValues(alpha: 0),
              ],
            );
            shadows = [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ];
            break;
          case 'grid2': // Mavi Neon - mavi tonları (daha parlaq)
            borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.3);
            gradient = RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF1E3A8A).withValues(alpha: 0.2),
                const Color(0xFF020617).withValues(alpha: 0),
              ],
            );
            shadows = [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ];
            break;
          case 'grid3': // Pembe/Mor Neon - yaşıl tonları
            borderColor = const Color(0xFF22C55E).withValues(alpha: 0.3);
            gradient = RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF14532D).withValues(alpha: 0.2),
                const Color(0xFF020617).withValues(alpha: 0),
              ],
            );
            shadows = [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ];
            break;
          default: // Klassik - mavi tonları
            borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.6);
            gradient = RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.35),
                const Color(0xFF020617).withValues(alpha: 0),
              ],
            );
            shadows = [
              BoxShadow(
                color: const Color(0xFF020617).withValues(alpha: 0.3),
                blurRadius: 6,
                spreadRadius: 0,
                offset: Offset.zero,
              ),
            ];
            break;
        }
        break;
      case CellType.path:
        // Yol - aktiv yol konfiqurasiyasına görə dizayn
        final pathStyle = activePathConfig?.pathPreviewPath ?? 'default';
        final rows = grid.length;
        final cols = grid.isNotEmpty ? grid[0].length : gridCols;
        
        // Yol widget-ini qaytar - oyun başladıktan sonra da top eklenebilir
        return GestureDetector(
          onTap: () {
            // Oyun başladıktan sonra da top eklenebilir
            if (selectedTowerType != null) {
              _placeTower(row, col);
            }
          },
          child: activePathConfig?.buildPathWidget(
            rows: rows,
            cols: cols,
            pathRow: row,
            pathCol: col,
          ) ?? Container(
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              border: Border.all(
                color: const Color(0xFFFACC15).withValues(alpha: 0.45),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      case CellType.tower:
        // Qüllə
        borderColor = const Color(0xFF3B82F6).withValues(alpha: 0.6);
        gradient = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.35),
            const Color(0xFF020617).withValues(alpha: 0),
          ],
        );
        shadows = [
          BoxShadow(
            color: const Color(0xFF020617).withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ];
        // Qülləni tap
        final tower = towers.firstWhere(
          (t) => t.row == row && t.col == col,
          orElse: () => Tower(id: -1, row: row, col: col),
        );
        // Qüllə widget-i
        child = _buildTowerWidget(tower, cellSize);
        
        // Seçili tower'ın range'ini göster
        if (_selectedTower != null && _selectedTower!.id == tower.id) {
          // Range görünümü için border'ı vurgula
          borderColor = tower.color.withValues(alpha: 0.8);
          shadows = [
            BoxShadow(
              color: tower.color.withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 2,
              offset: Offset.zero,
            ),
          ];
        }
        
        break;
    }
    
    // Oyun başladıktan sonra da top eklenebilir ve context menu açılabilir
    final canPlaceTower = (cellType == CellType.empty || cellType == CellType.path);
    
    return GestureDetector(
      onTapDown: (details) {
        // Düşmanlara tıklanıp tıklanmadığını kontrol et
        final screenWidth = MediaQuery.of(context).size.width;
        final padding = 24.0;
        final cols = grid.isNotEmpty ? grid[0].length : gridCols;
        final spacing = 6.0 * (cols - 1);
        final cellSize = (screenWidth - padding - spacing) / cols;
        
        // Tıklama pozisyonunu hücre koordinatlarına çevir
        final tapX = details.localPosition.dx;
        final tapY = details.localPosition.dy;
        
        // Bu hücrede düşman var mı kontrol et
        final cellCenterX = cellSize / 2;
        final cellCenterY = cellSize / 2;
        final enemySize = 22.0; // Düşman boyutu
        final enemyRadius = enemySize / 2;
        
        // Tıklama düşmanın merkezine yakın mı kontrol et
        final dx = tapX - cellCenterX;
        final dy = tapY - cellCenterY;
        final distance = sqrt(dx * dx + dy * dy);
        
        // Eğer tıklama düşmanın merkezine yakınsa, düşmana tıklanmış olabilir
        if (distance < enemyRadius + 5) {
          // Bu hücrede düşman var mı kontrol et
          final hasEnemy = enemies.any((enemy) {
            final enemyCol = enemy.x.round();
            final enemyRow = enemy.y.round();
            return enemyCol == col && enemyRow == row;
          });
          
          if (hasEnemy) {
            // Düşmana tıklanmış, hücre tıklamasını iptal et
            print('[DEBUG] Enemy tapped, ignoring cell tap');
            return;
          }
        }
      },
      onTap: () {
        print('[DEBUG] Cell tapped: row=$row, col=$col, cellType=$cellType');
        print('[DEBUG] canPlaceTower=$canPlaceTower, selectedTowerType=$selectedTowerType');
        print('[DEBUG] isGameRunning=$isGameRunning');
        
        // Düşmanlara tıklanıp tıklanmadığını tekrar kontrol et
        final hasEnemy = enemies.any((enemy) {
          final enemyCol = enemy.x.round();
          final enemyRow = enemy.y.round();
          return enemyCol == col && enemyRow == row;
        });
        
        if (hasEnemy) {
          // Düşmana tıklanmış, hücre tıklamasını iptal et
          print('[DEBUG] Enemy in cell, ignoring cell tap');
          return;
        }
        
        if (canPlaceTower && selectedTowerType != null) {
          print('[DEBUG] Placing tower at row=$row, col=$col');
          _placeTower(row, col);
        } else if (cellType == CellType.tower) {
          print('[DEBUG] Tower tapped, opening context menu');
          // Qüllə üzərində klik - context menu göstər (oyun başladıktan sonra da çalışır)
          final tower = towers.firstWhere(
            (t) => t.row == row && t.col == col,
            orElse: () => Tower(id: -1, row: row, col: col),
          );
          if (tower.id != -1) {
            setState(() {
              _selectedTower = tower;
              _showTowerContextMenu = true;
              _menuDragOffset = Offset.zero; // Yeni tower seçildiğinde offset'i sıfırla
            });
          }
        } else {
          print('[DEBUG] Other cell tapped, closing context menu');
          // Başqa yere tıklanırsa context menu'yu kapat
          setState(() {
            _selectedTower = null;
            _showTowerContextMenu = false;
            _isEditingAutoHeal = false;
            _menuDragOffset = Offset.zero;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(11),
          boxShadow: [
            ...?shadows,
            // Inset shadow (HTML/CSS stilində)
            BoxShadow(
              color: const Color(0xFF020617).withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Stack(
          children: [
            // İkinci qat çərçivə (cell::after)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            // Qüllə və ya digər məzmun
            if (child != null) child,
          ],
        ),
      ),
    );
  }
  
  // Düşmən və mərmiləri çək
  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = grid.length;
        final cols = grid.isNotEmpty ? grid[0].length : 1;
        final cellWidth = constraints.maxWidth / cols;
        final cellHeight = constraints.maxHeight / rows;
        final middleRow = rows ~/ 2; // Orta sətir
        final castleCol = cols - 1; // Son sütun (yolun sonu)
        
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            // Düşmənlər (tıklanabilir)
            ...enemies.map((enemy) => Positioned(
              left: enemy.x * cellWidth + cellWidth / 2 - 11, // Hücrenin merkezine yerleştir
              top: enemy.y * cellHeight + cellHeight / 2 - 11, // Hücrenin merkezine yerleştir
              child: _buildEnemy(enemy),
            )),
            
            // Mərmilər (tıklamaları engellemez)
            ...bullets.map((bullet) => Positioned(
              left: bullet.x * cellWidth + cellWidth / 2 - 4, // Hücrenin merkezine yerleştir
              top: bullet.y * cellHeight + cellHeight / 2 - 4, // Hücrenin merkezine yerleştir
              child: IgnorePointer(
                child: _buildBullet(bullet),
              ),
            )),
            
            // Qala (orta sətirin sonunda, yolun sonunda) - hüceyrənin mərkəzində (tıklamaları engellemez)
            Positioned(
              left: castleCol * cellWidth + cellWidth / 2 - 14,
              top: middleRow * cellHeight + cellHeight / 2 - 17.5,
              child: IgnorePointer(
                child: _buildCastleIcon(),
              ),
            ),
          ],
        );
      },
    );
  }
  
  // Qala ikonu (grid-də)
  Widget _buildCastleIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sağlamlıq barı (yuxarıda)
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (health <= 0 || health.isNaN || health.isInfinite) 
                ? 0.0 
                : (health / 100.0).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: health > 50 
                    ? NeonColors.neonGreen 
                    : (health > 25 ? NeonColors.neonYellow : NeonColors.neonRed),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Qala (skull ikonu)
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.purple.shade800,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.purple.shade400,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CustomPaint(
            painter: SkullPainter(),
            size: const Size(20, 20),
          ),
        ),
      ],
    );
  }
  
  // Düşmən widget - modern neon görünüş (içi boş, kenarları neon - can barı kenarlarda)
  Widget _buildEnemy(Enemy enemy) {
    // Can barı hesapla (health / maxHealth)
    final healthRatio = (enemy.maxHealth > 0 && !enemy.maxHealth.isNaN && !enemy.health.isNaN)
        ? (enemy.health / enemy.maxHealth).clamp(0.0, 1.0)
        : 0.0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEnemy = _selectedEnemy == enemy ? null : enemy;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Düşman görünüşü - içi boş, kenarları neon (can barı kenarlarda) - saat yönünde kaybolma efekti
          if (enemy.type == EnemyType.square)
            CustomPaint(
              size: const Size(22, 22),
              painter: _ClockwiseNeonBorderPainter(
                color: enemy.isBurning ? Colors.orange : enemy.color, // Yanırsa narıncı rəng
                healthRatio: healthRatio,
                borderRadius: 4,
              ),
            )
          else
            CustomPaint(
              size: const Size(22, 22),
              painter: _TriangleNeonPainter(
                enemy.isBurning ? Colors.orange : enemy.color, // Yanırsa narıncı rəng
                healthRatio,
              ),
            ),
          // Yanma effekti - alov animasiyası
          if (enemy.isBurning)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Container(
                width: 22,
                height: 8,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.orange.withValues(alpha: 0.9),
                      Colors.red.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  size: 12,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Düşman context menu (tooltip gibi)
  Widget _buildEnemyContextMenu(BuildContext context, Enemy enemy) {
    if (_selectedEnemy != enemy) return const SizedBox.shrink();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    
    // Düşman pozisyonunu hesapla
    final rows = grid.length;
    final cols = grid.isNotEmpty ? grid[0].length : 1;
    final cellWidth = screenWidth / cols;
    final cellHeight = (screenHeight - safeAreaTop - safeAreaBottom - 50) / rows; // 50 = bottom panel
    
    final enemyX = enemy.x * cellWidth + cellWidth / 2;
    final enemyY = enemy.y * cellHeight + cellHeight / 2 + safeAreaTop;
    
    // Menu boyutları
    const menuWidth = 180.0;
    const menuHeight = 140.0;
    
    // Menu pozisyonu (düşmanın üstünde)
    double menuX = enemyX;
    double menuY = enemyY - menuHeight / 2 - 15;
    
    // Ekran sınırları
    final gridMinX = 0.0;
    final gridMaxX = screenWidth;
    final gridMinY = safeAreaTop;
    final gridMaxY = screenHeight - safeAreaBottom - 50;
    
    // X pozisyonunu sınırla
    if (menuX - menuWidth / 2 < gridMinX) {
      menuX = gridMinX + menuWidth / 2;
    }
    if (menuX + menuWidth / 2 > gridMaxX) {
      menuX = gridMaxX - menuWidth / 2;
    }
    
    // Y pozisyonunu sınırla
    if (menuY - menuHeight / 2 < gridMinY) {
      menuY = gridMinY + menuHeight / 2;
    }
    if (menuY + menuHeight / 2 > gridMaxY) {
      menuY = gridMaxY - menuHeight / 2;
    }
    
    return Positioned(
      left: menuX - menuWidth / 2,
      top: menuY - menuHeight / 2,
      child: GestureDetector(
        onTap: () {
          // Menu içine tıklanınca kapanmasın
        },
        child: Container(
          width: menuWidth,
          height: menuHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enemy.color.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: enemy.color.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enemy.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      enemy.type == EnemyType.square ? 'Square' : 'Triangle',
                      style: TextStyle(
                        color: enemy.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEnemy = null;
                        });
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEnemyStatRow('Level', '${enemy.level}', enemy.color),
                      const SizedBox(height: 4),
                      _buildEnemyStatRow('Health', '${enemy.health.toStringAsFixed(0)}/${enemy.maxHealth.toStringAsFixed(0)}', enemy.color),
                      const SizedBox(height: 4),
                      _buildEnemyStatRow('Speed', enemy.speed.toStringAsFixed(2), enemy.color),
                      const SizedBox(height: 4),
                      _buildEnemyStatRow('Damage', '${enemy.attackDamage.toStringAsFixed(0)}', enemy.color),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnemyStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  
  // Mərmi widget - modern neon görünüş
  Widget _buildBullet(Bullet bullet) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: bullet.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: bullet.color.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: bullet.color.withValues(alpha: 0.9),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
  
  // Alt panel - incə versiya
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Profil ikonu
          _buildThinButton('👤', Colors.grey, () {
            // Profil pəncərəsi (gələcək)
          }),
          
          // Başlat/Fasilə düyməsi
          if (!isGameRunning)
            _buildThinButton('▶️', Colors.green, () => _startGame())
          else
            _buildThinButton(
              isGamePaused ? '▶️' : '⏸️',
              isGamePaused ? Colors.green : Colors.orange,
              () {
                setState(() {
                  isGamePaused = !isGamePaused;
                });
              },
            ),
          
          // Avto can yeniləmə
          if (isGameRunning)
            _buildThinButton('🔄', Colors.blue, () {
              _showGlobalAutoHealDialog();
            }),
          
          // Mağaza ikonu
          _buildThinButton('🛒', Colors.amber, () {
            _showShopMenu();
          }),
          
          // Oyunu qeyd etmə
          _buildThinButton('💾', Colors.purple, () {
            // Oyunu qeyd etmə funksiyası (gələcək)
          }),
          
          // Yenidən başlat
          _buildThinButton('🔄', Colors.red, () {
            _restartGame();
          }),
          
          // Oyun idarətməsi
          _buildThinButton('⚙️', Colors.cyan, () {
            _showGameManagementMenu();
          }),
        ],
      ),
    );
  }
  
  // İncə düymə
  Widget _buildThinButton(String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  // Mağaza menyusu
  void _showShopMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShopMenu(),
    ).whenComplete(() {
      // Mağaza bağlananda preview-i geri qaytar
      _restoreGridFromPreview();
    });
  }
  
  // Mağaza menyu widget
  Widget _buildShopMenu() {
    return _ShopMenuWidget(gameState: this);
  }
  
  // Oyun idarətməsi menyusu
  void _showGameManagementMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGameManagementMenu(),
    );
  }
  
  // Global avto can dialogu
  void _showGlobalAutoHealDialog() {
    final TextEditingController thresholdController = TextEditingController(
      text: _globalAutoHealThreshold.toString(),
    );
    Set<TowerType> selectedTypes = Set.from(_globalAutoHealEnabledTypes);
    
    // Yalnız oyun taxtasında olan top növlərini göstər
    Set<TowerType> availableTypes = towers.map((t) => t.type).toSet();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: NeonColors.neonCyan.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 260, maxHeight: 400),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlıq
                Text(
                  'Avto Can Yeniləmə',
                  style: TextStyle(
                    color: NeonColors.neonCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Minimum dəyər input
                Text(
                  'Minimum Dəyər:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: NeonColors.neonCyan.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: thresholdController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Min: 0',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 9),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Top növləri siyahısı (1 sətirdə 2 qutu)
                Text(
                  'Top Növləri:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: SingleChildScrollView(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = (constraints.maxWidth - 4) / 2;
                        return Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: availableTypes.map((type) {
                            final isSelected = selectedTypes.contains(type);
                            final stats = Tower.getTowerStats(type);
                            final color = stats['color'] as Color;
                            final name = _getTowerName(type);
                            
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  if (isSelected) {
                                    selectedTypes.remove(type);
                                  } else {
                                    selectedTypes.add(type);
                                  }
                                });
                              },
                              child: Container(
                                width: itemWidth,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.2)
                                  : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.withValues(alpha: 0.3),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : Colors.grey.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 10,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Təsdiq düyməsi
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final threshold = int.tryParse(thresholdController.text);
                          if (threshold != null && threshold >= 0) {
                            setState(() {
                              _globalAutoHealThreshold = threshold;
                              _globalAutoHealEnabledTypes = selectedTypes;
                              
                              // Seçilmiş top növlərindəki bütün toplarda avto can aktiv et
                              for (var tower in towers) {
                                if (selectedTypes.contains(tower.type)) {
                                  tower.autoHeal = true;
                                  tower.autoHealThreshold = threshold;
                                } else {
                                  // Seçilməmiş növlərdə avto can söndür
                                  tower.autoHeal = false;
                                }
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: NeonColors.neonCyan.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: NeonColors.neonCyan,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Təsdiq',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: NeonColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Ləğv',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Oyun idarətməsi menyu widget
  Widget _buildGameManagementMenu() {
    return _GameManagementMenuWidget(
      gameState: this,
      onTowerSelected: (type) {
        setState(() {
          selectedTowerType = type;
        });
        Navigator.pop(context);
      },
      onPathChange: () {
        Navigator.pop(context);
        setState(() {
          _initializeGrid();
          _createPath();
          towers.clear();
        });
      },
      onRestart: () {
        // Bu callback artık kullanılmıyor (düğme kaldırıldı)
        // Navbar'daki yeniden başlat düğmesi kullanılacak
      },
    );
  }
  
  // Qüllə seçimi - modern neon görünüş
  Widget _buildTowerOption(TowerType type, String name, String cost, int? starCost) {
    final stats = Tower.getTowerStats(type);
    final isSelected = selectedTowerType == type;
    final canAfford = starCost != null 
        ? stars >= starCost 
        : (stats['cost'] as int? ?? 0) <= money;
    final towerColor = stats['color'] as Color;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTowerType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    towerColor.withValues(alpha: 0.3),
                    towerColor.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade900.withValues(alpha: 0.6),
          border: Border.all(
            color: isSelected 
                ? towerColor
                : (canAfford ? Colors.grey.shade600 : Colors.grey.shade800),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: towerColor.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: towerColor,
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    canAfford 
                        ? towerColor.withValues(alpha: 0.4)
                        : Colors.grey.shade700,
                    canAfford 
                        ? towerColor.withValues(alpha: 0.1)
                        : Colors.grey.shade800,
                  ],
                ),
                boxShadow: canAfford
                    ? [
                        BoxShadow(
                          color: towerColor.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: canAfford 
                    ? (isSelected ? towerColor : Colors.white)
                    : Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                shadows: isSelected && canAfford
                    ? [
                        Shadow(
                          color: towerColor.withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cost,
              style: TextStyle(
                color: canAfford 
                    ? (isSelected ? towerColor : NeonColors.neonYellow)
                    : Colors.grey.shade600,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Oyun idarətmələri
  Widget _buildGameControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isGameRunning)
          _buildSimpleButton(
            'Başlat',
            Colors.green,
            () => _startGame(),
          ),
        if (isGameRunning) ...[
          _buildSimpleButton(
            isGamePaused ? '▶️ Davam' : '⏸️ Fasilə',
            isGamePaused ? Colors.green : Colors.orange,
            () {
              setState(() {
                isGamePaused = !isGamePaused;
              });
            },
          ),
        ],
        _buildSimpleButton(
          'Yol Dəyiş',
          Colors.purple,
          () {
            setState(() {
              _initializeGrid();
              _createPath();
              towers.clear();
            });
          },
        ),
        _buildSimpleButton(
          'Yenidən',
          Colors.red,
          () {
            _restartGame();
          },
        ),
      ],
    );
  }
  
  // Tower context menu widget
  Widget _buildTowerContextMenu(BuildContext context) {
    if (_selectedTower == null) return const SizedBox.shrink();
    
    final tower = _selectedTower!;
    final stats = Tower.getTowerStats(tower.type);
    final upgradeCost = (tower.level * 50).toInt(); // Yükseltme maliyeti
    
    // Tower pozisyonunu hesapla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = 24.0;
    final spacing = 6.0;
    final cols = grid.isNotEmpty ? grid[0].length : gridCols;
    final rows = grid.length;
    final cellWidth = (screenWidth - padding - spacing * (cols - 1)) / cols;
    final cellHeight = cellWidth; // Kare hücreler
    
    // Grid sınırları
    final gridStartX = padding / 2;
    final gridStartY = padding / 2;
    final gridEndX = gridStartX + cols * (cellWidth + spacing) - spacing;
    final gridEndY = gridStartY + rows * (cellHeight + spacing) - spacing;
    
    // Tower'ın ekrandaki pozisyonu
    final towerX = gridStartX + tower.col * (cellWidth + spacing) + cellWidth / 2;
    final towerY = gridStartY + tower.row * (cellHeight + spacing) + cellHeight / 2;
    
    // Context menu boyutu - ekran boyutuna göre ölçeklendir
    final baseMenuWidth = 220.0;
    final baseMenuHeight = 240.0; // Yüksekliği azalt (280'den 240'a)
    final scaleFactor = (screenWidth / 800.0).clamp(0.7, 1.2); // Ekran genişliğine göre ölçeklendir
    double menuWidth = baseMenuWidth * scaleFactor;
    double menuHeight = (baseMenuHeight * scaleFactor).clamp(160.0, 280.0); // Min ve max değerleri de azalt
    
    // Grid sınırları - menü kesinlikle grid içinde kalmalı (5px padding)
    const gridPadding = 5.0;
    final gridMinX = gridStartX + gridPadding;
    final gridMaxX = gridEndX - gridPadding;
    final gridMinY = gridStartY + gridPadding;
    final gridMaxY = gridEndY - gridPadding;
    
    // Bottom panel yüksekliğini hesapla (padding + içerik) - 2 katına çıkar
    final bottomPanelHeight = 100.0; // 2 katına çıkarıldı (50'den 100'e)
    
    // Menü grid içinde sığabiliyor mu kontrol et (5px padding ile)
    // Eğer sığmıyorsa boyutunu küçült
    if (menuWidth > (gridMaxX - gridMinX)) {
      menuWidth = (gridMaxX - gridMinX);
    }
    if (menuHeight > (gridMaxY - gridMinY)) {
      menuHeight = (gridMaxY - gridMinY).clamp(160.0, 280.0);
    }
    
    // Ekran sınırları (SafeArea dahil) - bottom panel'i hesaba kat
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final screenTop = safeAreaTop;
    final screenBottom = screenHeight - safeAreaBottom - bottomPanelHeight;
    
    // Damanın mövqeyinə görə menyunun açılma istiqamətini təyin et
    // Damanın grid-dəki mövqeyini təyin et
    final cellCenterX = towerX;
    final cellCenterY = towerY;
    final cellLeft = cellCenterX - cellWidth / 2;
    final cellRight = cellCenterX + cellWidth / 2;
    final cellTop = cellCenterY - cellHeight / 2;
    final cellBottom = cellCenterY + cellHeight / 2;
    
    // Grid-in mərkəzini hesabla
    final gridCenterX = (gridStartX + gridEndX) / 2;
    final gridCenterY = (gridStartY + gridEndY) / 2;
    
    // Damanın mövqeyini təyin et (sağda, solda, yuxarıda, aşağıda)
    final isRightSide = tower.col >= cols / 2;
    final isLeftSide = tower.col < cols / 2;
    final isBottomSide = tower.row >= rows / 2;
    final isTopSide = tower.row < rows / 2;
    
    // Menyunun açılma istiqamətini təyin et
    // Əgər dama sağda altdadırsa, menyu damanın yuxarısında və solunda açılmalıdır
    // Əgər dama solda yuxarıdadırsa, menyu damanın aşağısında və sağında açılmalıdır
    // və s.
    double menuX = cellCenterX;
    double menuY = cellCenterY;
    
    // Menyunun damadan uzaqlaşma məsafəsi
    final menuOffset = 10.0; // Menyu ilə dama arasındakı məsafə
    
    // Mövqeyə görə menyunun pozisyonunu təyin et
    if (isRightSide && isBottomSide) {
      // Sağda altdadırsa: yuxarıda və solda açıl
      menuX = cellLeft - menuWidth / 2 - menuOffset;
      menuY = cellTop - menuHeight / 2 - menuOffset;
    } else if (isRightSide && isTopSide) {
      // Sağda yuxarıdadırsa: aşağıda və solda açıl
      menuX = cellLeft - menuWidth / 2 - menuOffset;
      menuY = cellBottom + menuHeight / 2 + menuOffset;
    } else if (isLeftSide && isBottomSide) {
      // Solda altdadırsa: yuxarıda və sağda açıl
      menuX = cellRight + menuWidth / 2 + menuOffset;
      menuY = cellTop - menuHeight / 2 - menuOffset;
    } else if (isLeftSide && isTopSide) {
      // Solda yuxarıdadırsa: aşağıda və sağda açıl
      menuX = cellRight + menuWidth / 2 + menuOffset;
      menuY = cellBottom + menuHeight / 2 + menuOffset;
    } else if (isRightSide) {
      // Sadəcə sağdadırsa: solda açıl
      menuX = cellLeft - menuWidth / 2 - menuOffset;
      menuY = cellCenterY;
    } else if (isLeftSide) {
      // Sadəcə soldadırsa: sağda açıl
      menuX = cellRight + menuWidth / 2 + menuOffset;
      menuY = cellCenterY;
    } else if (isBottomSide) {
      // Sadəcə altdadırsa: yuxarıda açıl
      menuX = cellCenterX;
      menuY = cellTop - menuHeight / 2 - menuOffset;
    } else if (isTopSide) {
      // Sadəcə yuxarıdadırsa: aşağıda açıl
      menuX = cellCenterX;
      menuY = cellBottom + menuHeight / 2 + menuOffset;
    }
    
    // Sürükleme offset'ini uygula (əgər sürüklənirsə)
    if (_menuDragOffset != Offset.zero) {
      menuX += _menuDragOffset.dx;
      menuY += _menuDragOffset.dy;
    }
    
    // Grid sınırları içinde kalmalı (menü tamamen grid içinde, 5px padding ile)
    final minX = gridMinX + menuWidth / 2;
    final maxX = gridMaxX - menuWidth / 2;
    final minY = gridMinY + menuHeight / 2;
    final maxY = gridMaxY - menuHeight / 2;
    
    // Ekstra padding - menü kesinlikle görünür alanda kalmalı
    final extraBottomPadding = 10.0;
    final extraTopPadding = 10.0;
    final extraRightPadding = 10.0;
    final extraLeftPadding = 10.0;
    final maxAllowedY = screenBottom - extraBottomPadding;
    final minAllowedY = screenTop + extraTopPadding;
    final maxAllowedX = screenWidth - extraRightPadding;
    final minAllowedX = extraLeftPadding;
    
    // Menünün gerçek kenarlarını hesapla (Positioned widget'ı için)
    // Positioned widget'ı left ve top değerleri kullanır:
    // Gerçek sol kenar = menuX - menuWidth / 2
    // Gerçek sağ kenar = menuX - menuWidth / 2 + menuWidth = menuX + menuWidth / 2
    // Gerçek üst kenar = menuY - menuHeight / 2
    // Gerçek alt kenar = menuY - menuHeight / 2 + menuHeight = menuY + menuHeight / 2
    
    // Önce ekran sınırlarını kontrol et - menü kesinlikle ekranda görünür olmalı
    final menuLeftEdge = menuX - menuWidth / 2;
    final menuRightEdge = menuX + menuWidth / 2;
    final menuBottomEdge = menuY + menuHeight / 2;
    final menuTopEdge = menuY - menuHeight / 2;
    
    // X ekseni (yatay) sınırlarını kontrol et
    // Eğer menü ekranın sağından taşıyorsa, sola taşı
    if (menuRightEdge > maxAllowedX) {
      menuX = maxAllowedX - menuWidth / 2;
      // Eğer sola taşıdıktan sonra soldan taşıyorsa, sol sınırına taşı
      if (menuX - menuWidth / 2 < minAllowedX) {
        menuX = minAllowedX + menuWidth / 2;
        // Eğer hala sığmıyorsa, boyutunu küçült
        if (menuX + menuWidth / 2 > maxAllowedX) {
          menuWidth = (maxAllowedX - minAllowedX).clamp(180.0, 300.0);
          menuX = minAllowedX + menuWidth / 2;
        }
      }
    }
    
    // Eğer menü ekranın solundan taşıyorsa, sağa taşı
    if (menuLeftEdge < minAllowedX) {
      menuX = minAllowedX + menuWidth / 2;
      // Eğer sağa taşıdıktan sonra sağdan taşıyorsa, sağ sınırına taşı
      if (menuX + menuWidth / 2 > maxAllowedX) {
        menuX = maxAllowedX - menuWidth / 2;
        // Eğer hala sığmıyorsa, boyutunu küçült
        if (menuX - menuWidth / 2 < minAllowedX) {
          menuWidth = (maxAllowedX - minAllowedX).clamp(180.0, 300.0);
          menuX = maxAllowedX - menuWidth / 2;
        }
      }
    }
    
    // Eğer menü ekranın altından taşıyorsa, yukarı taşı
    if (menuBottomEdge > maxAllowedY) {
      menuY = maxAllowedY - menuHeight / 2;
      // Eğer yukarı taşıdıktan sonra üstten taşıyorsa, üst sınırına taşı
      if (menuY - menuHeight / 2 < minAllowedY) {
        menuY = minAllowedY + menuHeight / 2;
        // Eğer hala sığmıyorsa, boyutunu küçült
        if (menuY + menuHeight / 2 > maxAllowedY) {
          menuHeight = (maxAllowedY - minAllowedY).clamp(160.0, 280.0);
          menuY = minAllowedY + menuHeight / 2;
        }
      }
    }
    
    // Eğer menü ekranın üstünden taşıyorsa, aşağı taşı
    if (menuTopEdge < minAllowedY) {
      menuY = minAllowedY + menuHeight / 2;
      // Eğer aşağı taşıdıktan sonra alttan taşıyorsa, alt sınırına taşı
      if (menuY + menuHeight / 2 > maxAllowedY) {
        menuY = maxAllowedY - menuHeight / 2;
        // Eğer hala sığmıyorsa, boyutunu küçült
        if (menuY - menuHeight / 2 < minAllowedY) {
          menuHeight = (maxAllowedY - minAllowedY).clamp(160.0, 280.0);
          menuY = maxAllowedY - menuHeight / 2;
        }
      }
    }
    
    // Şimdi grid sınırları içinde kalmalı (ekran sınırlarından sonra)
    // Grid X sınırlarını kontrol et, ancak ekran sınırlarını koru
    if (menuX + menuWidth / 2 > gridMaxX) {
      menuX = gridMaxX - menuWidth / 2;
      // Eğer grid sınırına taşıdıktan sonra ekran sınırını ihlal ediyorsa, ekran sınırını önceliklendir
      if (menuX + menuWidth / 2 > maxAllowedX) {
        menuX = maxAllowedX - menuWidth / 2;
      }
      if (menuX - menuWidth / 2 < minAllowedX) {
        menuX = minAllowedX + menuWidth / 2;
      }
    }
    if (menuX - menuWidth / 2 < gridMinX) {
      menuX = gridMinX + menuWidth / 2;
      // Eğer grid sınırına taşıdıktan sonra ekran sınırını ihlal ediyorsa, ekran sınırını önceliklendir
      if (menuX - menuWidth / 2 < minAllowedX) {
        menuX = minAllowedX + menuWidth / 2;
      }
      if (menuX + menuWidth / 2 > maxAllowedX) {
        menuX = maxAllowedX - menuWidth / 2;
      }
    }
    
    // Grid Y sınırlarını kontrol et, ancak ekran sınırlarını koru
    if (menuY + menuHeight / 2 > gridMaxY) {
      menuY = gridMaxY - menuHeight / 2;
      // Eğer grid sınırına taşıdıktan sonra ekran sınırını ihlal ediyorsa, ekran sınırını önceliklendir
      if (menuY + menuHeight / 2 > maxAllowedY) {
        menuY = maxAllowedY - menuHeight / 2;
      }
      if (menuY - menuHeight / 2 < minAllowedY) {
        menuY = minAllowedY + menuHeight / 2;
      }
    }
    if (menuY - menuHeight / 2 < gridMinY) {
      menuY = gridMinY + menuHeight / 2;
      // Eğer grid sınırına taşıdıktan sonra ekran sınırını ihlal ediyorsa, ekran sınırını önceliklendir
      if (menuY - menuHeight / 2 < minAllowedY) {
        menuY = minAllowedY + menuHeight / 2;
      }
      if (menuY + menuHeight / 2 > maxAllowedY) {
        menuY = maxAllowedY - menuHeight / 2;
      }
    }
    
    // Son kontrol: Eğer hala ekran sınırlarını ihlal ediyorsa, boyutunu küçült
    // X ekseni kontrolü
    if (menuX + menuWidth / 2 > maxAllowedX || menuX - menuWidth / 2 < minAllowedX) {
      final availableWidth = maxAllowedX - minAllowedX;
      if (availableWidth > 0) {
        menuWidth = availableWidth.clamp(180.0, 300.0);
        menuX = (minAllowedX + maxAllowedX) / 2;
      }
    }
    // Y ekseni kontrolü
    if (menuY + menuHeight / 2 > maxAllowedY || menuY - menuHeight / 2 < minAllowedY) {
      final availableHeight = maxAllowedY - minAllowedY;
      if (availableHeight > 0) {
        menuHeight = availableHeight.clamp(160.0, 280.0);
        menuY = (minAllowedY + maxAllowedY) / 2;
      }
    }
    
    // İçerik ölçeklendirme faktörü - menü boyutu küçüldüyse içeriği de küçült
    final contentScaleFactor = (menuHeight / baseMenuHeight).clamp(0.65, 1.0);
    
    return Positioned(
      left: menuX - menuWidth / 2,
      top: menuY - menuHeight / 2,
      child: GestureDetector(
        onTap: () {
          // Menu içine tıklanınca kapanmasın
        },
        child: Transform.scale(
          scale: contentScaleFactor,
          alignment: Alignment.topCenter,
          child: Container(
            width: menuWidth / contentScaleFactor,
            constraints: BoxConstraints(
              maxHeight: menuHeight / contentScaleFactor,
              minHeight: 160.0 / contentScaleFactor, // MinHeight'i de azalt
            ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: tower.color.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: tower.color.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - sürükleme için
              GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isDraggingMenu = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    // Basit sürükleme - sadece offset'i güncelle
                    _menuDragOffset += details.delta;
                    
                    // Ekran sınırlarını kontrol et
                    final safeAreaTop = MediaQuery.of(context).padding.top;
                    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
                    final bottomPanelHeight = 100.0;
                    final maxY = screenHeight - safeAreaBottom - bottomPanelHeight - menuHeight / 2 - 10;
                    final minY = safeAreaTop + menuHeight / 2 + 10;
                    final maxX = screenWidth - menuWidth / 2 - 10;
                    final minX = menuWidth / 2 + 10;
                    
                    // Menünün yeni pozisyonunu hesapla
                    final newMenuX = menuX + _menuDragOffset.dx;
                    final newMenuY = menuY + _menuDragOffset.dy;
                    
                    // Sınırları kontrol et ve offset'i sınırla
                    if (newMenuX > maxX) {
                      _menuDragOffset = Offset(maxX - menuX, _menuDragOffset.dy);
                    } else if (newMenuX < minX) {
                      _menuDragOffset = Offset(minX - menuX, _menuDragOffset.dy);
                    }
                    
                    if (newMenuY > maxY) {
                      _menuDragOffset = Offset(_menuDragOffset.dx, maxY - menuY);
                    } else if (newMenuY < minY) {
                      _menuDragOffset = Offset(_menuDragOffset.dx, minY - menuY);
                    }
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDraggingMenu = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: tower.color.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.drag_handle,
                            color: tower.color.withValues(alpha: 0.6),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getTowerName(tower.type),
                            style: TextStyle(
                              color: tower.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTower = null;
                            _showTowerContextMenu = false;
                            _isEditingAutoHeal = false;
                            _menuDragOffset = Offset.zero;
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: tower.color,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Atış gücü (Damage) - Upgrade butonu
                      _buildUpgradeButton(
                        tower: tower,
                        icon: Icons.whatshot,
                        currentValue: '${tower.damage.toInt()}',
                        upgradeLevel: tower.damageUpgradeLevel,
                        upgradeCost: 50,
                        color: Colors.red,
                        onUpgrade: () {
                          if (tower.damageUpgradeLevel < 3 && money >= 50) {
                            setState(() {
                              money -= 50;
                              tower.damageUpgradeLevel++;
                              tower.damage *= 1.2;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      // Hız (Fire Rate) - Upgrade butonu
                      _buildUpgradeButton(
                        tower: tower,
                        icon: Icons.flash_on,
                        currentValue: tower.fireRate.toStringAsFixed(1),
                        upgradeLevel: tower.fireRateUpgradeLevel,
                        upgradeCost: 50,
                        color: Colors.yellow,
                        onUpgrade: () {
                          if (tower.fireRateUpgradeLevel < 3 && money >= 50) {
                            setState(() {
                              money -= 50;
                              tower.fireRateUpgradeLevel++;
                              tower.fireRate *= 1.1;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      // Yarıçap (Range) - Upgrade butonu
                      _buildUpgradeButton(
                        tower: tower,
                        icon: Icons.my_location,
                        currentValue: tower.range.toStringAsFixed(1),
                        upgradeLevel: tower.rangeUpgradeLevel,
                        upgradeCost: 50,
                        color: Colors.blue,
                        onUpgrade: () {
                          if (tower.rangeUpgradeLevel < 3 && money >= 50) {
                            setState(() {
                              money -= 50;
                              tower.rangeUpgradeLevel++;
                              tower.range *= 1.05;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Orta kısım - 2 yan yana buton
                      Row(
                        children: [
                          // Health restore butonu
                          Expanded(
                            child: _buildHealthButton(
                              tower: tower,
                              icon: Icons.medication_liquid,
                              label: '${tower.currentHealth.toInt()}/${tower.maxHealth.toInt()}',
                              cost: Tower.getFullRepairCost(tower.maxHealth),
                              color: Colors.cyan,
                              onTap: () {
                                final repairCost = Tower.getFullRepairCost(tower.maxHealth);
                                if (tower.currentHealth < tower.maxHealth && money >= repairCost) {
                                  setState(() {
                                    money -= repairCost;
                                    tower.currentHealth = tower.maxHealth;
                                    // Rengi orijinal haline qaytar
                                    final stats = Tower.getTowerStats(tower.type);
                                    tower.color = stats['color'] as Color;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Health upgrade butonu
                          Expanded(
                            child: _buildHealthButton(
                              tower: tower,
                              icon: Icons.favorite,
                              label: '${tower.maxHealth.toInt()} (+50)',
                              cost: 50,
                              color: Colors.red,
                              onTap: () {
                                if (money >= 50) {
                                  setState(() {
                                    money -= 50;
                                    tower.maxHealth += 50;
                                    tower.currentHealth += 50;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Auto Heal toggle
                      _buildToggleButton(
                        tower: tower,
                        icon: Icons.refresh,
                        label: 'Avto Can: ${tower.autoHeal ? "Açıq (${tower.autoHealThreshold})" : "Kapalı"}',
                        isActive: tower.autoHeal,
                        color: Colors.purple,
                        onTap: () {
                          if (!tower.autoHeal) {
                            // Input sahəsini göstər
                            setState(() {
                              _isEditingAutoHeal = true;
                              _autoHealThresholdController.text = tower.autoHealThreshold.toString();
                            });
                          } else {
                            // Auto heal kapat və input sahəsini gizlət
                            setState(() {
                              tower.autoHeal = false;
                              _isEditingAutoHeal = false;
                            });
                          }
                        },
                      ),
                      // Auto heal input sahəsi (yalnız editing mode-da görünür)
                      if (_isEditingAutoHeal && _selectedTower?.id == tower.id) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.purple.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _autoHealThresholdController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: Colors.white, fontSize: 11),
                                  decoration: InputDecoration(
                                    hintText: 'Min: (0-${tower.maxHealth.toInt()})',
                                    hintStyle: TextStyle(color: Colors.white54, fontSize: 10),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                final threshold = int.tryParse(_autoHealThresholdController.text);
                                if (threshold != null && threshold >= 0 && threshold <= tower.maxHealth.toInt()) {
                                  setState(() {
                                    tower.autoHeal = true;
                                    tower.autoHealThreshold = threshold;
                                    _isEditingAutoHeal = false;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.purple,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Təsdiq',
                                  style: TextStyle(
                                    color: Colors.purple,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      // Awaken ve Shield butonları yan yana
                      Row(
                        children: [
                          // Awaken butonu
                          Expanded(
                            child: _buildDiamondButton(
                              tower: tower,
                              icon: Icons.auto_awesome,
                              label: '', // Awaken yazısı kaldırıldı
                              cost: 20,
                              color: Colors.purpleAccent,
                              onTap: () {
                                if (stars >= 20) {
                                  setState(() {
                                    stars -= 20;
                                    tower.level++;
                                    tower.damage *= 1.3;
                                    tower.fireRate *= 1.2;
                                    tower.range *= 1.1;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Shield upgrade butonu
                          Expanded(
                            child: _buildDiamondButton(
                              tower: tower,
                              icon: Icons.shield,
                              label: '',
                              cost: 50,
                              color: Colors.blue,
                              onTap: () {
                                if (stars >= 50) {
                                  setState(() {
                                    stars -= 50;
                                    tower.maxHealth *= 1.5;
                                    tower.health *= 1.5;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Sell butonu
                      _buildSellButton(
                        tower: tower,
                        onTap: () {
                          final sellPrice = (tower.level * 10 + 
                            (tower.damageUpgradeLevel + tower.fireRateUpgradeLevel + tower.rangeUpgradeLevel) * 5).toInt();
                          setState(() {
                            money += sellPrice;
                            towers.remove(tower);
                            grid[tower.row][tower.col] = CellType.empty;
                            _selectedTower = null;
                            _showTowerContextMenu = false;
                            _isEditingAutoHeal = false;
                            _menuDragOffset = Offset.zero;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // Transform.scale kapanışı
      ), // GestureDetector kapanışı
    ); // Positioned kapanışı
  }
  
  // Upgrade button widget - görseldeki gibi
  Widget _buildUpgradeButton({
    required Tower tower,
    required IconData icon,
    required String currentValue,
    required int upgradeLevel,
    required int upgradeCost,
    required Color color,
    required VoidCallback onUpgrade,
  }) {
    final canUpgrade = upgradeLevel < 3 && money >= upgradeCost;
    
    return GestureDetector(
      onTap: canUpgrade ? onUpgrade : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Solda icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            // Ortada değer ve upgrade seviyesi
            Expanded(
              child: Row(
                children: [
                  Text(
                    currentValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '($upgradeLevel/3)',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Sağda maliyet
            Text(
              '— \$$upgradeCost',
              style: TextStyle(
                color: canUpgrade ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Health button widget
  Widget _buildHealthButton({
    required Tower tower,
    required IconData icon,
    required String label,
    required int cost,
    required Color color,
    required VoidCallback onTap,
  }) {
    final canAfford = money >= cost;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: canAfford ? Colors.white : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '— \$$cost',
              style: TextStyle(
                color: canAfford ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Toggle button widget
  Widget _buildToggleButton({
    required Tower tower,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: isActive ? 0.6 : 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isActive ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? color : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Diamond button widget (stars currency)
  Widget _buildDiamondButton({
    required Tower tower,
    required IconData icon,
    required String label,
    required int cost,
    required Color color,
    required VoidCallback onTap,
  }) {
    final canAfford = stars >= cost;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            if (label.isNotEmpty)
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: canAfford ? Colors.white : Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              '(💎 $cost)',
              style: TextStyle(
                color: canAfford ? Colors.white : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Sell button widget
  Widget _buildSellButton({
    required Tower tower,
    required VoidCallback onTap,
  }) {
    final sellPrice = (tower.level * 10 + 
      (tower.damageUpgradeLevel + tower.fireRateUpgradeLevel + tower.rangeUpgradeLevel) * 5).toInt();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.orange,
                size: 14,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Sell',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '(\$$sellPrice)',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  
  // Qüllə adını qaytar
  String _getTowerName(TowerType type) {
    switch (type) {
      case TowerType.basic:
        return 'Basic';
      case TowerType.rapid:
        return 'Rapid';
      case TowerType.heavy:
        return 'Heavy';
      case TowerType.ice:
        return 'Ice';
      case TowerType.flame:
        return 'Flame';
      case TowerType.laser:
        return 'Laser';
      case TowerType.plasma:
        return 'Plasma';
    }
  }
  
  // Qüllə widget - gözəl neon görünüş
  Widget _buildTowerWidget(Tower tower, double cellSize) {
    // Ən yaxın düşməni tap (ateş etme durumu için)
    Enemy? nearestEnemy;
    double nearestDistance = double.infinity;
    
    for (var enemy in enemies) {
      final dx = enemy.x - tower.col;
      final dy = enemy.y - tower.row;
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance <= tower.range && distance < nearestDistance) {
        nearestEnemy = enemy;
        nearestDistance = distance;
      }
    }
    
    // Lülə istiqaməti (tower'ın currentAngle'ını kullan)
    final angle = tower.currentAngle;
    
    // Yeni neon top dizaynı - HTML tasarımına əsasən
    // Top hücrenin içinde, inset: 4px boşlukla
    // Her top tipi üçün ayrı widget istifadə et
    Widget towerWidget;
    switch (tower.type) {
      case TowerType.basic:
        towerWidget = BasicTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.rapid:
        towerWidget = RapidTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.heavy:
        towerWidget = HeavyTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.ice:
        towerWidget = IceTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.flame:
        towerWidget = FlameTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.laser:
        towerWidget = LaserTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
      case TowerType.plasma:
        towerWidget = PlasmaTowerWidget(
          size: cellSize,
          angle: angle,
          isFiring: nearestEnemy != null,
        );
        break;
    }
    
    Widget finalWidget = Padding(
      padding: const EdgeInsets.all(4), // HTML'deki inset: 4px
      child: towerWidget,
    );
    
    // Tower adı yukarıda
    // Can barı hesapla (currentHealth / maxHealth)
    final healthRatio = (tower.currentHealth / tower.maxHealth).clamp(0.0, 1.0);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Can barı (kenarındaki renk çizgileri) - saat yönünde kaybolma efekti
        Positioned.fill(
          child: CustomPaint(
            painter: _ClockwiseNeonBorderPainter(
              color: tower.color,
              healthRatio: healthRatio,
              borderRadius: 11,
            ),
          ),
        ),
        finalWidget,
      ],
    );
  }
  
  
  // Modern neon düymə
  Widget _buildSimpleButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: color.withValues(alpha: 0.8),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}

// Mağaza menyu widget
class _ShopMenuWidget extends StatefulWidget {
  final _NeonDefenderGameScreenState gameState;
  
  const _ShopMenuWidget({required this.gameState});
  
  @override
  State<_ShopMenuWidget> createState() => _ShopMenuWidgetState();
}

class _ShopMenuWidgetState extends State<_ShopMenuWidget> {
  int selectedTab = 0; // 0 = Pul, 1 = Elmas, 2 = Ulduz, 3 = Zümrüd, 4 = Hediyye
  int emeraldSubTab = 0; // 0 = Grid, 1 = Yol, 2 = Toplar, 3 = Xüsusiyyətlər
  GridConfig? previewGrid; // Preview üçün seçilmiş grid
  final TextEditingController _giftCodeController = TextEditingController();
  bool _isValidatingGiftCode = false;
  String? _giftCodeMessage;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: NeonColors.neonBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab başlıqları
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: NeonColors.neonBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildShopTabButton('💰 Pul', 0, () {
                    setState(() => selectedTab = 0);
                  }),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildShopTabButton('💎 Elmas', 1, () {
                    setState(() => selectedTab = 1);
                  }),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildShopTabButton('⭐ Ulduz', 2, () {
                    setState(() => selectedTab = 2);
                  }),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildShopTabButton('💚 Zümrüd', 3, () {
                    setState(() => selectedTab = 3);
                  }),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildShopTabButton('🎁 Hediyye', 4, () {
                    setState(() => selectedTab = 4);
                  }),
                ),
              ],
            ),
          ),
          
          // Tab məzmunu
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: _buildShopTabContent(),
            ),
          ),
        ],
      ),
    );
  }
  
  // Mağaza tab düyməsi
  Widget _buildShopTabButton(String text, int index, VoidCallback onTap) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? NeonColors.neonBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? NeonColors.neonBlue
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? NeonColors.neonBlue : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // Mağaza tab məzmunu
  Widget _buildShopTabContent() {
    switch (selectedTab) {
      case 0: // Pul
        return _buildMoneyTab();
      case 1: // Elmas
        return _buildDiamondTab();
      case 2: // Ulduz
        return _buildStarTab();
      case 3: // Zümrüd
        return _buildEmeraldTab();
      case 4: // Hediyye
        return _buildGiftTab();
      default:
        return const SizedBox.shrink();
    }
  }
  
  // Pul tabı
  Widget _buildMoneyTab() {
    return Center(
      child: Text(
        'Pul tabı tezliklə əlavə ediləcək',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Elmas tabı
  Widget _buildDiamondTab() {
    return Center(
      child: Text(
        'Elmas tabı tezliklə əlavə ediləcək',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Ulduz tabı
  Widget _buildStarTab() {
    return Center(
      child: Text(
        'Ulduz tabı tezliklə əlavə ediləcək',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Zümrüd tabı - Tablı sistem
  Widget _buildEmeraldTab() {
    final gameState = widget.gameState;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Alt tablar
        Row(
          children: [
            Expanded(
              child: _buildEmeraldSubTabButton('Grid', 0, () {
                setState(() => emeraldSubTab = 0);
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildEmeraldSubTabButton('Yol', 1, () {
                setState(() => emeraldSubTab = 1);
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildEmeraldSubTabButton('Toplar', 2, () {
                setState(() => emeraldSubTab = 2);
              }),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildEmeraldSubTabButton('Xüsusiyyətlər', 3, () {
                setState(() => emeraldSubTab = 3);
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Alt tab məzmunu - SizedBox ile sabit yükseklik (scroll özelliği içəridə)
        SizedBox(
          height: 300,
          child: _buildEmeraldSubTabContent(gameState),
        ),
      ],
    );
  }
  
  // Zümrüd alt tab düyməsi
  Widget _buildEmeraldSubTabButton(String text, int index, VoidCallback onTap) {
    final isSelected = emeraldSubTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? NeonColors.neonGreen.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected 
                ? NeonColors.neonGreen
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? NeonColors.neonGreen : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // Zümrüd alt tab məzmunu
  Widget _buildEmeraldSubTabContent(_NeonDefenderGameScreenState gameState) {
    switch (emeraldSubTab) {
      case 0: // Grid
        return _buildGridTab(gameState);
      case 1: // Yol
        return _buildPathTab(gameState);
      case 2: // Toplar
        return _buildTowersTab(gameState);
      case 3: // Xüsusiyyətlər
        return _buildFeaturesTab(gameState);
      default:
        return const SizedBox.shrink();
    }
  }
  
  // Grid tabı
  Widget _buildGridTab(_NeonDefenderGameScreenState gameState) {
    if (gameState.gridConfigs.isEmpty) {
      return const Center(
        child: Text(
          'Gridlər yüklənir...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 sütun - yan yana daha çox
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.2, // Frame'leri daha geniş yap (1/4 küçük)
      ),
      itemCount: gameState.gridConfigs.length,
      itemBuilder: (context, index) {
        final gridConfig = gameState.gridConfigs[index];
        return _buildGridPreviewItem(gridConfig, gameState);
      },
    );
  }
  
  // Yol tabı
  Widget _buildPathTab(_NeonDefenderGameScreenState gameState) {
    // Debug: pathConfigs sayısını kontrol et
    if (gameState.pathConfigs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Yollar yüklənir...',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'PathConfigs sayı: ${gameState.pathConfigs.length}',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.2,
      ),
      itemCount: gameState.pathConfigs.length,
      itemBuilder: (context, index) {
        if (index >= gameState.pathConfigs.length) {
          return const SizedBox.shrink();
        }
        final pathConfig = gameState.pathConfigs[index];
        return _buildPathPreviewItem(pathConfig, gameState);
      },
    );
  }
  
  // Yol preview elementi
  Widget _buildPathPreviewItem(PathConfig config, _NeonDefenderGameScreenState gameState) {
    final isOwned = config.isOwned;
    final isActive = config.isActive;
    
    return GestureDetector(
      onTap: () {
        if (isOwned) {
          gameState._activatePath(config);
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive 
              ? NeonColors.neonGreen.withValues(alpha: 0.1)
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive 
                ? NeonColors.neonGreen.withValues(alpha: 0.5)
                : Colors.grey.shade600,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Yol preview - tam frame ölçüsündə
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildPathPreview(config),
              ),
            ),
            // Şeffaf label - "Aktiv et" və ya "Aktivdir"
            if (isOwned)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: GestureDetector(
                  onTap: isActive ? null : () {
                    gameState._activatePath(config);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Colors.grey.shade700.withValues(alpha: 0.7)
                          : NeonColors.neonGreen.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActive 
                            ? Colors.grey.shade500
                            : NeonColors.neonGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Aktivdir' : 'Aktiv et',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: GestureDetector(
                  onTap: gameState.emeralds >= config.emeraldCost
                      ? () {
                          gameState._buyPath(config);
                          setState(() {});
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: gameState.emeralds >= config.emeraldCost
                          ? NeonColors.neonPurple.withValues(alpha: 0.7)
                          : Colors.grey.shade700.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: gameState.emeralds >= config.emeraldCost
                            ? NeonColors.neonPurple
                            : Colors.grey.shade500,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Al: ${config.emeraldCost} 💚',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gameState.emeralds >= config.emeraldCost
                            ? Colors.white
                            : Colors.grey.shade400,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Yol adı - yuxarıda
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Text(
                config.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Yol preview widget
  Widget _buildPathPreview(PathConfig config) {
    // Yol preview üçün tüm grid
    return config.buildPreview();
  }
  
  // Grid preview elementi - tam frame ölçüsündə grid
  Widget _buildGridPreviewItem(GridConfig config, _NeonDefenderGameScreenState gameState) {
    final isOwned = config.isOwned;
    final isActive = config.isActive;
    final isSelected = previewGrid?.id == config.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          previewGrid = config;
        });
        // Preview üçün grid-i dəyiş (qalıcı deyil)
        gameState._previewGrid(config);
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected
              ? NeonColors.neonGreen.withValues(alpha: 0.15)
              : (isActive 
                  ? NeonColors.neonGreen.withValues(alpha: 0.1)
                  : Colors.grey.shade800),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? NeonColors.neonGreen
                : (isActive 
                    ? NeonColors.neonGreen.withValues(alpha: 0.5)
                    : Colors.grey.shade600),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Grid preview - tam frame ölçüsündə
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: _buildGridPreview(config),
              ),
            ),
            // Şeffaf label - "Aktiv et" və ya "Aktivdir"
            if (isOwned)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: GestureDetector(
                  onTap: isActive ? null : () {
                    gameState._activateGrid(config);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? Colors.grey.shade700.withValues(alpha: 0.7)
                          : NeonColors.neonGreen.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActive 
                            ? Colors.grey.shade500
                            : NeonColors.neonGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Aktivdir' : 'Aktiv et',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: GestureDetector(
                  onTap: gameState.emeralds >= config.emeraldCost
                      ? () {
                          gameState._buyGrid(config);
                          setState(() {});
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: gameState.emeralds >= config.emeraldCost
                          ? NeonColors.neonPurple.withValues(alpha: 0.7)
                          : Colors.grey.shade700.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: gameState.emeralds >= config.emeraldCost
                            ? NeonColors.neonPurple
                            : Colors.grey.shade500,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Al: ${config.emeraldCost} 💚',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: gameState.emeralds >= config.emeraldCost
                            ? Colors.white
                            : Colors.grey.shade400,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Grid adı - yuxarıda
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  config.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Grid preview - tam ölçüdə
  Widget _buildGridPreview(GridConfig config) {
    return config.buildPreview();
  }
  
  // Toplar tabı
  Widget _buildTowersTab(_NeonDefenderGameScreenState gameState) {
    return Center(
      child: Text(
        'Toplar tabı tezliklə əlavə ediləcək',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Xüsusiyyətlər tabı
  Widget _buildFeaturesTab(_NeonDefenderGameScreenState gameState) {
    return Center(
      child: Text(
        'Xüsusiyyətlər tabı tezliklə əlavə ediləcək',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Hediyye tabı
  Widget _buildGiftTab() {
    final gameState = widget.gameState;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gift kod girişi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: NeonColors.neonGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Gift Kod Daxil Edin',
                  style: TextStyle(
                    color: NeonColors.neonGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _giftCodeController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Gift kod yazın (məs: hediyye5)',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: NeonColors.neonGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: NeonColors.neonGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: NeonColors.neonGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isValidatingGiftCode ? null : () => _validateGiftCode(gameState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _isValidatingGiftCode
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'Gift Kodu Aktiv Et',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (_giftCodeMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _giftCodeMessage!,
                      style: TextStyle(
                        color: _giftCodeMessage!.contains('uğur')
                            ? NeonColors.neonGreen
                            : Colors.red.shade400,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Açıklama
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ℹ️ Məlumat',
                  style: TextStyle(
                    color: NeonColors.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Gift kodları bir dəfə istifadə edilə bilər\n'
                  '• Gift kod aktiv edildikdə avtomatik olaraq hesabınıza əlavə edilir\n'
                  '• Gift kodları böyük/kiçik hərf həssas deyil',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Gift kod doğrulama
  Future<void> _validateGiftCode(_NeonDefenderGameScreenState gameState) async {
    final code = _giftCodeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _giftCodeMessage = 'Zəhmət olmasa gift kod daxil edin';
      });
      return;
    }
    
    setState(() {
      _isValidatingGiftCode = true;
      _giftCodeMessage = null;
    });
    
    try {
      // Yerel test için (API olmadan)
      final result = await GiftCodeService.validateGiftCodeLocal(code);
      
      if (result['success'] == true) {
        final giftCode = result['gift_code'] as GiftCode;
        
        // Gift kod kullanılmış mı kontrol et
        if (giftCode.isUsed) {
          setState(() {
            _isValidatingGiftCode = false;
            _giftCodeMessage = 'Bu gift kod artıq istifadə edilib';
          });
          return;
        }
        
        // Hediyyeleri ver
        setState(() {
          gameState.money += giftCode.money ?? 0;
          gameState.diamonds += giftCode.diamonds ?? 0;
          gameState.stars += giftCode.stars ?? 0;
          gameState.emeralds += giftCode.emeralds ?? 0;
          _isValidatingGiftCode = false;
          _giftCodeMessage = 'Gift kod uğurla aktiv edildi!\n'
              '💰 +${giftCode.money ?? 0} | '
              '💎 +${giftCode.diamonds ?? 0} | '
              '⭐ +${giftCode.stars ?? 0} | '
              '💚 +${giftCode.emeralds ?? 0}';
          _giftCodeController.clear();
        });
        
        // Oyun verilerini kaydet
        await gameState._saveGameData();
        
        // Gift kod kullanımını kaydet (lokal)
        await GiftCodeService.markGiftCodeAsUsed(code);
      } else {
        setState(() {
          _isValidatingGiftCode = false;
          _giftCodeMessage = result['message'] as String? ?? 'Gift kod tapılmadı';
        });
      }
    } catch (e) {
      setState(() {
        _isValidatingGiftCode = false;
        _giftCodeMessage = 'Xəta: ${e.toString()}';
      });
    }
  }
  
  @override
  void dispose() {
    _giftCodeController.dispose();
    super.dispose();
  }
  
  // Grid elementi (köhnə - silinəcək)
  Widget _buildGridItem(GridConfig config, _NeonDefenderGameScreenState gameState) {
    final isOwned = config.isOwned;
    final isActive = config.isActive;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive 
            ? NeonColors.neonGreen.withValues(alpha: 0.1)
            : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive 
              ? NeonColors.neonGreen
              : Colors.grey.shade600,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeonColors.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Aktiv',
                    style: TextStyle(
                      color: NeonColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ölçü: ${config.rows} x ${config.cols}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (isOwned)
            ElevatedButton(
              onPressed: isActive ? null : () {
                gameState._activateGrid(config);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive 
                    ? Colors.grey.shade600
                    : NeonColors.neonGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(isActive ? 'Aktivdir' : 'Aktiv et'),
            )
          else
            ElevatedButton(
              onPressed: gameState.emeralds >= config.emeraldCost
                  ? () {
                      gameState._buyGrid(config);
                      setState(() {});
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: gameState.emeralds >= config.emeraldCost
                    ? NeonColors.neonPurple
                    : Colors.grey.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Al: ${config.emeraldCost} 💚',
                style: TextStyle(
                  color: gameState.emeralds >= config.emeraldCost
                      ? Colors.white
                      : Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Oyun idarətməsi menyu widget (ayrı StatefulWidget)
class _GameManagementMenuWidget extends StatefulWidget {
  final _NeonDefenderGameScreenState gameState;
  final Function(TowerType) onTowerSelected;
  final VoidCallback onPathChange;
  final VoidCallback onRestart;
  
  const _GameManagementMenuWidget({
    required this.gameState,
    required this.onTowerSelected,
    required this.onPathChange,
    required this.onRestart,
  });
  
  @override
  State<_GameManagementMenuWidget> createState() => _GameManagementMenuWidgetState();
}

class _GameManagementMenuWidgetState extends State<_GameManagementMenuWidget> {
  int selectedTab = 0; // 0 = Toplar, 1 = Əlavələr
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: NeonColors.neonBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab başlıqları
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: NeonColors.neonBlue.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Toplar', 0, () {
                    setState(() => selectedTab = 0);
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton('Əlavələr', 1, () {
                    setState(() => selectedTab = 1);
                  }),
                ),
              ],
            ),
          ),
          
          // Tab məzmunu
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: selectedTab == 0
                ? _buildTowersTab()
                : _buildExtrasTab(),
          ),
        ],
      ),
    );
  }
  
  // Tab düyməsi
  Widget _buildTabButton(String text, int index, VoidCallback onTap) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? NeonColors.neonBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? NeonColors.neonBlue
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? NeonColors.neonBlue : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // Toplar tab
  Widget _buildTowersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildTowerOption(TowerType.basic, 'Sadə', '\$50', null),
          _buildTowerOption(TowerType.rapid, 'Sürətli', '\$100', null),
          _buildTowerOption(TowerType.heavy, 'Ağır', '\$200', null),
          _buildTowerOption(TowerType.ice, 'Buz', '⭐1', 1),
          _buildTowerOption(TowerType.flame, 'Alov', '⭐2', 2),
          _buildTowerOption(TowerType.laser, 'Lazer', '⭐3', 3),
          _buildTowerOption(TowerType.plasma, 'Plazma', '⭐4', 4),
        ],
      ),
    );
  }
  
  // Əlavələr tab
  Widget _buildExtrasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // FPS seçimi
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: NeonColors.neonCyan.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FPS Seçimi',
                  style: TextStyle(
                    color: NeonColors.neonCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Oyunun sürətini və görünüşünü test etmək üçün',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildFPSButton(30, '30'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildFPSButton(60, '60'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildFPSButton(90, '90'),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _buildFPSButton(120, '120'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Cari: ${widget.gameState.targetFPS} FPS',
                  style: TextStyle(
                    color: NeonColors.neonCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildExtraButton('Yol Dəyiş', Colors.purple, widget.onPathChange),
          // Navbar'daki yeniden başlat düğmesi kullanılacak, buradaki kaldırıldı
        ],
      ),
    );
  }
  
  // FPS düyməsi
  Widget _buildFPSButton(int fps, String label) {
    final isSelected = widget.gameState.targetFPS == fps;
    return GestureDetector(
      onTap: () {
        widget.gameState.setFPS(fps);
        setState(() {}); // UI yenilə
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? NeonColors.neonCyan.withValues(alpha: 0.3)
              : Colors.grey.shade800.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
                ? NeonColors.neonCyan
                : Colors.grey.shade600,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '$label FPS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? NeonColors.neonCyan : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // Qüllə seçimi
  Widget _buildTowerOption(TowerType type, String name, String cost, int? starCost) {
    final stats = Tower.getTowerStats(type);
    final towerColor = stats['color'] as Color;
    
    return GestureDetector(
      onTap: () => widget.onTowerSelected(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: towerColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: towerColor,
                  width: 2,
                ),
                gradient: RadialGradient(
                  colors: [
                    towerColor.withValues(alpha: 0.4),
                    towerColor.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: towerColor.withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: towerColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              cost,
              style: TextStyle(
                color: NeonColors.neonYellow,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Əlavə düyməsi
  Widget _buildExtraButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Path cell widget - pulse animasiyası ilə
class _PathCellWidget extends StatefulWidget {
  final Color borderColor;
  final Gradient? gradient;
  final Widget? child;
  final VoidCallback onTap;
  
  const _PathCellWidget({
    required this.borderColor,
    required this.gradient,
    required this.child,
    required this.onTap,
  });
  
  @override
  State<_PathCellWidget> createState() => _PathCellWidgetState();
}

class _PathCellWidgetState extends State<_PathCellWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              border: Border.all(
                color: widget.borderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFACC15).withValues(alpha: _animation.value),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // İkinci qat çərçivə (cell::after)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
                // Qüllə və ya digər məzmun
                if (widget.child != null) widget.child!,
              ],
            ),
          );
        },
      ),
    );
  }
}

// Path cell widget with flow animation (Grid1, Grid2 və Grid3 üçün)
class _PathCellWidgetWithFlow extends StatefulWidget {
  final Color borderColor;
  final Gradient? gradient;
  final Widget? child;
  final int pathIndex;
  final int totalPathLength;
  final String direction; // 'right', 'left', 'up', 'down'
  final String gridStyle; // 'grid1', 'grid2', 'grid3', 'default'
  final VoidCallback onTap;
  
  const _PathCellWidgetWithFlow({
    required this.borderColor,
    required this.gradient,
    required this.child,
    required this.pathIndex,
    required this.totalPathLength,
    required this.direction,
    required this.gridStyle,
    required this.onTap,
  });
  
  @override
  State<_PathCellWidgetWithFlow> createState() => _PathCellWidgetWithFlowState();
}

class _PathCellWidgetWithFlowState extends State<_PathCellWidgetWithFlow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3, milliseconds: 600),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Animasiya path boyunca hərəkət edir
    // Delay-i path index-ə görə hesabla
    final delay = widget.pathIndex * 0.15;
    final totalDuration = widget.totalPathLength * 0.15;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.gradient,
          border: Border.all(
            color: widget.borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Stack(
          children: [
            // İkinci qat çərçivə (cell::after)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            // İşıq dalğası animasiyası
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Animasiya 1-ci sütundan başlayıb sonuncu sütunda bitməlidir
                // Hər hüceyrə üçün delay hesabla
                final baseAnimation = _controller.value;
                final cellStartTime = delay / totalDuration;
                final cellEndTime = (delay + 0.15) / totalDuration;
                
                // Bu hüceyrədə animasiya görünməlidirmi?
                if (baseAnimation < cellStartTime || baseAnimation > cellEndTime) {
                  return Stack(
                    children: [
                      if (widget.child != null) widget.child!,
                    ],
                  );
                }
                
                // Bu hüceyrə daxilində animasiya progress-i (0.0 - 1.0)
                final localProgress = (baseAnimation - cellStartTime) / (cellEndTime - cellStartTime);
                
                // İstiqamətə görə gradient və transform
                Alignment begin, end;
                Offset translateOffset;
                
                switch (widget.direction) {
                  case 'right':
                    begin = Alignment.centerLeft;
                    end = Alignment.centerRight;
                    translateOffset = Offset(-1.0 + localProgress * 2.0, 0) * 46;
                    break;
                  case 'left':
                    begin = Alignment.centerRight;
                    end = Alignment.centerLeft;
                    translateOffset = Offset(1.0 - localProgress * 2.0, 0) * 46;
                    break;
                  case 'down':
                    begin = Alignment.topCenter;
                    end = Alignment.bottomCenter;
                    translateOffset = Offset(0, -1.0 + localProgress * 2.0) * 46;
                    break;
                  case 'up':
                    begin = Alignment.bottomCenter;
                    end = Alignment.topCenter;
                    translateOffset = Offset(0, 1.0 - localProgress * 2.0) * 46;
                    break;
                  default:
                    begin = Alignment.centerLeft;
                    end = Alignment.centerRight;
                    translateOffset = Offset(-1.0 + localProgress * 2.0, 0) * 46;
                }
                
                // Opacity hesabla
                double opacity = 0.0;
                if (localProgress < 0.1) {
                  opacity = localProgress / 0.1;
                } else if (localProgress < 0.9) {
                  opacity = 1.0;
                } else {
                  opacity = 1.0 - ((localProgress - 0.9) / 0.1);
                }
                
                // Grid dizaynına görə animasiya rəngləri
                Color waveColor;
                switch (widget.gridStyle) {
                  case 'grid1': // Sarı Neon
                    waveColor = const Color(0xFFFACC15);
                    break;
                  case 'grid2': // Mavi Neon
                    waveColor = const Color(0xFF3B82F6);
                    break;
                  case 'grid3': // Pembe/Mor Neon
                    waveColor = const Color(0xFFEC4899);
                    break;
                  default: // Klassik - Sarı
                    waveColor = const Color(0xFFFACC15);
                    break;
                }
                
                return Stack(
                  children: [
                    // Qüllə və ya digər məzmun
                    if (widget.child != null) widget.child!,
                    // İşıq dalğası - yalnız hüceyrə daxilində, istiqamətə görə
                    if (opacity > 0)
                      Positioned.fill(
                        child: ClipRect(
                          child: Transform.translate(
                            offset: translateOffset,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: begin,
                                  end: end,
                                  colors: [
                                    Colors.transparent,
                                    waveColor.withValues(alpha: opacity),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Üçbucaq çəkmək üçün painter
class TrianglePainter extends CustomPainter {
  final Color color;
  
  TrianglePainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Skull çəkmək üçün painter
class SkullPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    
    // Skull forması (sadə versiya)
    // Baş
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 
                     size.width * 0.8, size.height * 0.8),
      paint,
    );
    
    // Göz yuvaları (qara)
    final blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.3, 
                     size.width * 0.15, size.height * 0.2),
      blackPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.3, 
                     size.width * 0.15, size.height * 0.2),
      blackPaint,
    );
    
    // Burun (qara)
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.4, size.height * 0.5, 
                     size.width * 0.2, size.height * 0.15),
      blackPaint,
    );
    
    // Ağız (qara)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.7, 
                       size.width * 0.4, size.height * 0.15),
        const Radius.circular(4),
      ),
      blackPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Triangle neon painter (içi boş, kenarları neon - can barı kenarlarda)
class _TriangleNeonPainter extends CustomPainter {
  final Color color;
  final double healthRatio; // Can barı için (0.0 - 1.0)
  
  _TriangleNeonPainter(this.color, [this.healthRatio = 1.0]);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Triangle'ın üç köşesi
    final top = Offset(size.width / 2, 0);
    final bottomRight = Offset(size.width, size.height);
    final bottomLeft = Offset(0, size.height);
    
    // Tam triangle path'i (siyah border için)
    final fullPath = Path();
    fullPath.moveTo(top.dx, top.dy);
    fullPath.lineTo(bottomRight.dx, bottomRight.dy);
    fullPath.lineTo(bottomLeft.dx, bottomLeft.dy);
    fullPath.close();
    
    // Önce ince siyah border çiz (tam border)
    final blackBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, blackBorderPaint);
    
    if (healthRatio <= 0) return; // Can yoksa neon border çizme
    
    // Triangle'ın üç kenarının uzunlukları
    final edge1Length = (top - bottomRight).distance; // Üst -> Sağ alt
    final edge2Length = (bottomRight - bottomLeft).distance; // Sağ alt -> Sol alt
    final edge3Length = (bottomLeft - top).distance; // Sol alt -> Üst
    final totalPerimeter = edge1Length + edge2Length + edge3Length;
    
    // Görünür uzunluk
    final visibleLength = totalPerimeter * healthRatio;
    
    // Saat yönünde (clockwise) - sağdan başla (saat 3)
    // Triangle'da saat 3 pozisyonu sağ alt köşeden başlar
    // Saat yönünde: sağ alt -> sol alt -> üst -> sağ alt
    final path = Path();
    var currentLength = 0.0;
    
    // Sağ alt köşeden başla (saat 3)
    path.moveTo(bottomRight.dx, bottomRight.dy);
    
    // Kenar 1: Sağ alt -> Sol alt (saat 3 -> saat 9)
    if (currentLength + edge2Length <= visibleLength) {
      path.lineTo(bottomLeft.dx, bottomLeft.dy);
      currentLength += edge2Length;
    } else if (currentLength < visibleLength) {
      final remaining = visibleLength - currentLength;
      final ratio = remaining / edge2Length;
      path.lineTo(
        bottomRight.dx + (bottomLeft.dx - bottomRight.dx) * ratio,
        bottomRight.dy + (bottomLeft.dy - bottomRight.dy) * ratio,
      );
      currentLength = visibleLength;
    }
    
    // Kenar 2: Sol alt -> Üst (saat 9 -> saat 12)
    if (currentLength < visibleLength && currentLength + edge3Length <= visibleLength) {
      path.lineTo(top.dx, top.dy);
      currentLength += edge3Length;
    } else if (currentLength < visibleLength) {
      final remaining = visibleLength - currentLength;
      final ratio = remaining / edge3Length;
      path.lineTo(
        bottomLeft.dx + (top.dx - bottomLeft.dx) * ratio,
        bottomLeft.dy + (top.dy - bottomLeft.dy) * ratio,
      );
      currentLength = visibleLength;
    }
    
    // Kenar 3: Üst -> Sağ alt (saat 12 -> saat 3)
    if (currentLength < visibleLength) {
      final remaining = visibleLength - currentLength;
      final ratio = remaining / edge1Length;
      path.lineTo(
        top.dx + (bottomRight.dx - top.dx) * ratio,
        top.dy + (bottomRight.dy - top.dy) * ratio,
      );
    }
    
    // Shadow - daha hafif ve net
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    // Main border - daha parlak ve net
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Shadow'u önce çiz (arkada)
    canvas.drawPath(path, shadowPaint);
    // Main border'ı sonra çiz (önde)
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _TriangleNeonPainter) {
      return oldDelegate.healthRatio != healthRatio || oldDelegate.color != color;
    }
    return true;
  }
}

// Saat yönünde (clockwise) neon border kaybolma efekti
class _ClockwiseNeonBorderPainter extends CustomPainter {
  final Color color;
  final double healthRatio; // Can barı için (0.0 - 1.0)
  final double borderRadius;
  
  _ClockwiseNeonBorderPainter({
    required this.color,
    required this.healthRatio,
    required this.borderRadius,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    // Tam RRect path'i (siyah border için)
    final fullPath = Path()..addRRect(rrect);
    
    // Önce ince siyah border çiz (tam border)
    final blackBorderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(fullPath, blackBorderPaint);
    
    if (healthRatio <= 0) return; // Can yoksa neon border çizme
    
    // RRect'in tam çevresini hesapla
    final metrics = fullPath.computeMetrics().first;
    final totalLength = metrics.length;
    final visibleLength = totalLength * healthRatio;
    
    // Saat yönünde (clockwise) - sağdan başla (saat 3)
    // RRect path'i saat yönünün tersine (counter-clockwise) çizilir
    // Saat 3'ten (sağ) başlamak için path'i 1/4 (90 derece) kaydır
    // Çünkü: RRect path saat 12'den başlar, saat yönünün tersine gider
    // Saat 3'e gitmek için: 12 -> 3 (saat yönünde) = 1/4 tur
    final quarterLength = totalLength / 4;
    final startOffset = quarterLength; // Saat 3'ten başla
    final endOffset = startOffset + visibleLength;
    
    // Eğer görünür uzunluk çevreyi aşıyorsa, baştan devam et
    Path visiblePath;
    if (endOffset <= totalLength) {
      // Tek parça: startOffset'ten endOffset'e
      visiblePath = metrics.extractPath(startOffset, endOffset);
    } else {
      // İki parça: startOffset'ten sona, sonra baştan kalan kısmına
      final firstPart = metrics.extractPath(startOffset, totalLength);
      final remainingLength = endOffset - totalLength;
      final secondPart = metrics.extractPath(0, remainingLength);
      // Path'leri düzgün birleştir
      visiblePath = Path()
        ..addPath(firstPart, Offset.zero)
        ..addPath(secondPart, Offset.zero);
    }
    
    // Shadow - daha hafif ve net
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    // Main border - daha parlak ve net
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Shadow'u önce çiz (arkada)
    canvas.drawPath(visiblePath, shadowPaint);
    // Main border'ı sonra çiz (önde)
    canvas.drawPath(visiblePath, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _ClockwiseNeonBorderPainter) {
      return oldDelegate.healthRatio != healthRatio || 
             oldDelegate.color != color || 
             oldDelegate.borderRadius != borderRadius;
    }
    return true;
  }
}

