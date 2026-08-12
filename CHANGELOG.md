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
