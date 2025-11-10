#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gift Kod Loader - Python GUI'den oluşturulan kodları Flutter'a aktarır
"""

import json
import os

def load_gift_codes_for_flutter():
    """gift_codes.json dosyasını oku ve Flutter formatına çevir"""
    gift_codes_file = "gift_codes.json"
    
    if not os.path.exists(gift_codes_file):
        print("gift_codes.json dosyası bulunamadı!")
        return None
    
    with open(gift_codes_file, 'r', encoding='utf-8') as f:
        codes = json.load(f)
    
    # Flutter için Dart kodu oluştur
    dart_code = "  // Python GUI'den oluşturulan gift kodları\n"
    dart_code += "  static final Map<String, Map<String, dynamic>> _giftCodes = {\n"
    
    for code in codes:
        code_name = code.get('code', '').lower()
        dart_code += f"    '{code_name}': {{\n"
        dart_code += f"      'id': '{code.get('id', '')}',\n"
        dart_code += f"      'code': '{code.get('code', '')}',\n"
        dart_code += f"      'name': '{code.get('name', '')}',\n"
        dart_code += f"      'money': {code.get('money', 0)},\n"
        dart_code += f"      'diamonds': {code.get('diamonds', 0)},\n"
        dart_code += f"      'stars': {code.get('stars', 0)},\n"
        dart_code += f"      'emeralds': {code.get('emeralds', 0)},\n"
        dart_code += f"      'is_used': {str(code.get('is_used', False)).lower()},\n"
        dart_code += "    },\n"
    
    dart_code += "  };\n"
    
    return dart_code

if __name__ == "__main__":
    dart_code = load_gift_codes_for_flutter()
    if dart_code:
        print("Flutter için Dart kodu:")
        print("=" * 50)
        print(dart_code)
        print("=" * 50)
        print("\nBu kodu lib/game/gift_code_service.dart dosyasındaki")
        print("_validateTestCode metodundaki testCodes map'ine ekleyin.")

