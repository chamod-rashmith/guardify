import 'package:flutter/widgets.dart';

import 'guardify_scope.dart';

/// Extension methods on [BuildContext] for Role-Based Access Control (RBAC)
/// and Permission-Based Access Control (PBAC).
///
/// Provides ergonomic convenience methods for checking user authorization directly
/// from any build context where a [GuardifyScope] is present in the widget ancestry.
///
/// ### Example Usage:
/// ```dart
/// if (context.hasRole('admin')) {
///   // Perform admin action
/// }
///
/// if (context.hasPermission('users:delete')) {
///   // Delete user
/// }
/// ```
extension GuardifyContextExtension on BuildContext {
  /// Evaluates whether the active [GuardifyScope] in [BuildContext] is authorized for
  /// [allowedRoles] and [allowedPermissions].
  ///
  /// Parameters:
  /// - [allowedRoles]: List of role strings authorized to perform an action or view content.
  /// - [allowedPermissions]: List of permission strings authorized.
  /// - [requireAll]: If `true`, requires all specified roles and permissions to be active. If `false` (default), any single role or permission matches.
  ///
  /// Returns `false` safely if no [GuardifyScope] is found in the widget tree ancestry.
  bool isAuthorized(
    List<String> allowedRoles, {
    bool requireAll = false,
    List<String> allowedPermissions = const [],
  }) {
    final scope = GuardifyScope.of(this);
    if (scope == null) return false;
    return scope.isAuthorized(
      allowedRoles,
      requireAll: requireAll,
      allowedPermissions: allowedPermissions,
    );
  }

  /// Checks if the active user possesses the specified single [role].
  bool hasRole(String role) {
    return isAuthorized([role]);
  }

  /// Checks if the active user possesses **any** of the specified [roles] (OR logic).
  bool hasAnyRole(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: false);
  }

  /// Checks if the active user possesses **all** of the specified [roles] (AND logic).
  bool hasAllRoles(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: true);
  }

  /// Checks if the active user possesses the specified single [permission].
  bool hasPermission(String permission) {
    return isAuthorized(const [], allowedPermissions: [permission]);
  }

  /// Checks if the active user possesses **any** of the specified [permissions] (OR logic).
  bool hasAnyPermission(Iterable<String> permissions) {
    return isAuthorized(const [], allowedPermissions: permissions.toList(), requireAll: false);
  }

  /// Checks if the active user possesses **all** of the specified [permissions] (AND logic).
  bool hasAllPermissions(Iterable<String> permissions) {
    return isAuthorized(const [], allowedPermissions: permissions.toList(), requireAll: true);
  }
}
