# 📖 Daily Diary App

A secure, offline-first personal diary app built with **Flutter**. It keeps your entries private with biometric lock, stores everything locally in SQLite, supports photos and voice notes, and reminds you to write every day.

---

## 📱 Features

- 🔐 **Biometric lock**: protect your diary with fingerprint or face recognition (`local_auth`)
- 🗄️ **Offline storage**: fast local persistence with SQLite (`sqflite`)
- 🖼️ **Photos**: attach multiple images to an entry (`image_picker`)
- 🎙️ **Voice notes**: record and play back audio (`record`, `audioplayers`)
- ⏰ **Daily reminders**: custom-time notifications (`flutter_local_notifications`, `timezone`)
- 🎨 **Material 3 UI**: clean, responsive design with `provider` state management

---

## 🛠️ Tech Stack

| Area | Technology |
|------|------------|
| Framework | Flutter (Dart 3.x) |
| State management | Provider |
| Database | sqflite |
| Security | local_auth |
| Notifications | flutter_local_notifications, timezone |
| Media | image_picker, record, audioplayers |

---

## 🏗️ Project Structure

```text
lib/
├── core/            # Services & helpers (database, notifications, biometrics)
├── models/          # Data models
├── providers/       # State management
├── views/
│   ├── screens/     # Home, Add/Edit Entry, Settings, Lock screen
│   └── widgets/     # Reusable components
└── main.dart        # App entry point
```

---

## 🚀 Getting Started

### Prerequisites

Install these first:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel, Dart 3+)
- [Android Studio](https://developer.android.com/studio) (with Android SDK) or VS Code with the Flutter extension
- JDK 17
- Git

Check that everything is set up correctly:

```bash
flutter doctor
```

Fix any issues it reports before continuing.

### 1. Clone the repository

```bash
git clone https://github.com/ChamodyaIshani99/daily-diary-app.git
cd daily-diary-app
```

> If the Flutter project is inside a sub-folder, `cd` into that folder (the one containing `pubspec.yaml`).

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Connect a device

- **Emulator**: start an Android Virtual Device from Android Studio (Device Manager), or
- **Physical phone**: enable *Developer options* → *USB debugging*, then connect via USB.

Confirm the device is detected:

```bash
flutter devices
```

### 4. Run the app

```bash
flutter run
```

If you hit build errors from old cached files:

```bash
flutter clean
flutter pub get
flutter run
```

## 🔑 Android Permissions

The app uses these permissions (already declared in `android/app/src/main/AndroidManifest.xml`):

- `USE_BIOMETRIC` – fingerprint / face unlock
- `RECORD_AUDIO` – voice notes
- `POST_NOTIFICATIONS` – daily reminders (Android 13+)
- `SCHEDULE_EXACT_ALARM` – reminders at an exact time
- Camera / Photos access – attaching images

Grant them when the app asks, or reminders, voice notes, and image attachments won't work.

---

## ❓ Troubleshooting

| Problem | Fix |
|---------|-----|
| `flutter: command not found` | Add Flutter's `bin` folder to your PATH, then reopen the terminal |
| Gradle / Java version error | Make sure JDK 17 is installed and `JAVA_HOME` points to it |
| Android licenses error | Run `flutter doctor --android-licenses` and accept all |
| Reminders not showing | Allow notification and exact alarm permission in phone settings; disable battery optimization for the app |
| Biometric not working on emulator | Set up a fingerprint in the emulator's Security settings first |


---

## 🤝 Contributing

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

---
