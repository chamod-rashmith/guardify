# Guardify 🛡️

A powerful, type-safe **Role-Based UI Access Control (RBAC)** code generation package for Flutter apps using `build`, `source_gen`, and `analyzer`.

[![pub package](https://img.shields.io/pub/v/guardify.svg)](https://pub.dev/packages/guardify)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-blue.svg)](https://flutter.dev)

---

## ✨ Features

- 🛡️ **Annotation-Based Code Generation**: Simply annotate any Flutter widget with `@Secured(['admin'])`.
- ⚡ **Zero Prop-Drilling**: Ambient role state resolution via `GuardifyScope` (InheritedWidget).
- 🎨 **Flexible Fallback UI Strategies**:
  - `FallbackType.hide`: Silently hides unauthorized widgets (`SizedBox.shrink()`). Perfect for buttons & cards.
  - `FallbackType.scaffold`: Renders a full "Access Denied" page for screens.
  - `FallbackType.text`: Displays an inline error text widget.
  - **Runtime Override**: Pass custom `fallback: MyWidget()` dynamically at runtime.
- 👥 **Multi-Role Support**: Easily configure `requireAll: true` or single/multiple active roles.
- 🔑 **Custom Permission Checker**: Plug in custom auth callbacks (Firebase Auth, JWT claims, dynamic rules).
- 🚀 **BuildContext Extensions**: Query permissions directly in code using `context.hasRole('admin')`.
- 📦 **Full Parameter Forwarding**: Automatically forwards all required/optional, positional/named constructor parameters.

---

## 🚀 Getting Started

### Add Dependencies

Add `guardify` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  guardify: ^1.1.3

dev_dependencies:
  build_runner: ^2.4.0
```

Run `flutter pub get` to install.

---

## 💻 Usage

### 1. Annotate Your Widgets

Annotate any `StatelessWidget` or `StatefulWidget` with `@Secured`:

```dart
import 'package:flutter/material.dart';
import 'package:guardify/guardify.dart';

part 'my_widgets.secured.g.dart';

// 1. Delete Button (Hides automatically for unauthorized users)
@Secured(['admin', 'superadmin'], fallback: FallbackType.hide)
class DeleteUserButton extends StatelessWidget {
  final String userId;
  final VoidCallback onDelete;

  const DeleteUserButton({
    super.key,
    required this.userId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onDelete,
      child: Text('Delete User $userId'),
    );
  }
}

// 2. Admin Screen (Shows full Access Denied page for unauthorized users)
@Secured(['admin'], fallback: FallbackType.scaffold)
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Admin Panel')),
    );
  }
}
```

---

### 2. Generate Code

Run `build_runner` to generate the `.secured.g.dart` file:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> **Pro Tip**: Use `watch` mode during development for auto-generation on file save:
> ```bash
> dart run build_runner watch --delete-conflicting-outputs
> ```

---

### 3. Wrap Your App with `GuardifyScope`

Wrap your app or widget tree with `GuardifyScope` to supply ambient role state:

```dart
void main() {
  runApp(
    GuardifyScope(
      currentRole: 'admin', // Active user role (e.g. from Auth Store)
      child: const MyApp(),
    ),
  );
}
```

---

### 4. Use Generated Secured Widgets

Instantiate the generated **`Secured<ClassName>`** widgets cleanly without prop-drilling:

```dart
//  Zero prop-drilling! Automatically reads active role from GuardifyScope
SecuredDeleteUserButton(
  userId: 'usr_8890',
  onDelete: () => deleteUser('usr_8890'),
);

//  Secured Screen
SecuredAdminDashboardScreen();
```

---

## 🎨 Fallback UI Strategies

| Strategy | Behavior | Typical Use Case |
|---|---|---|
| `FallbackType.hide` *(default)* | Renders `const SizedBox.shrink()` | Buttons, Action Icons, Cards, Dialogs |
| `FallbackType.scaffold` | Renders a full "Access Denied" Scaffold page | Full App Pages / Screens |
| `FallbackType.text` | Renders an inline `'Access Denied'` Text widget | Form Fields, Table Rows |
| `fallback: CustomWidget()` | Overrides fallback UI dynamically at runtime | Tooltips, Locked Containers |

---

## 🔑 BuildContext Extensions

Use `BuildContext` helper extensions anywhere in your widget tree:

```dart
// Check if user has specific role
if (context.hasRole('admin')) {
  // Navigate to Admin Settings
}

// Check if user has any of the listed roles
if (context.hasAnyRole(['admin', 'manager'])) {
  // Perform manager action
}

// Check if user has all specified roles
if (context.hasAllRoles(['manager', 'finance'])) {
  // Access financial reports
}
```

---

## 🛡️ Custom Permission Checker Callback

Connect custom authentication rules (such as Firebase Auth Claims or JWT permissions):

```dart
GuardifyScope(
  permissionChecker: (allowedRoles, {requireAll = false}) {
    return myAuthService.canUserAccess(allowedRoles);
  },
  child: const MyApp(),
)
```

---

## 🗺️ Roadmap

Interested in upcoming features, UI fallback expansion, or security audit tooling? Check out our detailed [ROADMAP.md](ROADMAP.md) to see planned milestones for future releases.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

