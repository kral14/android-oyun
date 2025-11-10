import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

// Gift kod modeli
class GiftCode {
  final String id;
  final String code;
  final String name;
  final int? money;
  final int? diamonds;
  final int? stars;
  final int? emeralds;
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  
  GiftCode({
    required this.id,
    required this.code,
    required this.name,
    this.money,
    this.diamonds,
    this.stars,
    this.emeralds,
    this.isUsed = false,
    this.usedBy,
    this.usedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'money': money,
      'diamonds': diamonds,
      'stars': stars,
      'emeralds': emeralds,
      'is_used': isUsed,
      'used_by': usedBy,
      'used_at': usedAt?.toIso8601String(),
    };
  }
  
  factory GiftCode.fromJson(Map<String, dynamic> json) {
    return GiftCode(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      money: json['money'] as int?,
      diamonds: json['diamonds'] as int?,
      stars: json['stars'] as int?,
      emeralds: json['emeralds'] as int?,
      isUsed: json['is_used'] as bool? ?? false,
      usedBy: json['used_by'] as String?,
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at'] as String) : null,
    );
  }
}

// Gift kod servisi
class GiftCodeService {
  // PostgreSQL bağlantı string'i
  static const String dbUrl = 'postgresql://neondb_owner:npg_SxvR6sZIK9yi@ep-sparkling-grass-a4c444kf-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require';
  
  // API endpoint (backend API oluşturulduğunda kullanılacak)
  static const String apiBaseUrl = 'https://your-api-url.com/api';
  
