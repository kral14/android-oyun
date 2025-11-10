# Gift Kod Generator - Kullanım Kılavuzu

## Kurulum

1. Python 3.x yüklü olmalıdır
2. Tkinter genellikle Python ile birlikte gelir (Linux'ta `python3-tk` paketi gerekebilir)

## Kullanım

### Gift Kod Oluşturma

1. `gift_code_generator.py` dosyasını çalıştırın:
   ```bash
   python gift_code_generator.py
   ```

2. Gift Kod Adı alanına kod adını girin (örn: `hediyye5`)

3. İstediğiniz miktarları girin:
   - 💰 Pul
   - 💎 Elmas
   - ⭐ Ulduz
   - 💚 Zümrüd

4. "Gift Kod Oluştur" butonuna tıklayın

5. Şifrelenmiş kod otomatik olarak oluşturulur ve gösterilir

### Gift Kod Formatı

Gift kodlar `gift_codes.json` dosyasında saklanır. Her kod şu bilgileri içerir:

```json
{
  "id": "gift_20241201120000",
  "code": "hediyye5",
  "name": "Hediyye 5",
  "money": 1000,
  "diamonds": 50,
  "stars": 25,
  "emeralds": 10,
  "is_used": false,
  "created_at": "2024-12-01T12:00:00",
  "encoded": "Base64 şifrelenmiş kod"
}
```

### Flutter'da Kullanım

Flutter uygulamasında gift kodları kullanmak için:

1. `gift_codes.json` dosyasını Flutter projesine ekleyin
2. Gift kod servisi bu dosyayı okuyup doğrulayacak
3. Base64 şifrelenmiş kodları decode edip kullanacak

## Özellikler

- ✅ Gift kod oluşturma
- ✅ Base64 şifreleme
- ✅ JSON formatında kaydetme
- ✅ Mevcut kodları listeleme
- ✅ Kod silme
- ✅ Kullanım durumu takibi

