#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Deploy Script - Otomatik Git Commit ve Push
Her çalıştırmada değişiklikleri commit edip GitHub'a gönderir
"""

import subprocess
import sys
from datetime import datetime
import os

def run_command(command, check=True):
    """Komut çalıştır ve sonucu döndür"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            check=check
        )
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except subprocess.CalledProcessError as e:
        return e.stdout.strip(), e.stderr.strip(), e.returncode

def get_git_status():
    """Git durumunu kontrol et"""
    stdout, stderr, code = run_command("git status --porcelain", check=False)
    return stdout, code

def deploy():
    """Deploy işlemini gerçekleştir"""
    print("=" * 60)
    print("🚀 Deploy Script Başlatılıyor...")
    print("=" * 60)
    
    # Git repository kontrolü
    if not os.path.exists(".git"):
        print("❌ Hata: Bu klasör bir Git repository değil!")
        print("   Önce 'git init' komutunu çalıştırın.")
        sys.exit(1)
    
    # Git durumunu kontrol et
    print("\n📊 Git durumu kontrol ediliyor...")
    status_output, status_code = get_git_status()
    
    if not status_output and status_code == 0:
        print("ℹ️  Değişiklik yok, commit edilecek bir şey bulunamadı.")
        print("   Yine de push yapmak istiyor musunuz? (y/n): ", end="")
        choice = input().strip().lower()
        if choice != 'y':
            print("❌ Deploy iptal edildi.")
            sys.exit(0)
    
    # Tüm değişiklikleri ekle
    print("\n➕ Tüm değişiklikler ekleniyor...")
    stdout, stderr, code = run_command("git add .", check=False)
    if code != 0:
        print(f"❌ Hata: git add başarısız oldu!")
        print(f"   {stderr}")
        sys.exit(1)
    print("✓ Tüm dosyalar eklendi")
    
    # Commit mesajı oluştur
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    commit_message = f"Auto deploy: {timestamp}"
    
    # Commit yap
    print(f"\n💾 Commit yapılıyor: '{commit_message}'...")
    stdout, stderr, code = run_command(f'git commit -m "{commit_message}"', check=False)
    
    if code != 0:
        if "nothing to commit" in stderr.lower() or "nothing to commit" in stdout.lower():
            print("ℹ️  Commit edilecek değişiklik yok.")
        else:
            print(f"❌ Hata: git commit başarısız oldu!")
            print(f"   {stderr}")
            sys.exit(1)
    else:
        print("✓ Commit başarılı")
        print(f"   {stdout}")
    
    # Remote kontrolü
    print("\n🌐 Remote repository kontrol ediliyor...")
    stdout, stderr, code = run_command("git remote -v", check=False)
    if code != 0 or not stdout:
        print("❌ Hata: Remote repository bulunamadı!")
        print("   Önce 'git remote add origin <url>' komutunu çalıştırın.")
        sys.exit(1)
    print(f"✓ Remote bulundu:\n{stdout}")
    
    # Branch adını al
    stdout, stderr, code = run_command("git branch --show-current", check=False)
    branch = stdout.strip() if stdout else "main"
    if not branch:
        branch = "main"
    
    # Push yap
    print(f"\n📤 GitHub'a push yapılıyor (branch: {branch})...")
    stdout, stderr, code = run_command(f"git push -u origin {branch}", check=False)
    
    if code != 0:
        # Eğer branch henüz oluşturulmamışsa, önce oluştur
        if "no upstream branch" in stderr.lower() or "branch" in stderr.lower():
            print("ℹ️  Branch henüz oluşturulmamış, oluşturuluyor...")
            stdout, stderr, code = run_command(f"git push -u origin {branch}", check=False)
        
        if code != 0:
            print(f"❌ Hata: git push başarısız oldu!")
            print(f"   {stderr}")
            print("\n💡 İpucu: GitHub kimlik doğrulaması gerekebilir.")
            print("   Personal Access Token kullanmanız gerekebilir.")
            sys.exit(1)
    
    print("✓ Push başarılı!")
    print(f"   {stdout}")
    
    # Başarı mesajı
    print("\n" + "=" * 60)
    print("✅ Deploy başarıyla tamamlandı!")
    print("=" * 60)
    print(f"\n📅 Tarih: {timestamp}")
    print(f"🌿 Branch: {branch}")
    print(f"🔗 Repository: https://github.com/kral14/android-oyun.git")
    print("\n")

if __name__ == "__main__":
    try:
        deploy()
    except KeyboardInterrupt:
        print("\n\n❌ Deploy kullanıcı tarafından iptal edildi.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Beklenmeyen hata: {e}")
        sys.exit(1)

