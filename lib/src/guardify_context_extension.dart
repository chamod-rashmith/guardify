import 'package:flutter/widgets.dart';

import 'guardify_scope.dart';

/// Extension methods on [BuildContext] for Guardify Role-Based Access Control.
extension GuardifyContextExtension on BuildContext {
  /// Evaluates whether the current context has authorization for the [allowedRoles].
  bool isAuthorized(List<String> allowedRoles, {bool requireAll = false}) {
    final scope = GuardifyScope.of(this);
    if (scope == null) return false;
    return scope.isAuthorized(allowedRoles, requireAll: requireAll);
  }

  /// Checks if the active user possesses the specified [role].
  bool hasRole(String role) {
    return isAuthorized([role]);
  }

  /// Checks if the active user possesses any of the specified [roles].
  bool hasAnyRole(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: false);
  }

  /// Checks if the active user possesses all of the specified [roles].
  bool hasAllRoles(Iterable<String> roles) {
    return isAuthorized(roles.toList(), requireAll: true);
  }
}
