import 'package:flutter/widgets.dart';

/// Signature for custom permission checking callbacks.
typedef PermissionChecker = bool Function(
  List<String> allowedRoles, {
  bool requireAll,
  Set<String>? activeRoles,
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
    if (allowedRoles.isEmpty) return false;

    final activeRoles = <String>{};
    if (currentRole != null) {
      activeRoles.add(currentRole!);
      if (currentRole!.contains('.')) {
        activeRoles.add(currentRole!.split('.').last);
      }
    }
    if (currentRoles != null) {
      for (final r in currentRoles!) {
        activeRoles.add(r);
        if (r.contains('.')) {
          activeRoles.add(r.split('.').last);
        }
      }
    }

    if (permissionChecker != null) {
      return permissionChecker!(
        allowedRoles,
        requireAll: requireAll,
        activeRoles: activeRoles,
      );
    }

    if (activeRoles.isEmpty) return false;

    if (requireAll) {
      return allowedRoles.every((role) => activeRoles.contains(role));
    } else {
      return allowedRoles.any((role) => activeRoles.contains(role));
    }
  }

  @override
  bool updateShouldNotify(GuardifyScope oldWidget) {
    if (currentRole != oldWidget.currentRole ||
        permissionChecker != oldWidget.permissionChecker) {
      return true;
    }

    final newRoles = <String>{
      if (currentRole != null) currentRole!,
      if (currentRoles != null) ...currentRoles!,
    };
    final oldRoles = <String>{
      if (oldWidget.currentRole != null) oldWidget.currentRole!,
      if (oldWidget.currentRoles != null) ...oldWidget.currentRoles!,
    };

    if (newRoles.length != oldRoles.length) return true;
    return !newRoles.every(oldRoles.contains);
  }
}

