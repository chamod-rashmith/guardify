import 'package:flutter/widgets.dart';

/// Signature for custom permission checking callbacks.
typedef PermissionChecker = bool Function(
  List<String> allowedRoles, {
  bool requireAll,
});

/// An [InheritedWidget] that supplies role state and permission logic to descendant widgets.
class GuardifyScope extends InheritedWidget {
  /// Single active user role.
  final String? currentRole;

  /// Multiple active user roles.
  final Iterable<String>? currentRoles;

  /// Optional custom permission checker function (e.g. for JWT claims or dynamic async rules).
  final PermissionChecker? permissionChecker;

  const GuardifyScope({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.permissionChecker,
    required super.child,
  });

  /// Retrieves the nearest [GuardifyScope] instance up the widget tree.
  static GuardifyScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GuardifyScope>();
  }

  /// Evaluates whether access is authorized based on allowed roles.
  bool isAuthorized(List<String> allowedRoles, {bool requireAll = false}) {
    if (permissionChecker != null) {
      return permissionChecker!(allowedRoles, requireAll: requireAll);
    }

    final activeRoles = <String>{
      if (currentRole != null) currentRole!,
      if (currentRoles != null) ...currentRoles!,
    };

    if (activeRoles.isEmpty) return false;

    if (requireAll) {
      return allowedRoles.every((role) => activeRoles.contains(role));
    } else {
      return allowedRoles.any((role) => activeRoles.contains(role));
    }
  }

  @override
  bool updateShouldNotify(GuardifyScope oldWidget) {
    return currentRole != oldWidget.currentRole ||
        currentRoles != oldWidget.currentRoles ||
        permissionChecker != oldWidget.permissionChecker;
  }
}
