## [Unreleased]

- ⚡ **Dart 3 Switch Expression UI Rendering**: Refactored `SecuredCodeComposer` to emit modern Dart 3 `switch` expressions with pattern matching (`(true, _)`, `(false, final fallback?)`) for clean, functional UI widget returns.
- 🚀 **Declarative Set Collection & Tear-off Optimization**: Aggregates active roles via collection-if spread syntax and replaces lambda closures with tear-off method references (`allowedRoles.any(activeRoles.contains)`).
- 🔑 **Generated Enum Normalization**: Generated widgets now automatically normalize qualified enum strings (e.g. `'UserRole.admin'` -> `'admin'`), ensuring seamless role matching whether passed directly or via `GuardifyScope`.
- 🛡️ **Vacuous Truth Protection**: Fixed edge-case bug where empty `allowedRoles` with `requireAll: true` evaluated to `true` due to Dart list `every` semantics.
- 📝 **Rich Step-by-Step Code Comments**: Added detailed 1-5 numbered inline documentation in generated `.secured.g.dart` widgets explaining role resolution, scope lookup, normalization, evaluation, and fallback selection.
- 🧪 **Modular Test Suite**: Refactored `test/` into clean domain modules (`test/unit`, `test/runtime`, `test/generator`) with 23 passing tests.

## 1.1.4

- 🛡️ **Critical Security Patch**: Fixed custom `permissionChecker` bypass where direct widget role props (`currentRole` / `currentRoles`) were ignored when a parent scope defined a custom `permissionChecker`.
- 🐛 **Property Collision & Fallback Disambiguation**: Resolved parameter collisions on target widgets accepting custom `fallback` parameters by cleanly isolating the access-denied fallback UI property (`accessDeniedFallback`).
- ⚡ **Set Equality Optimization**: Updated `GuardifyScope.updateShouldNotify` to compare active roles using content set equality, preventing unnecessary subtree rebuilds when new list instances with identical roles are passed.
- 🔑 **Enum Normalization & Empty Role Guard**: Enhanced `GuardifyScope.isAuthorized` to normalize qualified enum strings (e.g. `'DemoRole.admin'` -> `'admin'`) for context extension checks and returning `false` when `allowedRoles` is empty.
- 🛠️ **Analyzer Reflection Compatibility**: Upgraded constructor reflection logic in `SecuredGenerator` to prevent dynamic reflection crashes across Dart Analyzer versions.

## 1.1.3

- 🧹 **Dart Linter `use_null_aware_elements` Fix**: Refactored `SecuredGenerator` template to construct `activeRoles` Set imperatively using `.add()` and `.addAll()` with local variable type promotion (`directRole`, `directRoles`, `scopeRole`, `scopeRoles`), completely eliminating collection-if checks and resolving `use_null_aware_elements` linter warnings across all Dart 3.0+ linter configurations.

## 1.1.2

- 🧹 **Dart 3.0+ Null-Aware Collection Elements**: Updated `SecuredGenerator` template to use null-aware pattern matching (`if (... case final role?) role` and `...?`) to eliminate `use_null_aware_elements` linter warnings.
- ⚡ **Const Constructor Optimization**: Automatically injects `const` keyword for 0-argument const target constructor invocations in generated `.secured.g.dart` widgets, eliminating `prefer_const_constructors` linter warnings and improving runtime performance.

## 1.1.1

- 🐛 **Named Constructor Selection**: Added automatic fallback to the first public constructor for widgets with named constructors (e.g. `MyWidget.primary(...)`).
- 🔑 **Dual Enum Role Matching**: Extracted both short Enum name (`'admin'`) and qualified Enum name (`'DemoRole.admin'`) for seamless Enum role resolution.
- 🛡️ **Reserved Parameter Collision Fix**: Prevented property name collisions when target widget constructors use parameters named `currentRole`, `currentRoles`, or `fallback`.

## 1.1.0

- 🚀 **Generic Widget Support (`<T>`)**: Generates type-safe wrapper classes preserving generic type parameters and bounds (e.g. `SecuredGenericDataCard<T>`).
- 🔑 **Enum & Constant Role Extraction**: `@Secured` annotations now support Enum instances and constant objects in `allowedRoles` (e.g. `@Secured([UserRole.admin])`).
- 🛡️ **AST Compile-Time Guardrails**: Strict validation ensuring `@Secured` is only applied to Flutter `Widget` classes and enforcing non-empty `allowedRoles` lists.
- 🎨 **Code Builder & Formatting**: Integrated `DartFormatter` from `dart_style` for clean, formatted generated output.

## 1.0.0

- 🛡️ **Initial Release of Guardify** - Role-Based UI Access Control (RBAC) code generator for Flutter.
- **`@Secured` Annotation**: Support for `allowedRoles`, `fallback` UI strategies (`hide`, `scaffold`, `text`), `requireAll` matching logic, and custom class `name` overrides.
- **`SecuredGenerator`**: Generates type-safe, idiomatic `Secured<ClassName>` widget wrappers with constructor parameter forwarding.
- **`GuardifyScope`**: Ambient role state resolution via `InheritedWidget` to eliminate prop-drilling across widget trees.
- **`BuildContext` Extensions**: Convenience getters including `context.hasRole()`, `context.hasAnyRole()`, `context.hasAllRoles()`, and `context.isAuthorized()`.
- **Custom Permission Checker**: Support for dynamic permission callbacks (Firebase Auth claims, JWT rules) via `permissionChecker`.
