# Guardify 🛡️

A powerful, type-safe **Role-Based UI Access Control (RBAC)** and **Permission-Based Access Control (PBAC)** framework for Flutter apps, offering both **Annotation-Based Code Generation** and **Zero-Boilerplate Runtime Widgets**.

[![pub package](https://img.shields.io/pub/v/guardify.svg)](https://pub.dev/packages/guardify)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-SDK-blue.svg)](https://flutter.dev)

---

## 🔒 Security Best Practices & Architectural Notice

> [!IMPORTANT]
> **Client-Side UI Gating vs. Server-Side Enforcement (Defense in Depth)**
>
> **Guardify** is designed for the **Presentation Layer (UI/UX)**:
> - It prevents unauthorized UI components from rendering or executing client-side callbacks (`onPressed`, `onTap`).
> - It delivers smooth, clean UX by hiding restricted buttons, displaying disabled states with lock badges, and handling route redirects before screens mount.
> 
> **However, client-side code runs on user-controlled hardware and can theoretically be inspected or manipulated:**
> - **Never rely exclusively on client-side UI gating for data security.**
> - **Server-Side Enforcement is Mandatory**: Sensitive data operations, database queries, and mutation endpoints (e.g. DELETE / POST API calls) must **always** be authenticated and authorized on the backend server or cloud security layer (e.g., Firebase Security Rules, Supabase Row-Level Security (RLS), Node.js / Go / Spring Boot JWT claim validators).
> - **Verified Claims**: Always supply `currentRole`, `currentRoles`, or `currentPermissions` to `GuardifyScope` from cryptographically verified authentication sources (such as verified JWT token claims, Firebase Auth Custom Claims, or Auth0 access tokens).
> - **Secure by Default**: Guardify follows the principle of least privilege—if roles or permissions do not match, or if `GuardifyScope` is missing from the tree, access is safely **denied** by default.

---

## ✨ Features

- 🛡️ **Dual-Mode Access Control**:
  - **Runtime Widget (`RoleGate` / `SecuredFeature`)**: Protect any Flutter or 3rd-party widget on-the-fly with **Zero `build_runner` required**.
  - **Code Generation (`@Secured`)**: Type-safe, component-level security policies declared on widget classes.
- ⚡ **Zero Prop-Drilling**: Ambient role & permission state resolution via `GuardifyScope` (`InheritedWidget`).
- 🔄 **Reactive State Binding**: Connect directly to `ValueListenable`, `ChangeNotifier`, or `Stream` using `GuardifyScope.listenable` or `GuardifyScope.stream` for automatic rebuilds on auth changes.
- 🎨 **Flexible Fallback UI Strategies**:
  - `FallbackType.hide` *(default)*: Silently hides unauthorized widgets (`const SizedBox.shrink()`).
  - `FallbackType.disabled`: Disables user interactions (`AbsorbPointer`) with reduced opacity and optional lock overlay icon.
  - `FallbackType.scaffold`: Renders a full "Access Denied" page for screens.
  - `FallbackType.text`: Displays an inline error text widget.
  - **Dynamic Fallback Builders**: Pass `fallbackBuilder: (context, missingRoles, missingPerms) => ...` locally on widgets or globally in `GuardifyScope`.
- 👥 **Multi-Role & PBAC Support**: Configure roles and fine-grained permissions (`requireAll: true/false`).
- 🧭 **Route Guard for Navigation**: Easily secure routes with `GuardifyRouteGuard` or `guardifyRedirect` (compatible with `go_router` and Navigator).
- 🔑 **Custom Permission Checker**: Plug in custom auth callbacks (Firebase Auth, JWT claims, dynamic rules).
- 📊 **Access Control Matrix (ACM) CLI**: Scan codebase (`@Secured` & `RoleGate`) and generate security audit matrices in Markdown, Console, or JSON.
- 🚀 **BuildContext Extensions**: Query authorization directly in code using `context.hasRole('admin')` or `context.hasPermission('users:delete')`.
- 🛡️ **Variable Shadowing Immunity**: Code generator safely isolates internal variables to avoid any parameter collisions.

---

## 🚀 Getting Started

### Add Dependencies

Add `guardify` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  guardify: ^1.2.0

dev_dependencies:
  build_runner: ^2.4.0 # Optional: only needed if using @Secured code generation
```

Run `flutter pub get` to install.

---

## 💻 Usage

### 1. Wrap Your App with `GuardifyScope`

Wrap your app or widget tree with `GuardifyScope` to supply active user roles and permissions:

```dart
void main() {
  runApp(
    GuardifyScope(
      currentRole: 'admin',
      currentPermissions: const {'users:delete', 'reports:export'},
      child: const MyApp(),
    ),
  );
}
```

#### Reactive Auth Binding with `GuardifyScope.listenable`
Automatically rebuilds descendant scope widgets whenever your auth notifier changes (no `setState` required):

```dart
GuardifyScope.listenable(
  listenable: authStateNotifier, // ValueNotifier<String?>
  child: const MyApp(),
)
```

---

### 2. Choose Your Gating Mode

#### Option A: Zero-Boilerplate Runtime Widget (`RoleGate`)
No code generation required! Guard any widget directly:

```dart
// 1. Silently hide for unauthorized users
RoleGate(
  allowedRoles: const ['admin'],
  child: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
)

// 2. Disabled mode with lock overlay badge (e.g. Freemium / Pro features)
RoleGate(
  allowedRoles: const ['premium'],
  fallbackType: FallbackType.disabled,
  lockBadge: const CircleAvatar(
    backgroundColor: Colors.black87,
    child: Icon(Icons.lock, color: Colors.amber),
  ),
  child: ElevatedButton(onPressed: exportReport, child: const Text('Export PDF')),
)

// 3. Dynamic context-aware fallback builder
RoleGate(
  allowedRoles: const ['editor'],
  fallbackBuilder: (context, missingRoles, missingPerms) {
    return UpgradeBanner(requiredRole: missingRoles.first);
  },
  child: const EditArticleToolbar(),
)
```

#### Option B: Annotation-Based Code Generation (`@Secured`)
Ideal for design systems, reusable button kits, and enterprise component governance:

```dart
part 'my_widgets.secured.g.dart';

@Secured(['admin', 'superadmin'], fallback: FallbackType.hide)
class DeleteUserButton extends StatelessWidget {
  final String userId;
  final VoidCallback onDelete;

  const DeleteUserButton({super.key, required this.userId, required this.onDelete});

  @override
  Widget build(BuildContext context) => ElevatedButton(...);
}
```

Run build runner to generate `.secured.g.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Then instantiate cleanly with zero prop-drilling:
```dart
SecuredDeleteUserButton(
  userId: 'usr_100',
  onDelete: () => deleteUser('usr_100'),
);
```

---

### 3. Route & Navigation Guards (`go_router` / Navigator)

Prevent unauthorized users from entering protected screens at the router level:

```dart
GoRoute(
  path: '/admin',
  redirect: GuardifyRouteGuard(
    allowedRoles: const ['admin'],
    fallbackPath: '/unauthorized',
  ),
  builder: (context, state) => const AdminScreen(),
);
```

Or perform an inline redirect check:
```dart
final redirect = guardifyRedirect(
  context,
  allowedRoles: const ['manager'],
  fallbackPath: '/unauthorized',
);

if (redirect != null) {
  // Handle redirect or show notification
}
```

---

### 4. BuildContext Extensions

Use `BuildContext` helper extensions anywhere in your widget tree:

```dart
// Role checks
if (context.hasRole('admin')) { ... }
if (context.hasAnyRole(['admin', 'manager'])) { ... }
if (context.hasAllRoles(['manager', 'finance'])) { ... }

// Permission checks (PBAC)
if (context.hasPermission('users:delete')) { ... }
if (context.hasAnyPermission(['reports:view', 'reports:export'])) { ... }
if (context.hasAllPermissions(['posts:read', 'posts:write'])) { ... }
```

---

### 5. Fallback UI Strategies

| Strategy | Behavior | Typical Use Case |
|---|---|---|
| `FallbackType.hide` *(default)* | Renders `const SizedBox.shrink()` | Inline buttons, list actions |
| `FallbackType.disabled` | Renders with `AbsorbPointer`, reduced opacity, & optional lock badge | Freemium / Pro features |
| `FallbackType.scaffold` | Full-screen "Access Denied" page with AppBar | Restricted screens / pages |
| `FallbackType.text` | Renders inline error text message | Form fields, tables |
| `fallbackBuilder` | Dynamic context-aware builder receiving missing roles & permissions | Custom upgrade banners |

---

### 6. Security Audit: Access Control Matrix (ACM) CLI Tool 📊

Guardify comes with an AST-powered command-line audit scanner. It scans your Flutter codebase for `@Secured` annotations and `RoleGate`/`SecuredFeature` runtime widgets, producing an Access Control Matrix (ACM) report for compliance and security documentation.

```bash
# Print audit matrix directly in your terminal
dart run guardify:matrix

# Generate Markdown table for documentation or pull request reviews
dart run guardify:matrix --format=markdown --output=SECURITY_MATRIX.md

# Export JSON for CI/CD compliance validation pipelines
dart run guardify:matrix --format=json --output=matrix.json
```

#### CLI Options

| Flag | Shorthand | Description | Default |
|---|---|---|---|
| `--path` | `-p` | Directory or file path to scan | `lib` |
| `--output` | `-o` | Destination file path to save report | Prints to stdout |
| `--format` | `-f` | Output format: `console`, `markdown`, `json` | `console` |
| `--verbose` | `-v` | Prints diagnostic scan details | `false` |
| `--help` | `-h` | Displays usage instructions | |

---

## 🛡️ Custom Permission Checker Callback

Connect external authentication engines or custom claim evaluators:

```dart
GuardifyScope(
  permissionChecker: (allowedRoles, {requireAll = false, activeRoles, allowedPermissions, activePermissions}) {
    return myAuthService.evaluate(
      allowedRoles: allowedRoles,
      allowedPermissions: allowedPermissions,
    );
  },
  child: const MyApp(),
)
```

---

## 🗺️ Roadmap

Check out our detailed [ROADMAP.md](ROADMAP.md) to explore upcoming features including compliance CLI tools and automated test scopes.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
