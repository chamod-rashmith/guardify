# Guardify Product Roadmap 🗺️

This document outlines the strategic future development roadmap for **Guardify**. It serves as a vision and tracking tool for forthcoming enhancements across Code Generation, Access Control Features, UI/UX Fallback Strategies, Framework Integrations, and Compliance Tooling.

---

## 🎯 Strategic Milestones Overview

```
 [v1.0.0] Current Release ──► [v1.1.0] CodeGen Core & AST ──► [v1.2.0] UI Fallbacks & UX
                                                                       │
 [v2.0.0] Enterprise CLI ◄── [v1.4.0] Navigation & Reactive ◄── [v1.3.0] PBAC & Telemetry
```

---

## 🚀 Detailed Phase Breakdown

### 📍 Phase 1: Code Generator Core & AST Modernization (`v1.1.0`)
*Focus: Bulletproof code generation, generic support, compile-time guardrails, and AST formatting.*

- [x] **Generic Widget Support**: Support generic type parameters on annotated widget classes (e.g. `class UserTable<T> extends StatelessWidget`).
  ```dart
  // Generated wrapper preserves <T>
  class SecuredUserTable<T> extends StatelessWidget { ... }
  ```
- [x] **Enum & Constant Role Extraction**: Support passing enums in `@Secured` (e.g., `@Secured([UserRole.admin])`) without missing string values.
- [x] **Strict AST Compile-Time Guardrails**:
  - Validate that annotated elements extend `Widget` (throw `InvalidGenerationSourceError` if applied to standard classes).
  - Ensure `allowedRoles` is not empty.
- [x] **`code_builder` & `dart_style` Migration**: Transition from manual string interpolation to `code_builder` AST generation for formatted code output.

---

### 📍 Phase 2: Rich UI Fallback Strategies & Visual Feedback (`v1.2.0`)
*Focus: Flexible user feedback modes for SaaS and enterprise Flutter applications.*

- [ ] **Expanded `FallbackType` Strategies**:
  - `FallbackType.disabled`: Displays the widget with reduced opacity (`0.5`) and disables interaction using `AbsorbPointer`.
  - `FallbackType.tooltip`: Shows the disabled widget wrapped in a `Tooltip` explaining missing access rights.
  - `FallbackType.blur`: Renders a blurred backdrop filter with a lock icon overlay.
- [ ] **Global Fallback Builder**: Register a default fallback UI builder inside `GuardifyScope`:
  ```dart
  GuardifyScope(
    currentRole: 'guest',
    fallbackBuilder: (context, widgetName, requiredRoles) {
      return CustomLockedWidgetCard(widgetName: widgetName);
    },
    child: const MyApp(),
  );
  ```

---

### 📍 Phase 3: Permission-Based Access Control (PBAC) & Telemetry (`v1.3.0`)
*Focus: Fine-grained permissions, feature flags, and security auditing.*

- [ ] **Permission-Based Access Control (PBAC)**: Support action permissions alongside roles:
  ```dart
  @Secured(['admin'], permissions: ['users.delete', 'users.export'])
  ```
- [ ] **Feature Toggles**: Combine role checks with feature flags (`@Secured(['admin'], featureFlag: 'beta_v2')`).
- [ ] **Audit & Telemetry Logging**: Add an `onAccessDenied` callback to `GuardifyScope` for analytics/security log tracking:
  ```dart
  GuardifyScope(
    onAccessDenied: (widgetName, requiredRoles) {
      analytics.logEvent('UNAUTHORIZED_ACCESS_ATTEMPT', parameters: {'widget': widgetName});
    },
    child: const MyApp(),
  );
  ```

---

### 📍 Phase 4: Navigation & Reactive State Integrations (`v1.4.0`)
*Focus: Router guards and seamless auth state binding.*

- [ ] **Route Guards (`GoRouter` / `AutoRoute`)**: Provide a `GuardifyRouteGuard` helper for page-level access control.
  ```dart
  GoRoute(
    path: '/admin',
    redirect: GuardifyRouteGuard(allowedRoles: ['admin'], fallbackPath: '/forbidden'),
    builder: (context, state) => const AdminScreen(),
  );
  ```
- [ ] **Reactive Scopes**: Introduce `GuardifyNotifierScope` and `GuardifyStreamScope` to auto-rebuild UI when authentication state changes.

---

### 📍 Phase 5: Security Compliance Tooling & Test Helpers (`v2.0.0`)
*Focus: Automated security audits and widget testing utilities.*

- [ ] **Access Control Matrix (ACM) CLI Tool**: Command-line generator that scans `@Secured` annotations and exports a markdown/JSON compliance matrix.
- [ ] **`GuardifyTestScope`**: Unit/Widget testing utility for mocking active roles effortlessly during `flutter_test` runs:
  ```dart
  await tester.pumpWidget(
    GuardifyTestScope(
      role: 'admin',
      child: const SecuredAdminButton(),
    ),
  );
  ```

---

## 💬 Community Feedback & Contributions

Suggestions, feature requests, and PRs are welcome! Feel free to open an issue or start a discussion on our GitHub repository.
