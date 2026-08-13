import 'package:flutter/widgets.dart';
import 'role_registry.dart';

/// Signature for custom permission evaluation callbacks.
///
/// Implement this function to inject dynamic permission rules, JWT token claim
/// evaluations, dynamic feature flags, or async authorization engines into Guardify.
///
/// Parameters:
/// - [allowedRoles]: The list of roles authorized by the target [@Secured] widget.
/// - [requireAll]: Whether all roles are required (`true`) or any single role matches (`false`).
/// - [activeRoles]: The set of active roles currently present in the scope/widget.
typedef PermissionChecker = bool Function(
  List<String> allowedRoles, {
  bool requireAll,
  Set<String>? activeRoles,
});

/// Signature for fallback UI builder functions contextually aware of authorization failures.
///
/// Parameters:
/// - [context]: The active [BuildContext].
/// - [missingRoles]: Roles from the target widget's `allowedRoles` list that the active scope/user lacks.
/// - [missingPermissions]: Permissions that the active scope/user lacks (reserved for PBAC/ABAC).
typedef SecuredFallbackBuilder = Widget Function(
  BuildContext context,
  List<String> missingRoles,
  List<String> missingPermissions,
);

/// An [InheritedWidget] that supplies active user role state and authorization logic to descendant widgets.
///
/// Place [GuardifyScope] near the root of your application (or above role-restricted
/// widget subtrees) to broadcast active roles down the widget tree.
///
/// ### Example Usage:
/// ```dart
/// GuardifyScope(
///   currentRole: 'admin',
///   child: MaterialApp(
///     home: MyHomeScreen(),
///   ),
/// )
/// ```
///
/// Descendant widgets (and generated `Secured<Widget>` wrappers) look up the nearest
/// [GuardifyScope] via [GuardifyScope.of] or [BuildContext] extension methods.
class GuardifyScope extends InheritedWidget {
  /// The active user role as a single role string or enum string representation.
  ///
  /// Can be a simple role string like `'admin'` or a qualified enum name like `'UserRole.admin'`.
  /// String normalization automatically strips enum prefixes when matching (e.g., `'UserRole.admin'` matches `'admin'`).
  final String? currentRole;

  /// Multiple active user roles (e.g. for users with multiple concurrent permissions).
  ///
  /// Combined with [currentRole] when evaluating active permissions.
  final Iterable<String>? currentRoles;

  /// Pre-computed 64-bit integer bitmask flag representing all active roles in this scope.
  ///
  /// Generated via [RoleRegistry] to enable constant-time $O(1)$ bitwise authorization checks.
  int get roleMask => RoleRegistry.getMaskForRoles(
        collectRoles(currentRole: currentRole, currentRoles: currentRoles),
      );

  /// Optional custom permission checking function.
  ///
  /// When provided, this callback overrides standard role-matching logic.
  /// Useful for integrating custom access-control engines, scope rules, or dynamic claims.
  final PermissionChecker? permissionChecker;

  /// Optional global fallback builder for unauthorized descendant widgets.
  ///
  /// When descendant widgets fail authorization checks and do not define a local fallback
  /// or override widget, this builder will be invoked with the missing roles and permissions.
  final SecuredFallbackBuilder? fallbackBuilder;

  /// Creates a [GuardifyScope] to propagate role state down the widget tree.
  const GuardifyScope({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.permissionChecker,
    this.fallbackBuilder,
    required super.child,
  });

  /// Retrieves the nearest [GuardifyScope] instance up the widget tree from [context].
  ///
  /// Returns `null` if no [GuardifyScope] is present in the widget ancestry.
  static GuardifyScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GuardifyScope>();
  }

  /// Collects and normalizes active user role strings from direct parameters and ambient scope.
  ///
  /// Combines [currentRole] and [currentRoles] from direct widget properties as well as
  /// inherited [scope] parameters, automatically expanding qualified enum strings
  /// (e.g. `'UserRole.admin'` -> adds both `'UserRole.admin'` and `'admin'`).
  static Set<String> collectRoles({
    String? currentRole,
    Iterable<String>? currentRoles,
    GuardifyScope? scope,
  }) {
    final activeRoles = <String>{};

    void addRole(String? role) {
      if (role == null) return;
      activeRoles.add(role);
      if (role.contains('.')) {
        activeRoles.add(role.split('.').last);
      }
    }

    addRole(currentRole);
    if (currentRoles != null) {
      for (final role in currentRoles) {
        addRole(role);
      }
    }

    if (scope != null) {
      addRole(scope.currentRole);
      if (scope.currentRoles != null) {
        for (final role in scope.currentRoles!) {
          addRole(role);
        }
      }
    }

    return activeRoles;
  }

  /// Evaluates whether the active scope configuration grants authorization for [allowedRoles].
  ///
  /// Parameters:
  /// - [allowedRoles]: List of role strings allowed to access a feature/widget.
  /// - [requireAll]: If `true`, all roles in [allowedRoles] must be active. If `false` (default), any single matching role grants authorization.
  ///
  /// Performs an $O(1)$ constant-time bitwise check via [RoleRegistry].
  bool isAuthorized(List<String> allowedRoles, {bool requireAll = false}) {
    if (allowedRoles.isEmpty) return false;

    // Delegate to custom permissionChecker if provided
    if (permissionChecker != null) {
      final activeRoles = collectRoles(
        currentRole: currentRole,
        currentRoles: currentRoles,
      );
      return permissionChecker!(
        allowedRoles,
        requireAll: requireAll,
        activeRoles: activeRoles,
      );
    }

    if (roleMask == 0) return false;

    final targetMask = RoleRegistry.getMaskForRoles(allowedRoles);
    return RoleRegistry.matchMask(
      activeMask: roleMask,
      targetMask: targetMask,
      requireAll: requireAll,
    );
  }

  /// Evaluates whether descendant widgets depending on this scope should rebuild when [oldWidget] updates.
  ///
  /// Performs single-cycle integer equality comparison (`roleMask != oldWidget.roleMask`)
  /// eliminating set allocations and element iteration during widget rebuilds.
  @override
  bool updateShouldNotify(GuardifyScope oldWidget) {
    return roleMask != oldWidget.roleMask ||
        permissionChecker != oldWidget.permissionChecker ||
        fallbackBuilder != oldWidget.fallbackBuilder;
  }
}
