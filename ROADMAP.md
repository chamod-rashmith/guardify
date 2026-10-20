# Guardify Product Roadmap 🗺️

This document outlines the strategic development roadmap for **Guardify**. It tracks completed milestones and upcoming enhancements across Access Control, Code Generation, Navigation, and Compliance Tooling.

---

## 🎯 Strategic Milestones Overview

```
 [v1.0.0/v1.1.0] Code Generation Core & AST Modernization (Completed ✅)
        │
 [v1.2.0] Dual-Mode (RoleGate), Disabled Overlays & Dynamic Fallback Builders (Completed ✅)
        │
 [v1.3.0] Permission-Based Access Control (PBAC) & Telemetry (Completed ✅)
        │
 [v1.4.0] Route Guards & Reactive Listenable/Stream Scopes (Completed ✅)
        │
 [v2.0.0] Access Control Matrix (ACM) CLI & Security Audit Tooling (Upcoming 🚀)
```

---

## 🚀 Detailed Phase Breakdown

### 📍 Phase 1: Code Generator Core & AST Modernization (`v1.1.0` - Completed ✅)
- [x] **Generic Widget Support**: Support generic type parameters on annotated widget classes (e.g. `class UserTable<T> extends StatelessWidget`).
- [x] **Enum & Constant Role Extraction**: Support passing enums in `@Secured` (e.g., `@Secured([UserRole.admin])`) without missing string values.
- [x] **Strict AST Compile-Time Guardrails**:
  - Validate that annotated elements extend `Widget` (throw `InvalidGenerationSourceError` if applied to standard classes).
  - Ensure `allowedRoles` or `allowedPermissions` is not empty.
- [x] **Variable Shadowing Immunity**: Safely isolate internal generator identifiers (`guardifyScope`, `guardifyIsAuthorized`) from target widget constructor parameters.

---

### 📍 Phase 2: Rich UI Fallback Strategies, Lock Overlays & Runtime Widget (`v1.2.0` - Completed ✅)
- [x] **Zero-Boilerplate Runtime `RoleGate` / `SecuredFeature`**:
  - Protect any native or third-party Flutter widget without code-gen or `build_runner`.
- [x] **Built-in `FallbackType.disabled` with Lock Overlay**:
  - Automatically wraps child widgets with `AbsorbPointer` and reduced opacity (e.g., `0.5`).
  - Supports optional lock badge/overlay icon (`lockBadge`) out-of-the-box.
- [x] **Dynamic `fallbackBuilder` Callback**:
  - Context-aware fallback builder receiving `missingRoles` and `missingPermissions`.
  - Configurable locally on widgets and globally in `GuardifyScope`.

---

### 📍 Phase 3: Permission-Based Access Control (PBAC) & Telemetry (`v1.3.0` - Completed ✅)
- [x] **Fine-Grained Permissions (PBAC)**:
  - Support string permissions alongside roles (`allowedPermissions: ['analytics:export', 'users:delete']`).
  - Pass current user permissions down via `GuardifyScope(currentPermissions: {'users:read', 'analytics:export'})`.
  - Extension methods: `context.hasPermission()`, `context.hasAnyPermission()`, `context.hasAllPermissions()`.
- [x] **Access Denied Callback (`onAccessDenied`)**:
  - Integrated into `RoleGate` for firing analytics/telemetry events or tracking unauthorized access.

---

### 📍 Phase 4: Navigation & Reactive State Integrations (`v1.4.0` - Completed ✅)
- [x] **Route & Navigation Guards (`go_router` / Navigator Integration)**:
  - `GuardifyRouteGuard` and `guardifyRedirect` helper for `go_router` and standard Navigators.
- [x] **Reactive Stream / Listenable Support in `GuardifyScope`**:
  - `GuardifyScope.listenable` directly consumes `ValueListenable` or `ChangeNotifier`.
  - `GuardifyScope.stream` directly consumes role and permission `Stream`s.

---

### 📍 Phase 5: Security Compliance Tooling & Test Helpers (`v2.0.0` - Planned 🚀)
- [ ] **Access Control Matrix (ACM) CLI Tool**: Command-line generator that scans `@Secured` annotations and exports a markdown/JSON compliance matrix.
- [ ] **Smooth Animated Fallback Transitions**: Built-in cross-fade / slide transitions (`AnimatedSwitcher`) when roles update dynamically.
- [ ] **`GuardifyTestScope`**: Pre-configured testing scope utility for mocking active roles and permissions during `flutter_test` runs.
