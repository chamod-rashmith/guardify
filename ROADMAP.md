# Guardify Product Roadmap 🗺️

This document outlines the strategic development roadmap for **Guardify**. It tracks completed releases, current active development on the `dev` branch, and upcoming milestones across Access Control, Security Audit Tools, and Developer Experience.

---

## 🎯 Milestones & Release Trajectory

```text
 [v1.0.0 - v1.1.0] Code Generation Core & AST Modernization (Released ✅)
        │
 [v1.2.0] Dual-Mode Architecture (Runtime RoleGate + @Secured Code-Gen)
          PBAC, Disabled Overlays, Route Guards & Reactive Scopes (Released ✅)
        │
 [v1.3.0] Security Compliance Tooling & Developer Experience (In Progress on `dev` 🚀)
          ├── Access Control Matrix (ACM) CLI Tool (Completed ✅)
          ├── Animated Fallback Transitions (Planned ⏳)
          └── GuardifyTestScope for Unit/Widget Testing (Planned ⏳)
        │
 [v2.0.0] Ecosystem Modernization & Deep Tooling (Future Vision 🔭)
          ├── Modular Package Separation (guardify_annotation / generator)
          ├── Flutter DevTools Security Inspector Plugin
          └── Remote Claim Synchronization
```

---

## 🚀 Detailed Phase Breakdown

### 📍 Phase 1: Code Generator Core & AST Modernization (`v1.0.0 - v1.1.0` - Released ✅)
- [x] **Generic Widget Support**: Support generic type parameters on annotated widget classes (e.g. `class UserTable<T> extends StatelessWidget`).
- [x] **Enum & Constant Role Extraction**: Support passing enums in `@Secured` (e.g., `@Secured([UserRole.admin])`) without missing string values.
- [x] **Strict AST Compile-Time Guardrails**:
  - Validate that annotated elements extend `Widget` (throw `InvalidGenerationSourceError` if applied to standard classes).
  - Ensure `allowedRoles` or `allowedPermissions` is not empty.
- [x] **Variable Shadowing Immunity**: Safely isolate internal generator identifiers (`guardifyScope`, `guardifyIsAuthorized`) from target widget constructor parameters.

---

### 📍 Phase 2: Dual-Mode Architecture & Runtime Gating (`v1.2.0` - Released ✅)
- [x] **Zero-Boilerplate Runtime `RoleGate` / `SecuredFeature`**:
  - Protect any native or third-party Flutter widget without code-gen or `build_runner`.
- [x] **Built-in `FallbackType.disabled` with Lock Overlay**:
  - Automatically wraps child widgets with `AbsorbPointer` and reduced opacity (e.g., `0.5`).
  - Supports optional lock badge/overlay icon (`lockBadge`) out-of-the-box.
- [x] **Dynamic `fallbackBuilder` Callback**:
  - Context-aware fallback builder receiving `missingRoles` and `missingPermissions`.
  - Configurable locally on widgets and globally in `GuardifyScope`.
- [x] **Fine-Grained Permissions (PBAC)**:
  - Support string permissions alongside roles (`allowedPermissions: ['analytics:export', 'users:delete']`).
  - Context extension methods: `context.hasPermission()`, `context.hasAnyPermission()`, `context.hasAllPermissions()`.
- [x] **Route & Navigation Guards**:
  - `GuardifyRouteGuard` and `guardifyRedirect` helper for `go_router` and standard Navigators.
- [x] **Reactive Stream / Listenable Support**:
  - `GuardifyScope.listenable` and `GuardifyScope.stream` for automatic rebuilds on auth changes.
- [x] **Telemetry & Access Denied Hook**:
  - `onAccessDenied` callback for logging unauthorized attempts.

---

### 📍 Phase 3: Security Compliance & DX (`v1.3.0` - In Active Development on `dev` 🚀)
- [x] **Access Control Matrix (ACM) CLI Tool (`dart run guardify:matrix`)**:
  - AST-powered scanner discovering all `@Secured` annotations and `RoleGate` instantiations across the codebase.
  - Generates audit matrices in Terminal Console, Markdown, and JSON formats for compliance reviews.
- [ ] **Smooth Animated Fallback Transitions**:
  - Built-in cross-fade / slide transitions (`AnimatedSwitcher`) when user roles update dynamically.
- [ ] **`GuardifyTestScope`**:
  - Pre-configured testing scope utility for mocking active roles and permissions easily during `flutter_test` runs.

---

### 📍 Phase 4: Ecosystem & Deep Tooling (`v2.0.0` - Future Vision 🔭)
- [ ] **Package Splitting**:
  - Split into lightweight `guardify_annotation`, compile-time `guardify_generator`, and core `guardify` to reduce app bundle size and speed up builds.
- [ ] **Flutter DevTools Extension**:
  - Interactive visual panel in Flutter DevTools to inspect active roles, toggle simulated roles live, and view gated widget statuses.
- [ ] **Security Policy Linter Rules**:
  - Custom `custom_lint` rules warning developers if sensitive buttons/routes lack proper access gates.
- [ ] **Remote Policy Sync**:
  - Integration bridges with Firebase Security Rules, Supabase RLS, and Auth0 claim structures.
