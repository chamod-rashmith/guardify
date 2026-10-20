import 'package:flutter/widgets.dart';

import 'guardify_context_extension.dart';

/// Navigation route guard utility for router packages such as `go_router` or custom navigators.
///
/// Can be passed directly as a redirect callback:
/// ```dart
/// GoRoute(
///   path: '/admin',
///   redirect: GuardifyRouteGuard(
///     allowedRoles: const ['admin'],
///     fallbackPath: '/unauthorized',
///   ),
///   builder: (context, state) => const AdminScreen(),
/// )
/// ```
class GuardifyRouteGuard {
  /// Authorized roles required to enter this route.
  final List<String> allowedRoles;

  /// Authorized permissions required to enter this route.
  final List<String> allowedPermissions;

  /// Whether all roles and permissions must be present.
  final bool requireAll;

  /// The redirection path returned when access is denied.
  final String fallbackPath;

  /// Instantiates a [GuardifyRouteGuard].
  const GuardifyRouteGuard({
    this.allowedRoles = const [],
    this.allowedPermissions = const [],
    this.requireAll = false,
    required this.fallbackPath,
  });

  /// Evaluates authorization in [context].
  ///
  /// Returns [fallbackPath] if unauthorized, or `null` if authorized
  /// (matching the contract for `go_router` redirect functions).
  String? call(BuildContext context, [dynamic state]) {
    final isAuth = context.isAuthorized(
      allowedRoles,
      requireAll: requireAll,
      allowedPermissions: allowedPermissions,
    );

    if (!isAuth) {
      return fallbackPath;
    }
    return null;
  }
}

/// Convenience helper to perform inline route redirects.
String? guardifyRedirect(
  BuildContext context, {
  List<String> allowedRoles = const [],
  List<String> allowedPermissions = const [],
  bool requireAll = false,
  required String fallbackPath,
}) {
  return GuardifyRouteGuard(
    allowedRoles: allowedRoles,
    allowedPermissions: allowedPermissions,
    requireAll: requireAll,
    fallbackPath: fallbackPath,
  ).call(context);
}
