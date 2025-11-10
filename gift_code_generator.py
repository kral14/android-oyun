#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gift Kod Generator - Admin Paneli
Gift kodları oluşturur, Base64 ile şifreler ve JSON formatında kaydeder
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import json
import base64
from datetime import datetime
import os
import shutil

class GiftCodeGenerator:
    def __init__(self, root):
        self.root = root
        self.root.title("Gift Kod Generator - Admin Paneli")
        self.root.geometry("600x700")
        self.root.configure(bg='#1a1a1a')
        
        # Gift kodları saklamak için dosya
        self.gift_codes_file = "gift_codes.json"
        
        # Stil ayarları
        self.setup_styles()
        
        # GUI oluştur
        self.create_widgets()
        
        # Mevcut kodları yükle
        self.load_gift_codes()
    
    def setup_styles(self):
        """GUI stil ayarları"""
        style = ttk.Style()
        style.theme_use('clam')
        
        # Koyu tema renkleri
        style.configure('Dark.TFrame', background='#1a1a1a')
        style.configure('Dark.TLabel', background='#1a1a1a', foreground='#ffffff')
        style.configure('Dark.TEntry', fieldbackground='#2a2a2a', foreground='#ffffff')
        style.configure('Dark.TButton', background='#00ff00', foreground='#000000')
    
    def create_widgets(self):
        """GUI widget'larını oluştur"""
        # Ana frame
        main_frame = ttk.Frame(self.root, style='Dark.TFrame', padding="20")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Başlık
        title_label = tk.Label(
            main_frame,
            text="🎁 Gift Kod Generator",
            font=("Arial", 20, "bold"),
            bg='#1a1a1a',
            fg='#00ff00'
        )
        title_label.pack(pady=(0, 20))
        
        # Gift kod adı
        code_frame = ttk.Frame(main_frame, style='Dark.TFrame')
        code_frame.pack(fill=tk.X, pady=10)
        
        tk.Label(
            code_frame,
            text="Gift Kod Adı:",
            font=("Arial", 12),
            bg='#1a1a1a',
            fg='#ffffff'
        ).pack(side=tk.LEFT, padx=(0, 10))
        
        self.code_name_entry = tk.Entry(
            code_frame,
            font=("Arial", 12),
            bg='#2a2a2a',
            fg='#ffffff',
            insertbackground='#ffffff',
            width=30
        )
        self.code_name_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        # Miktarlar frame
        amounts_frame = ttk.LabelFrame(
            main_frame,
            text="Hediyye Məbləğləri",
            style='Dark.TFrame',
            padding="15"
        )
        amounts_frame.pack(fill=tk.X, pady=10)
        
        # Pul
        self.create_amount_field(amounts_frame, "💰 Pul:", "money")
        
        # Elmas
        self.create_amount_field(amounts_frame, "💎 Elmas:", "diamonds")
        
        # Ulduz
        self.create_amount_field(amounts_frame, "⭐ Ulduz:", "stars")
        
        # Zümrüd
        self.create_amount_field(amounts_frame, "💚 Zümrüd:", "emeralds")
        
        # Butonlar
        button_frame = ttk.Frame(main_frame, style='Dark.TFrame')
        button_frame.pack(fill=tk.X, pady=20)
        
        # Oluştur butonu
        create_btn = tk.Button(
            button_frame,
            text="Gift Kod Oluştur",
            font=("Arial", 12, "bold"),
            bg='#00ff00',
            fg='#000000',
            activebackground='#00cc00',
            activeforeground='#000000',
            command=self.create_gift_code,
            cursor='hand2',
            padx=20,
            pady=10
        )
        create_btn.pack(side=tk.LEFT, padx=5)
        
        # Temizle butonu
        clear_btn = tk.Button(
            button_frame,
            text="Temizle",
            font=("Arial", 12),
            bg='#ff4444',
            fg='#ffffff',
            activebackground='#cc0000',
            activeforeground='#ffffff',
            command=self.clear_fields,
            cursor='hand2',
            padx=20,
            pady=10
        )
        clear_btn.pack(side=tk.LEFT, padx=5)
        
        # Şifrelenmiş kod gösterimi
        result_frame = ttk.LabelFrame(
            main_frame,
            text="Şifrelenmiş Gift Kod",
            style='Dark.TFrame',
            padding="15"
        )
        result_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        self.result_text = scrolledtext.ScrolledText(
            result_frame,
            height=8,
            font=("Courier", 10),
            bg='#2a2a2a',
            fg='#00ff00',
            insertbackground='#ffffff',
            wrap=tk.WORD
        )
        self.result_text.pack(fill=tk.BOTH, expand=True)
        
        # Mevcut kodlar listesi
        list_frame = ttk.LabelFrame(
            main_frame,
            text="Mevcut Gift Kodları",
            style='Dark.TFrame',
            padding="15"
        )
        list_frame.pack(fill=tk.BOTH, expand=True, pady=10)
        
        # Liste ve scrollbar
        list_container = ttk.Frame(list_frame, style='Dark.TFrame')
        list_container.pack(fill=tk.BOTH, expand=True)
        
        scrollbar = tk.Scrollbar(list_container)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.codes_listbox = tk.Listbox(
            list_container,
            font=("Arial", 10),
            bg='#2a2a2a',
            fg='#ffffff',
            selectbackground='#00ff00',
            selectforeground='#000000',
            yscrollcommand=scrollbar.set
        )
        self.codes_listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.config(command=self.codes_listbox.yview)
        
        # Liste butonları
        list_btn_frame = ttk.Frame(list_frame, style='Dark.TFrame')
        list_btn_frame.pack(fill=tk.X, pady=(10, 0))
        
        refresh_btn = tk.Button(
            list_btn_frame,
            text="Yenilə",
            font=("Arial", 10),
            bg='#4444ff',
            fg='#ffffff',
            command=self.load_gift_codes,
            cursor='hand2',
            padx=10,
            pady=5
        )
        refresh_btn.pack(side=tk.LEFT, padx=5)
        
        delete_btn = tk.Button(
            list_btn_frame,
            text="Sil",
            font=("Arial", 10),
            bg='#ff4444',
            fg='#ffffff',
            command=self.delete_gift_code,
            cursor='hand2',
            padx=10,
            pady=5
        )
        delete_btn.pack(side=tk.LEFT, padx=5)
    
    def create_amount_field(self, parent, label_text, field_name):
        """Miktar alanı oluştur"""
        frame = ttk.Frame(parent, style='Dark.TFrame')
        frame.pack(fill=tk.X, pady=5)
        
        tk.Label(
            frame,
            text=label_text,
            font=("Arial", 11),
            bg='#1a1a1a',
            fg='#ffffff',
            width=15,
            anchor='w'
        ).pack(side=tk.LEFT, padx=(0, 10))
        
        entry = tk.Entry(
            frame,
            font=("Arial", 11),
            bg='#2a2a2a',
            fg='#ffffff',
            insertbackground='#ffffff',
            width=20
        )
        entry.pack(side=tk.LEFT)
        entry.insert(0, "0")
        
        # Entry'yi sakla
        setattr(self, f"{field_name}_entry", entry)
    
    def create_gift_code(self):
        """Gift kod oluştur"""
        # Değerleri al
        code_name = self.code_name_entry.get().strip()
        
        if not code_name:
            messagebox.showerror("Xəta", "Zəhmət olmasa gift kod adı daxil edin!")
            return
        
        try:
            money = int(self.money_entry.get() or "0")
            diamonds = int(self.diamonds_entry.get() or "0")
            stars = int(self.stars_entry.get() or "0")
            emeralds = int(self.emeralds_entry.get() or "0")
        except ValueError:
            messagebox.showerror("Xəta", "Məbləğlər yalnız rəqəm ola bilər!")
            return
        
        if money == 0 and diamonds == 0 and stars == 0 and emeralds == 0:
            messagebox.showerror("Xəta", "Ən azı bir məbləğ daxil edin!")
            return
        
        # Gift kod objesi oluştur
        gift_code_data = {
            "id": f"gift_{datetime.now().strftime('%Y%m%d%H%M%S')}",
            "code": code_name.lower().strip(),
            "name": code_name,
            "money": money,
            "diamonds": diamonds,
            "stars": stars,
            "emeralds": emeralds,
            "is_used": False,
            "created_at": datetime.now().isoformat()
        }
        
        # JSON'a çevir
        json_data = json.dumps(gift_code_data, ensure_ascii=False, indent=2)
        
        # Base64 ile şifrele
        encoded_bytes = base64.b64encode(json_data.encode('utf-8'))
        encoded_string = encoded_bytes.decode('utf-8')
        
        # Sonucu göster
        result = f"""Gift Kod: {code_name}
Məbləğlər:
  💰 Pul: {money}
  💎 Elmas: {diamonds}
  ⭐ Ulduz: {stars}
  💚 Zümrüd: {emeralds}

Şifrelenmiş Kod (Base64):
{encoded_string}

JSON Formatı:
{json_data}

Flutter'da Kullanım:
Oyunda '{code_name}' kodunu girin.
"""
        self.result_text.delete(1.0, tk.END)
        self.result_text.insert(1.0, result)
        
        # Dosyaya kaydet
        self.save_gift_code(gift_code_data, encoded_string)
        
        messagebox.showinfo("Uğur", f"Gift kod '{code_name}' uğurla yaradıldı!")
        
        # Listeyi yenile
        self.load_gift_codes()
    
    def save_gift_code(self, gift_code_data, encoded_string):
        """Gift kodunu dosyaya kaydet"""
        # Mevcut kodları yükle
        if os.path.exists(self.gift_codes_file):
            with open(self.gift_codes_file, 'r', encoding='utf-8') as f:
                codes = json.load(f)
        else:
            codes = []
        
        # Yeni kodu ekle
        codes.append({
            **gift_code_data,
            "encoded": encoded_string
        })
        
        # Dosyaya kaydet
        with open(self.gift_codes_file, 'w', encoding='utf-8') as f:
            json.dump(codes, f, ensure_ascii=False, indent=2)
        
        # Flutter assets klasörüne de kopyala
        self.copy_to_flutter_assets()
    
    def copy_to_flutter_assets(self):
        """gift_codes.json dosyasını Flutter assets klasörüne kopyala"""
        try:
            # Flutter assets klasörü yolu
            flutter_assets_dir = os.path.join('assets')
            flutter_assets_file = os.path.join(flutter_assets_dir, 'gift_codes.json')
            
            # Assets klasörü yoksa oluştur
            if not os.path.exists(flutter_assets_dir):
                os.makedirs(flutter_assets_dir)
            
            # Dosyayı kopyala
            if os.path.exists(self.gift_codes_file):
                shutil.copy2(self.gift_codes_file, flutter_assets_file)
                print(f"✓ Gift kodları Flutter assets klasörüne kopyalandı: {flutter_assets_file}")
        except Exception as e:
            print(f"⚠ Flutter assets klasörüne kopyalama hatası: {e}")
    
    def load_gift_codes(self):
        """Mevcut gift kodlarını yükle"""
        self.codes_listbox.delete(0, tk.END)
        
        if os.path.exists(self.gift_codes_file):
            with open(self.gift_codes_file, 'r', encoding='utf-8') as f:
                codes = json.load(f)
            
            for code in codes:
                code_name = code.get('name', code.get('code', 'Unknown'))
                money = code.get('money', 0)
                diamonds = code.get('diamonds', 0)
                stars = code.get('stars', 0)
                emeralds = code.get('emeralds', 0)
                is_used = code.get('is_used', False)
                
                status = "✓ İstifadə edilib" if is_used else "○ Aktiv"
                display_text = f"{code_name} - 💰{money} 💎{diamonds} ⭐{stars} 💚{emeralds} [{status}]"
                self.codes_listbox.insert(tk.END, display_text)
    
    def delete_gift_code(self):
        """Seçili gift kodunu sil"""
        selection = self.codes_listbox.curselection()
        if not selection:
            messagebox.showwarning("Xəbərdarlıq", "Zəhmət olmasa silmək istədiyiniz kodu seçin!")
            return
        
        if messagebox.askyesno("Təsdiq", "Bu gift kodu silmək istədiyinizə əminsiniz?"):
            index = selection[0]
            
            if os.path.exists(self.gift_codes_file):
                with open(self.gift_codes_file, 'r', encoding='utf-8') as f:
                    codes = json.load(f)
                
                if 0 <= index < len(codes):
                    codes.pop(index)
                    
                    with open(self.gift_codes_file, 'w', encoding='utf-8') as f:
                        json.dump(codes, f, ensure_ascii=False, indent=2)
                    
                    self.load_gift_codes()
                    messagebox.showinfo("Uğur", "Gift kod silindi!")
    
    def clear_fields(self):
        """Alanları temizle"""
        self.code_name_entry.delete(0, tk.END)
        self.money_entry.delete(0, tk.END)
        self.money_entry.insert(0, "0")
        self.diamonds_entry.delete(0, tk.END)
        self.diamonds_entry.insert(0, "0")
        self.stars_entry.delete(0, tk.END)
        self.stars_entry.insert(0, "0")
        self.emeralds_entry.delete(0, tk.END)
        self.emeralds_entry.insert(0, "0")
        self.result_text.delete(1.0, tk.END)


def main():
    root = tk.Tk()
    app = GiftCodeGenerator(root)
    root.mainloop()


if __name__ == "__main__":
    main()

