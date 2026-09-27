# Plan A — Setup & Fondasi NotedHealth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flutter SDK terinstall, project `com.rochwidias.notedhealth` jalan di emulator dengan tema mockup + shell 4 tab + layar login statis.

**Architecture:** Flutter 3.x stable (D:\flutter) + Riverpod (state) + go_router (rute) + hive_ce (lokal) + flutter_svg (ikon custom). Semua visual disalin dari mockup `design/` (design tokens, SVG sprite, font OFL).

**Tech Stack:** Flutter stable, Dart 3, flutter_riverpod, go_router, hive_ce, hive_ce_flutter, flutter_svg.

**Spec:** `design/index.html` + `design/styles.css` (mockup disetujui user) — plan ini berargumen dari mockup.

## Global Constraints

- Package: `com.rochwidias.notedhealth` (project name `notedhealth`), path `D:\project-app\notedhealth.app`
- Folder `design/` = referensi read-only, JANGAN dimodifikasi/dihapus
- Font bundle: Plus Jakarta Sans + Fredoka (SIL OFL 1.1) di `assets/fonts/`
- Ikon: SVG dari sprite mockup (`design/index.html` symbol i-*) → `assets/icons/*.svg` via flutter_svg — JANGAN pakai Icons Material
- Palet mockup: primary #7C5CFF, primary-ink #5638DB, accent #FFD64A, success #12855B, danger #D13A40, bg terang #FAF7F2, bg gelap #16131F, surface gelap #221D31; radius kartu 24–32
- Bahasa UI Indonesia; `flutter analyze` 0 issue; `flutter test` lolos
- Deps tahap ini: flutter_riverpod, go_router, hive_ce, hive_ce_flutter, flutter_svg (Firebase/fl_chart di Plan B/C — YAGNI)

---

### Task 1: Install Flutter SDK

**Files:** none (sistem); PATH user `D:\flutter\bin`

- [ ] **Step 1: Clone Flutter stable** — `git clone https://github.com/flutter/flutter.git -b stable --depth 1 D:\flutter` (timeout besar, ~1-2GB)
- [ ] **Step 2: Tambah PATH user** — `[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path","User") + ";D:\flutter\bin", "User")` lalu set `$env:Path += ";D:\flutter\bin"` untuk sesi ini
- [ ] **Step 3: `flutter --version`** (download Dart SDK first run) — Expected: versi stable 3.x
- [ ] **Step 4: `flutter doctor`** — Expected: Android SDK ✓, JDK ✓, git ✓, VS Code (ext menyusul), Chrome/CLI
- [ ] **Step 5: `code --install-extension Dart-Code.dart-code`** — Expected: "successfully installed"

### Task 2: Init project Git + Flutter

**Files:** Create: pubspec.yaml, android/, lib/, test/, .gitignore (bawaan)

- [ ] **Step 1:** `git init` di `D:\project-app\notedhealth.app`
- [ ] **Step 2:** `flutter create --org com.rochwidias --project-name notedhealth .` — Expected: android/app/build.gradle applicationId `com.rochwidias.notedhealth`; `design/` tak tersentuh
- [ ] **Step 3:** Commit awal `git add -A && git commit -m "chore: flutter create skeleton"`

### Task 3: Dependensi inti

- [ ] **Step 1:** `flutter pub add flutter_riverpod go_router hive_ce hive_ce_flutter flutter_svg` — Expected: pubspec berisi 5 deps + resolved versions
- [ ] **Step 2:** `flutter pub get` OK

### Task 4: Font OFL + ekstrak ikon

**Files:** Create: `assets/fonts/*.ttf`, `assets/icons/*.svg`, `tools/extract_icons.js`

- [ ] **Step 1:** Unduh variabel TTF dari github.com/google/fonts (raw): `ofl/fredoka/Fredoka[wdth,wght].ttf`, `ofl/plusjakartasans/PlusJakartaSans[wght].ttf` → `assets/fonts/`
- [ ] **Step 2:** pubspec `flutter: fonts:` family `PlusJakartaSans` + `Fredoka`, `assets: assets/icons/`
- [ ] **Step 3:** `tools/extract_icons.js` — parse `<symbol id="i-.*">…</symbol>` dari `design/index.html`, tulis ulang isi path/bulanatan ke `assets/icons/<name>.svg` (xmlns + viewBox di-export, `currentColor` dipertahankan)
- [ ] **Step 4:** jalankan `node tools/extract_icons.js` — Expected: ~32 file svg

### Task 5: Tema

**Files:** Create: `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`

- [ ] **Step 1:** `AppColors` (light/dark) — konstanta palet mockup di Global Constraints
- [ ] **Step 2:** `AppTheme.light()`/`AppTheme.dark()` — ColorScheme.fromSeed tidak dipakai; set manual; CardTheme radius 24, input 18; ElevatedButton radius 16; text theme family PlusJakartaSans; angka besar `Fredoka` via helper `TextStyle(fontFamily:'Fredoka')` (`AppText.display`)
- [ ] **Step 3:** `MaterialApp.router(theme:, darkTheme:, themeMode: ThemeMode.system)` di `lib/main.dart`

### Task 6: Router + shell 4 tab

**Files:** Create: `lib/app/router.dart`, `lib/features/shell/home_shell.dart`; Modify: `lib/main.dart`

- [ ] **Step 1:** `GoRouter(routes: [StatefulShellRoute.indexedStack(branches: /home→Beranda, /checklist, /weight, /profile) , GoRoute(/login)])`
- [ ] **Step 2:** `HomeShell` = Scaffold + NavigationBar 4 destinasi (ikon dari assets/icons, label ID: Beranda/Checklist/Berat/Profil)
- [ ] **Step 3:** placeholder per tab: `PlaceholderScreen(title)` — cukup judul appbar + teks "segera"

### Task 7: Layar login statis (frame 01)

**Files:** Create: `lib/features/auth/login_screen.dart`

- [ ] **Step 1:** Copy-on layout mockup: logo (i-logo svg), h1 "NotedHealth", copy "Masuk dengan Google, atau coba sebagai Tamu dulu.", kartu preview 3 baris (Skor harian / Timbang berat / Katalog sehat), tombol "Masuk dengan Google" (ikon i-google), divider "atau", tombol ghost "Masuk sebagai Tamu" (i-user), foot "Google: tersimpan aman di akunmu · Tamu: lokal di perangkat ini."
- [ ] **Step 2:** Tombol sementara `context.go('/home')` (wiring sesungguhnya di Plan B)
- [ ] **Step 3:** `svg_asset(icon)` helper → SvgPicture.asset('assets/icons/x.svg', colorFilter: ColorFilter.mode(warna, BlendMode.srcIn))

### Task 8: Verifikasi

- [ ] **Step 1:** `flutter analyze` — Expected: No issues found
- [ ] **Step 2:** `flutter test` — Expected: all passed (ganti widget_test bawaan: test login screen renders)
- [ ] **Step 3:** Start emulator `emulator -avd Pixel_10a` → `flutter run` — Expected: login screen tampil di emulator, tab bisa pindah
- [ ] **Step 4:** Commit `feat: fondasi app — tema, rute, shell 4 tab, layar login`