  // Gift kod şifreleme
  static String encryptCode(String code) {
    final bytes = utf8.encode(code);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Gift kod doğrulama (HTTP API üzerinden)
  static Future<Map<String, dynamic>> validateGiftCode(String code, String userId) async {
    try {
      // Şifrelenmiş kodu gönder
      final encryptedCode = encryptCode(code.toLowerCase().trim());
      
      // Backend API'ye istek gönder
      final response = await http.post(
        Uri.parse('$apiBaseUrl/gift-codes/validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': encryptedCode,
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'gift_code': GiftCode.fromJson(data['gift_code'] as Map<String, dynamic>),
        };
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'message': error['message'] as String? ?? 'Gift kod tapılmadı',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Xəta: ${e.toString()}',
      };
    }
  }
  
  // Gift kod kullanımı kaydet (HTTP API üzerinden)
  static Future<Map<String, dynamic>> useGiftCode(String code, String userId) async {
    try {
      final encryptedCode = encryptCode(code.toLowerCase().trim());
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/gift-codes/use'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': encryptedCode,
          'user_id': userId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'gift_code': GiftCode.fromJson(data['gift_code'] as Map<String, dynamic>),
          'rewards': data['rewards'] as Map<String, dynamic>?,
        };
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': false,
          'message': error['message'] as String? ?? 'Gift kod istifadə edilə bilmədi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Xəta: ${e.toString()}',
      };
    }
  }
  
  // Yerel test için (JSON dosyasından okuma veya SharedPreferences)
  static Future<Map<String, dynamic>> validateGiftCodeLocal(String code) async {
    try {
      final codeLower = code.toLowerCase().trim();
      
      // Önce kullanılmış mı kontrol et
      final isUsed = await isGiftCodeUsed(codeLower);
      if (isUsed) {
        return {
          'success': false,
          'message': 'Bu gift kod artıq istifadə edilib',
        };
      }
      
      // Test kodlarına bak
      return await _validateTestCode(codeLower);
    } catch (e) {
      return {
        'success': false,
        'message': 'Xəta: ${e.toString()}',
      };
    }
  }
  
  // JSON dosyasından okuma - Python GUI'den oluşturulan gift_codes.json dosyasını okur
  static Future<Map<String, dynamic>> validateGiftCodeFromJson(String code) async {
    try {
      final codeLower = code.toLowerCase().trim();
      
      // Önce assets'ten okumayı dene
      try {
        final jsonString = await rootBundle.loadString('assets/gift_codes.json');
        final codes = jsonDecode(jsonString) as List<dynamic>;
        
        final giftCodeData = codes.firstWhere(
          (c) => (c as Map<String, dynamic>)['code'] == codeLower,
          orElse: () => null,
        );
        
        if (giftCodeData != null) {
          final giftCode = GiftCode.fromJson(giftCodeData as Map<String, dynamic>);
          
          if (giftCode.isUsed) {
            return {
              'success': false,
              'message': 'Bu gift kod artıq istifadə edilib',
            };
          }
          
          return {
            'success': true,
            'gift_code': giftCode,
          };
        }
      } catch (e) {
        // Assets dosyası yoksa devam et
      }
      
      // Assets dosyası yoksa, SharedPreferences'tan oku (Python GUI'den kopyalanan kodlar)
      try {
        final prefs = await SharedPreferences.getInstance();
        final giftCodesJson = prefs.getString('gift_codes_data') ?? '[]';
        final codes = jsonDecode(giftCodesJson) as List<dynamic>;
        
        final giftCodeData = codes.firstWhere(
          (c) => (c as Map<String, dynamic>)['code'] == codeLower,
          orElse: () => null,
        );
        
        if (giftCodeData != null) {
          final giftCode = GiftCode.fromJson(giftCodeData as Map<String, dynamic>);
          
          if (giftCode.isUsed) {
            return {
              'success': false,
              'message': 'Bu gift kod artıq istifadə edilib',
            };
          }
          
          return {
            'success': true,
            'gift_code': giftCode,
          };
        }
      } catch (e) {
        // SharedPreferences'ta yoksa devam et
      }
      
      return {
        'success': false,
        'message': 'Gift kod tapılmadı',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Xəta: ${e.toString()}',
      };
    }
  }
  
  // Python GUI'den oluşturulan gift kodlarını yükle (SharedPreferences'a kaydet)
  static Future<void> loadGiftCodesFromJson(String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gift_codes_data', jsonString);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
  
  // Test kodları (fallback) - Python GUI'den oluşturulan kodlar buraya eklenecek
  static Future<Map<String, dynamic>> _validateTestCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Önce JSON dosyasından okumayı dene
    try {
      final jsonResult = await validateGiftCodeFromJson(code);
      if (jsonResult['success'] == true) {
        return jsonResult;
      }
    } catch (e) {
      // JSON dosyası yoksa test kodlarına bak
    }
    
    // Python GUI'den oluşturulan gift_codes.json dosyasından okunacak
    // Şimdilik test kodları
    final testCodes = {
      'hediyye5': {
        'id': '1',
        'code': 'hediyye5',
        'name': 'Hediyye 5',
        'money': 1000,
        'diamonds': 50,
        'stars': 25,
        'emeralds': 10,
        'is_used': false,
      },
    };
    
    final giftCodeData = testCodes[code];
    
    if (giftCodeData != null) {
      return {
        'success': true,
        'gift_code': GiftCode.fromJson(giftCodeData),
      };
    }
    
    return {
      'success': false,
      'message': 'Gift kod tapılmadı',
    };
  }
  
  // Gift kod kullanımını kaydet (lokal)
  static Future<void> markGiftCodeAsUsed(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usedCodesJson = prefs.getString('used_gift_codes') ?? '[]';
      final usedCodes = (jsonDecode(usedCodesJson) as List).cast<String>();
      
      if (!usedCodes.contains(code.toLowerCase().trim())) {
        usedCodes.add(code.toLowerCase().trim());
        await prefs.setString('used_gift_codes', jsonEncode(usedCodes));
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
  
  // Gift kod kullanılmış mı kontrol et
  static Future<bool> isGiftCodeUsed(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usedCodesJson = prefs.getString('used_gift_codes') ?? '[]';
      final usedCodes = (jsonDecode(usedCodesJson) as List).cast<String>();
      return usedCodes.contains(code.toLowerCase().trim());
    } catch (e) {
      return false;
    }
  }
}

