# Plan B — Auth Google + Tamu (Tahap 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dua jalur masuk berfungsi — Google Sign-In (Firebase Auth) dan Tamu (lokal Hive murni), dengan guard rute, upgrade tamu→Google, dan baris akun di Profil.

**Architecture:** AuthRepository sebagai satu pintu; status sesi `signedOut|guest|google` persist di Hive box `session`. Tamu TIDAK memakai Firebase anonymous — semua data lokal (Hive box habits/weights/daily_logs). Login Google → data tamu di-batch migrate ke `users/{uid}/...` Firestore (merge), Firestore offline persistence ON.

**Tech Stack:** firebase_core, firebase_auth, google_sign_in, cloud_firestore, hive_ce, flutter_riverpod, go_router.

**Spec:** `design/index.html` frame 01 (Google & Tamu) + frame 08 Profil; keputusan user: "Tamu itu kesimpen di local".

## Global Constraints

- Package `com.rochwidias.notedhealth`; SHA-1 debug `40:4B:65:C2:92:83:A5:90:5A:8F:17:13:01:68:BD:01:E2:7E:5B:39` (di console Firebase)
- **Interaksi user (sekali):** `firebase login` di browser + tambah SHA-1 di Firebase console + `flutterfire configure`
- Firestore rules: hanya owner `request.auth.uid == uid` (set via console/deploy nanti)
- Skema Firestore: `users/{uid}`, `users/{uid}/weights/{autoId}` (date `YYYY-MM-DD` string), `users/{uid}/habits/{autoId}`, `users/{uid}/daily_logs/{YYYY-MM-DD}`
- Val: berat 20–300 kg, judul habit ≥3 char, bobot 1–100
- Error → snackbar + retry; `flutter analyze` 0 issue; `flutter test` lolos

---

### Task 1: Firebase project + flutterfire ⚠️ butuh user

- [ ] `npm i -g firebase-tools` → `firebase login` (**browser user, sekali**)
- [ ] `dart pub global activate flutterfire_cli` → tambah `%LOCALAPPDATA%\Pub\Cache\bin` ke PATH user
- [ ] `flutterfire configure --project notedhealth-… --platforms android` di root project — Expected: `android/app/google-services.json` + `lib/firebase_options.dart`

### Task 2: SHA-1 ⚠️ user manual
- [ ] Kasih user link console + nilai SHA-1; tunggu konfirmasi

### Task 3: Dependensi Firebase
- [ ] `flutter pub add firebase_core firebase_auth google_sign_in cloud_firestore`
- [ ] `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` + `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)` di main

### Task 4: Model + sesi
**Files:** Create `lib/models/{habit,weight,daily_log}.dart`, `lib/features/auth/auth_session.dart`
- [ ] Model toMap/fromMap (tanpa codegen)
- [ ] `enum AuthStatus { signedOut, guest, google }` + `AuthSessionNotifier extends Notifier<AuthStatus>` — persist `{mode}` ke Hive box `session`, load saat init

### Task 5: AuthRepository
**Files:** Create `lib/features/auth/auth_repository.dart`
- [ ] `Future<void> continueAsGuest()` — tulis box session mode=guest, TANPA panggil Firebase
- [ ] `Future<void> signInWithGoogle()` — GoogleSignIn().authenticate() → GoogleAuthProvider.credential → signInWithCredential → simpan mode=google (uid tersimpan utk skema Firestore)
- [ ] `Future<void> upgradeGuestToGoogle()` — baca box habits/weights/daily_logs → batch tulis ke users/{uid}/{collection} (merge, jangan duplikat) → tandai upgraded
- [ ] `Future<void> signOut()` (Firebase + session→signedOut), `Future<void> deleteAccount()` (hapus doc users/{uid} recursive + local clear; google only)

### Task 6: Guard rute
**Files:** Modify `lib/app/router.dart`
- [ ] `redirect:` — session==signedOut → /login (kecuali di /login), else → /home
- [ ] Session init: baca Hive box sebelum router aktif (FutureBuilder di app root / router refreshListenable via Riverpod)

### Task 7: Wiring login
**Files:** Modify `login_screen.dart`
- [ ] Tombol Google → loading overlay → ok: upgrade if guest+signIn → /home; gagal/batal → snackbar (pesan ID, tombol coba lagi)
- [ ] Tombol Tamu → continueAsGuest → /home

### Task 8: Profil akun
**Files:** Modify `lib/features/profile/`
- [ ] Baris akun: google → avatar+nama+email; guest → "Mode tamu" + "Data lokal di perangkat"
- [ ] Keluar → dialog konfirmasi → signOut → /login
- [ ] Hapus akun → dialog → deleteAccount (google only; guest sembunyikan tombol / ganti "Hapus data lokal")

### Task 9: Verifikasi
- [ ] Unit: session persist (hive temp), router redirect matrix (signedOut/guest/google × /login /home)
- [ ] Widget: tap Tamu → shell; `flutter analyze` + `flutter test`
- [ ] Manual: Google Sign-In flow di emulator (butuh SHA-1 + akun Google user)

**Setelah B:** Plan C (habit CRUD + checklist + skor harian) → D (berat + BMI + grafik) → E (dashboard + notifikasi) → F (APK).
