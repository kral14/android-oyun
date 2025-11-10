#!/usr/bin/env python3
"""
GitHub-a push etmək üçün Python script
Bu script bütün dəyişiklikləri add edir, commit edir və GitHub-a push edir.
"""

import subprocess
import sys
import os
from datetime import datetime

def run_command(command, description):
    """Git komandasini icra edir ve neticeni gosterir"""
    print(f"\n[*] {description}...")
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            capture_output=True,
            text=True
        )
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"[X] Xeta: {e}")
        if e.stderr:
            print(f"Xeta mesaji: {e.stderr}")
        return False

def main():
    """Əsas funksiya"""
    print("=" * 60)
    print("GitHub-a Push Script")
    print("=" * 60)
    
    # Git repository yoxla
    if not os.path.exists('.git'):
        print("[X] Bu qovluq Git repository deyil!")
        sys.exit(1)
    
    # Remote repository yoxla
    print("\n[*] Remote repository yoxlanilir...")
    result = subprocess.run(
        "git remote -v",
        shell=True,
        capture_output=True,
        text=True
    )
    if result.returncode != 0 or not result.stdout:
        print("[X] Remote repository tapilmadi!")
        print("Git remote elave edin: git remote add origin https://github.com/kral14/android-oyun.git")
        sys.exit(1)
    
    print("[OK] Remote repository tapildi:")
    print(result.stdout)
    
    # Status yoxla
    print("\n[*] Git status yoxlanilir...")
    status_result = subprocess.run(
        "git status --short",
        shell=True,
        capture_output=True,
        text=True
    )
    
    if not status_result.stdout.strip():
        print("[i] Commit edilecek deyisiklik yoxdur.")
        # Yəni bütün dəyişikliklər artıq commit edilib
        # Yalnız push edək
        if run_command("git push origin main", "GitHub-a push edilir"):
            print("\n[OK] Kod ugurla GitHub-a push edildi!")
            return
    else:
        print("[*] Tapilan deyisiklikler:")
        print(status_result.stdout)
    
    # Bütün faylları add et
    if not run_command("git add .", "Butun deyisiklikler add edilir"):
        print("[X] Add emeliyyati ugursuz oldu!")
        sys.exit(1)
    
    # Commit mesajı yarat
    commit_message = f"Update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    
    # Commit et
    if not run_command(
        f'git commit -m "{commit_message}"',
        "Deyisiklikler commit edilir"
    ):
        print("[X] Commit emeliyyati ugursuz oldu!")
        sys.exit(1)
    
    # Push et
    if not run_command("git push origin main", "GitHub-a push edilir"):
        print("[X] Push emeliyyati ugursuz oldu!")
        print("\n[Teklif]:")
        print("   - Git credentials yoxlayin")
        print("   - Branch adini yoxlayin (main/master)")
        print("   - Remote repository URL-i yoxlayin")
        sys.exit(1)
    
    print("\n" + "=" * 60)
    print("[OK] Kod ugurla GitHub-a push edildi!")
    print("=" * 60)
    print(f"\nRepository: https://github.com/kral14/android-oyun.git")
    print(f"Commit zamani: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    main()

