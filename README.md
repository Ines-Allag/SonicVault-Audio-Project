# 🔐 SonicVault

> A secure biometric-gated audio player built with Flutter & Firebase.
> Stream, protect, and personalize your listening experience.

![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?style=flat-square&logo=flutter)

message.txt
3 KB
﻿
# 🔐 SonicVault

> A secure biometric-gated audio player built with Flutter & Firebase.
> Stream, protect, and personalize your listening experience.

![Flutter](https://img.shields.io/badge/Flutter-3.x-54C5F8?style=flat-square&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart)

---

## About

SonicVault is a mobile audio application combining enterprise-grade security with a fluid listening experience. It leverages fingerprint biometrics for access control, Firebase for cloud-synced favorites and authentication, and a dynamic playlist engine powered by an external audio API — all wrapped in a clean dark interface with real-time listening statistics.

---

## Features

| Feature | Description |
|---|---|
| **Biometric Gate** | Fingerprint auth on launch. Redirects to system settings if no print enrolled. Plays a success sound on unlock. |
| **Firebase Auth** | Sign up, login, and password reset. Age validation (13+). Stores name, surname, and birthdate. |
| **Stats Dashboard** | Total listening time, daily histogram for current month, top tracks list, and a configurable monthly goal progress bar. |
| **Audio Player** | Background playback, dynamic playlists by category from external API, play / pause / repeat. |
| **Cloud Favorites** | Save favorites to Firestore, synced across devices. Biometric confirmation required to remove a track. |

---

## Tech Stack

- **Framework:** Flutter 3.x / Dart
- **Backend:** Firebase Auth, Cloud Firestore
- **Biometrics:** `local_auth`
- **Audio:** `just_audio`, `audio_service`
- **Charts:** `fl_chart`
- **Local Storage:** `shared_preferences`
- **API:** [Quran Audio API](https://quran.yousefheiba.com/en)

---

## Project Structure

```
lib/
├── core/             # theme, constants, utils
├── features/
│   ├── auth/         # biometric + firebase auth
│   ├── player/       # audio playback, playlist
│   ├── stats/        # dashboard, charts
│   └── favorites/    # cloud-synced favorites
├── models/           # data models
├── services/         # firebase, audio API, biometrics
└── main.dart
```

---

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/sonicvault.git
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to their respective platform folders. Enable **Authentication** and **Firestore** in your Firebase console.

4. **Run**
   ```bash
   flutter run
   ```

---

## Requirements

- Flutter SDK ≥ 3.0
- Android 6.0+ / iOS 11+ (for biometric support)
- A physical device or emulator with fingerprint capability
  message.txt
  3 KB
