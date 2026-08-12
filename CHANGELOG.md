## 1.0.0

- 🛡️ **Initial Release of Guardify** - Role-Based UI Access Control (RBAC) code generator for Flutter.
- **`@Secured` Annotation**: Support for `allowedRoles`, `fallback` UI strategies (`hide`, `scaffold`, `text`), `requireAll` matching logic, and custom class `name` overrides.
- **`SecuredGenerator`**: Generates type-safe, idiomatic `Secured<ClassName>` widget wrappers with constructor parameter forwarding.
- **`GuardifyScope`**: Ambient role state resolution via `InheritedWidget` to eliminate prop-drilling across widget trees.
- **`BuildContext` Extensions**: Convenience getters including `context.hasRole()`, `context.hasAnyRole()`, `context.hasAllRoles()`, and `context.isAuthorized()`.
- **Custom Permission Checker**: Support for dynamic permission callbacks (Firebase Auth claims, JWT rules) via `permissionChecker`.
