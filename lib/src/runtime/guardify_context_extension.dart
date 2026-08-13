import 'package:flutter/widgets.dart';

import 'guardify_scope.dart';

/// Extension methods on [BuildContext] for Role-Based Access Control (RBAC).
///
/// Provides ergonomic convenience methods for checking user authorization directly
/// from any build context where a [GuardifyScope] is present in the widget ancestry.
///
/// ### Example Usage:
/// ```dart
/// if (context.hasRole('admin')) {
///   // Perform admin action
/// }
/// ```
extension GuardifyContextExtension on BuildContext {
  /// Evaluates whether the active [GuardifyScope] in [BuildContext] is authorized for [allowedRoles].
  ///
  /// Parameters:
  /// - [allowedRoles]: List of role strings authorized to perform an action or view content.
  /// - [requireAll]: If `true`, requires all specified roles to be active. If `false` (default), any single role matches.
  ///
  /// Returns `false` safely if no [GuardifyScope] is found in the widget tree ancestry.
  bool isAuthorized(List<String> allowedRoles, {bool requireAll = false}) {
    final scope = GuardifyScope.of(this);
    if (scope == null) return false;
    return scope.isAuthorized(allowedRoles, requireAll: requireAll);
  }

  /// Checks if the active user possesses the specified single [role].
  ///
  /// Returns `true` if the active [GuardifyScope] contains [role], otherwise `false`.
  bool hasRole(String role) {
    return isAuthorized([role]);
  }

  /// Checks if the active user possesses **any** of the specified [roles] (OR logic).
  ///
  /// Returns `true` if at least one role in [roles] is active.
  bool hasAnyRole(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: false);
  }

  /// Checks if the active user possesses **all** of the specified [roles] (AND logic).
  ///
  /// Returns `true` only if every role in [roles] is active.
  bool hasAllRoles(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: true);
  }
}
