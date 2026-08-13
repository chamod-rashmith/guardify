# Guardify Product Roadmap 🗺️

This document outlines the strategic future development roadmap for **Guardify**. It serves as a vision and tracking tool for forthcoming enhancements across Code Generation, Access Control Features, UI/UX Fallback Strategies, Framework Integrations, and Compliance Tooling.

---

## 🎯 Strategic Milestones Overview

```
 [v1.0.0/v1.1.0] Current Release ──► [v1.2.0] UI Fallbacks, Overlay & Transitions
                                                                │
 [v2.0.0] Compliance & CLI Tooling ◄── [v1.4.0] Navigation & Reactive ◄── [v1.3.0] PBAC, ABAC & Telemetry
```

---

## 🚀 Detailed Phase Breakdown

### 📍 Phase 1: Code Generator Core & AST Modernization (`v1.1.0` - Completed ✅)
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

### 📍 Phase 2: Rich UI Fallback Strategies, Lock Overlays & Animated Transitions (`v1.2.0` - Completed ✅)
*Focus: Flexible user feedback modes, disabled lock overlays, dynamic fallback builders, and smooth visual transitions for Flutter applications.*

- [x] **Built-in `FallbackType.disabled` with Lock Overlay**:
  - Automatically wraps child widgets with `AbsorbPointer` and reduced opacity (e.g., `0.5`).
  - Supports optional lock badge/overlay icon (e.g., `showLockBadge: true`, custom lock icon) out-of-the-box without requiring custom container wrappers.
- [x] **Dynamic `fallbackBuilder` Callback**:
  - Allow passing a context-aware fallback builder function both locally (`@Secured` / `SecuredFeature`) and globally in `GuardifyScope`.
  - Passes missing roles/permissions to the builder so developers can render context-aware UIs (e.g., subscription upgrade banners):
  ```dart
  // Local widget-level fallback builder
  SecuredFeature(
    allowedRoles: const ['premium'],
    fallbackBuilder: (context, missingRoles, missingPermissions) => UpgradeBanner(requiredRoles: missingRoles),
    child: const AnalyticsChart(),
  );

  // Global fallback builder in GuardifyScope
  GuardifyScope(
    currentRoles: const ['guest'],
    fallbackBuilder: (context, missingRoles, missingPermissions) {
      return CustomLockedCard(missingRoles: missingRoles);
    },
    child: const MyApp(),
  );
  ```
- [x] **Smooth UI Transitions / Animated Fallbacks**:
  - Provide smooth cross-fade, fade, or slide animations (`AnimatedSwitcher`) when roles update dynamically.
  - Prevents abrupt layout shifts and sudden UI pop-in/pop-out when permissions or roles change.
  ```dart
  SecuredFeature(
    allowedRoles: const ['admin'],
    animated: true,
    animationDuration: Duration(milliseconds: 300),
    child: const AdminToolbar(),
  );
  ```

---

### 📍 Phase 3: Permission-Based & Claim-Based Access Control (PBAC / ABAC) & Telemetry (`v1.3.0`)
*Focus: Fine-grained action permissions, attribute/claim rules, feature toggles, and security auditing callbacks.*

- [ ] **Permission-Based & Claim-Based Access Control (PBAC / ABAC)**:
  - Support fine-grained string permissions alongside roles (`permissions: ['analytics:export', 'users:delete']`).
  - Allow combining roles and permissions with `requireAll: true/false`.
  - Pass current user permissions down via `GuardifyScope(currentPermissions: {'users:read', 'analytics:export'})`.
  ```dart
  @Secured(
    roles: ['admin'],
    permissions: ['analytics:export', 'users:delete'],
    requireAll: true,
  )
  class ExportButton extends StatelessWidget { ... }
  ```
- [ ] **Access Denied Callback (`onAccessDenied`)**:
  - Add an optional `onAccessDenied` callback at both widget level (`@Secured` / `SecuredFeature`) and global `GuardifyScope` level.
  - Ideal for triggering analytics/telemetry events or displaying automatic SnackBars when access is blocked:
  ```dart
  // Widget-level callback
  @Secured(
    roles: ['premium'],
    onAccessDenied: (context) => Analytics.log('premium_feature_blocked'),
  )
  class ExportReportButton extends StatelessWidget { ... }

  // Global scope callback
  GuardifyScope(
    onAccessDenied: (context, widgetName, missingRoles, missingPermissions) {
      Telemetry.logUnauthorizedAccess(widget: widgetName);
    },
    child: const MyApp(),
  );
  ```
- [ ] **Feature Flag Toggles**: Combine role/permission checks with feature flag identifiers (`@Secured(roles: ['admin'], featureFlag: 'beta_analytics')`).

---

### 📍 Phase 4: Navigation & Reactive State Integrations (`v1.4.0`)
*Focus: Router guards, go_router integration, and direct Listenable/Stream state binding.*

- [ ] **Route & Navigation Guards (`go_router` / Navigator Integration)**:
  - Provide a `GuardifyRouteGuard` helper or `redirect` middleware for `go_router` and standard Navigator.
  - Prevents unauthorized navigation at the router level and handles automatic redirection (e.g. to `/unauthorized` or `/upgrade`):
  ```dart
  GoRoute(
    path: '/admin',
    redirect: GuardifyRouteGuard(
      allowedRoles: ['admin'],
      allowedPermissions: ['admin:access'],
      fallbackPath: '/unauthorized',
    ),
    builder: (context, state) => const AdminScreen(),
  );
  ```
- [ ] **Reactive Stream / Listenable Support in `GuardifyScope`**:
  - Allow `GuardifyScope` (e.g. `GuardifyScope.listenable` / `GuardifyScope.stream`) to directly consume a `Stream<String>`, `Stream<List<String>>`, or `Listenable` (such as `ValueNotifier`, `ChangeNotifier`, or `RoleCubit`).
  - Automatically rebuilds descendant scope widgets upon auth state changes without requiring external `BlocBuilder` or `AnimatedBuilder` wrappers:
  ```dart
  GuardifyScope.listenable(
    listenable: userRoleNotifier, // ValueNotifier<List<String>>
    child: const MyApp(),
  );
  ```

---

### 📍 Phase 5: Security Compliance Tooling & Test Helpers (`v2.0.0`)
*Focus: Automated security audits and widget testing utilities.*

- [ ] **Access Control Matrix (ACM) CLI Tool**: Command-line generator that scans `@Secured` annotations and exports a markdown/JSON compliance matrix.
- [ ] **`GuardifyTestScope`**: Unit/Widget testing utility for mocking active roles and permissions effortlessly during `flutter_test` runs:
  ```dart
  await tester.pumpWidget(
    GuardifyTestScope(
      roles: ['admin'],
      permissions: ['analytics:export'],
      child: const SecuredAdminButton(),
    ),
  );
  ```

---

## 💬 Community Feedback & Contributions

Suggestions, feature requests, and PRs are welcome! Feel free to open an issue or start a discussion on our GitHub repository.

