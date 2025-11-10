import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

// Import flutter_inappwebview for all platforms
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Import yeni oyun
import 'package:neon_defender/game/neon_defender_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Landscape orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Hide system UI for fullscreen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const NeonDefenderApp());
}

class NeonDefenderApp extends StatelessWidget {
  const NeonDefenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Defender',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0a84ff),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: false,
      ),
      // home: const AuthWrapper(), // Login sistemi
      home: const NeonDefenderGameScreen(), // Defender oyunu
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('towerDefenseLoggedIn') ?? false;
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error checking login status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Web platformunda WebView dəstəklənmir
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Web platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Android-da run etmək üçün:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'flutter run -d android',
                style: TextStyle(color: Color(0xFF0a84ff), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Windows platformunda WebView dəstəklənmir (NuGet tələb edir)
    if (!kIsWeb && Platform.isWindows) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Windows platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Android-da run etmək üçün:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'flutter run -d android',
                style: TextStyle(color: Color(0xFF0a84ff), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a84ff)),
          ),
        ),
      );
    }

    if (_isLoggedIn) {
      return const GameScreen();
    } else {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Windows üçün WebView dəstəklənmir
class _LoginScreenState extends State<LoginScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _showRegister = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || (!kIsWeb && Platform.isWindows)) {
      // Web və Windows üçün WebView dəstəklənmir
      _isLoading = false;
    }
  }

  Future<void> _loadLoginPage() async {
    if (_webViewController == null) return;

    try {
      final filePath = _showRegister
          ? 'assets/pages/register.html'
          : 'assets/pages/login.html';

      // Load file using rootBundle and loadData
      final htmlContent = await rootBundle.loadString(filePath);
      await _webViewController!.loadData(
        data: htmlContent,
        mimeType: 'text/html',
        encoding: 'utf8',
      );
    } catch (e) {
      debugPrint('Error loading login page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web platformunda WebView dəstəklənmir
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Web platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Windows platformunda WebView dəstəklənmir
    if (Platform.isWindows) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Windows platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialFile: _showRegister
                ? 'assets/pages/register.html'
                : 'assets/pages/login.html',
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              useShouldOverrideUrlLoading: true,
              supportZoom: false,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              // Register JavaScript handlers
              controller.addJavaScriptHandler(
                handlerName: 'onLoginSuccess',
                callback: (args) async {
                  // Save login status
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('towerDefenseLoggedIn', true);
                  widget.onLoginSuccess();
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'showRegister',
                callback: (args) {
                  setState(() {
                    _showRegister = true;
                  });
                  _loadLoginPage();
                },
              );
              controller.addJavaScriptHandler(
                handlerName: 'showLogin',
                callback: (args) {
                  setState(() {
                    _showRegister = false;
                  });
                  _loadLoginPage();
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });
              // Inject API URL and Flutter handlers
              await _injectFlutterHandlers();
            },
            onReceivedError: (controller, request, error) {
              debugPrint('WebView error: ${error.description}');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a84ff)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _injectFlutterHandlers() async {
    if (_webViewController == null) return;

    final js = '''
      (function() {
        // Set API URL
        window.API_BASE_URL = 'https://oyun-yeni.onrender.com/api';
        
        // Flutter handler bridge
        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
          // Handler already available
        } else {
          window.flutter_inappwebview = {
            callHandler: function(handlerName, args) {
              if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                return window.flutter_inappwebview.callHandler(handlerName, args);
              }
            }
          };
        }
      })();
    ''';

    await _webViewController!.evaluateJavascript(source: js);
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

// Windows üçün WebView dəstəklənmir

class _GameScreenState extends State<GameScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadWebAsset() async {
    if (_webViewController == null || !kIsWeb) return;
    
    try {
      await _webViewController!.loadUrl(
        urlRequest: URLRequest(
          url: WebUri('/assets/games/neondefender/index.html'),
        ),
      );
    } catch (e) {
      debugPrint('Error loading web asset: $e');
      try {
        final htmlContent = await rootBundle.loadString('assets/games/neondefender/index.html');
        final baseUrl = WebUri('/assets/games/neondefender/');
        
        await _webViewController!.loadData(
          data: htmlContent,
          baseUrl: baseUrl,
          mimeType: 'text/html',
          encoding: 'utf8',
        );
      } catch (e2) {
        debugPrint('Error loading asset with loadData: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Web platformunda WebView dəstəklənmir
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Web platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Windows platformunda WebView dəstəklənmir
    if (Platform.isWindows) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Windows platformunda WebView dəstəklənmir',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Android və ya iOS-da test edin',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a84ff)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: kIsWeb ? null : null,
            initialFile: kIsWeb ? null : 'assets/games/neondefender/index.html',
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              databaseEnabled: true,
              useShouldOverrideUrlLoading: true,
              useOnLoadResource: true,
              useOnDownloadStart: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              iframeAllow: 'camera; microphone',
              iframeAllowFullscreen: true,
              supportZoom: false,
              disableHorizontalScroll: false,
              disableVerticalScroll: false,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
              transparentBackground: true,
            ),
            onWebViewCreated: (controller) async {
              _webViewController = controller;
              if (kIsWeb) {
                await _loadWebAsset();
              }
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });
              await _injectMobileOptimizations();
            },
            onReceivedError: (controller, request, error) {
              debugPrint('WebView error: ${error.description}');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0a84ff)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _injectMobileOptimizations() async {
    if (_webViewController == null) return;
    
    final js = '''
      (function() {
        // Disable text selection
        document.addEventListener('touchstart', function(e) {
          if (e.target.tagName !== 'INPUT' && e.target.tagName !== 'TEXTAREA') {
            e.preventDefault();
          }
        }, {passive: false});
        
        // Prevent zoom on double tap
        var lastTouchEnd = 0;
        document.addEventListener('touchend', function(e) {
          var now = Date.now();
          if (now - lastTouchEnd <= 300) {
            e.preventDefault();
          }
          lastTouchEnd = now;
        }, false);
        
        // Set viewport meta tag if not exists
        if (!document.querySelector('meta[name=viewport]')) {
          var meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        
        // Platform flags
        window.isFlutterApp = true;
        window.isAndroidApp = ${!kIsWeb && Platform.isAndroid ? 'true' : 'false'};
        window.isIOSApp = ${!kIsWeb && Platform.isIOS ? 'true' : 'false'};
        window.isWindowsApp = ${!kIsWeb && Platform.isWindows ? 'true' : 'false'};
        window.isWebApp = ${kIsWeb ? 'true' : 'false'};
      })();
    ''';
    
    await _webViewController!.evaluateJavascript(source: js);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
