# 🎓 Shafeea Student (أكاديمية شفيع)

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

Shafeea Student is the official mobile application for **Shafeea Academy**, a comprehensive educational platform designed to empower students in their learning journey. Built with Flutter, the app provides a seamless, high-performance experience for tracking academic progress, accessing religious resources (including a full Quran reader), and managing daily educational activities.

---

## 🚀 Key Features

- **📱 User-Friendly Dashboard**: A centralized hub for students to view their progress and upcoming tasks.
- **📖 Integrated Quran Reader**: High-quality digital Quran with custom fonts and specialized reading modes.
- **📊 Daily Tracking**: Detailed logging and visualization of daily academic and spiritual activities.
- **🌓 Dynamic Theming**: Full support for light and dark modes with a premium aesthetic.
- **🌍 Localization**: Optimized for Arabic-speaking users with full RTL (Right-to-Left) support.
- **🔒 Secure Authentication**: Robust login system with device-aware security.

---

## 🛠️ Technology Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) |
| **State Management** | [BLoC / Cubit](https://pub.dev/packages/flutter_bloc) |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) |
| **Dependency Injection** | [Injectable](https://pub.dev/packages/injectable) / [GetIt](https://pub.dev/packages/get_it) |
| **Networking** | [Dio](https://pub.dev/packages/dio) |
| **Database** | [SQLite (sqflite)](https://pub.dev/packages/sqflite) |
| **Charts** | [FL Chart](https://pub.dev/packages/fl_chart) |

---

## 📂 Project Structure

```text
lib/
├── config/             # App configuration (DI, Routes, Themes, L10n)
├── core/               # Shared core logic (Network, Errors, UseCases)
├── features/           # Feature-based modules
│   ├── app/            # App-wide logic and setup
│   ├── auth/           # Authentication and User Management
│   ├── daily_tracking/ # Progress and activity tracking
│   ├── home/           # Main dashboard and core features
│   └── settings/       # User preferences and app settings
├── routes/             # Navigation routing definitions
├── shared/             # Reusable UI components and widgets
└── main.dart           # App entry point
```

---

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/your-username/shafeea_student.git
   cd shafeea_student
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Generate code (Injectable & BloC):**

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**

   ```bash
   flutter run
   ```

---

## ⚙️ Configuration

The app uses JSON configuration files for different environments:

- `config_dev.json`: Development environment settings.
- `config_prod.json`: Production environment settings (API URL, etc.).

Ensure these files are present in the root directory before building for production.

---

## 🤝 Contribution

Contributions are welcome! Please follow these steps:

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📬 Contact

**Emran Nasser** - [GitHub](https://github.com/emran-nasser)

Project Link: [https://github.com/shafeea-platform/shafeea_student](https://github.com/shafeea-platform/shafeea_student)

---
*Created with ❤️ by the Shafeea Development Team*
