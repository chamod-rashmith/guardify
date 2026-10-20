import 'package:flutter/material.dart';

import 'guardify_scope.dart';
import 'secured_annotation.dart';

/// A runtime role and permission gating widget.
///
/// Wraps any [child] widget and only displays it if the active user possesses
/// the authorized [allowedRoles] or [allowedPermissions].
///
/// Unlike code-generated `@Secured` widgets, [RoleGate] requires **no build_runner**
/// and can be used on-the-fly around any third-party or native Flutter widget.
///
/// ### Example Usage:
/// ```dart
/// RoleGate(
///   allowedRoles: const ['admin', 'manager'],
///   fallback: const Text('Locked Feature'),
///   child: FloatingActionButton(
///     onPressed: () {},
///     child: const Icon(Icons.add),
///   ),
/// )
/// ```
class RoleGate extends StatelessWidget {
  /// The target widget to render when the user is authorized.
  final Widget child;

  /// The list of role strings authorized to view the [child].
  final List<String> allowedRoles;

  /// The list of permission strings authorized to view the [child].
  final List<String> allowedPermissions;

  /// Whether all roles and permissions are required (`true`) or any single role/permission matches (`false`).
  final bool requireAll;

  /// Active role override passed directly to this widget.
  final String? currentRole;

  /// Active roles override passed directly to this widget.
  final Iterable<String>? currentRoles;

  /// Active permission override passed directly to this widget.
  final String? currentPermission;

  /// Active permissions override passed directly to this widget.
  final Iterable<String>? currentPermissions;

  /// Optional custom fallback widget to display when unauthorized.
  final Widget? fallback;

  /// Dynamic fallback builder invoked when unauthorized.
  final GuardifyFallbackBuilder? fallbackBuilder;

  /// Built-in fallback strategy when neither [fallback] nor [fallbackBuilder] is provided.
  final FallbackType fallbackType;

  /// Opacity multiplier used when [fallbackType] is [FallbackType.disabled].
  final double disabledOpacity;

  /// Optional badge or icon shown over the disabled child when [fallbackType] is [FallbackType.disabled].
  final Widget? lockBadge;

  /// Optional callback invoked when access is denied.
  final VoidCallback? onAccessDenied;

  /// Creates a runtime [RoleGate] to protect [child] based on roles and permissions.
  const RoleGate({
    super.key,
    required this.child,
    this.allowedRoles = const [],
    this.allowedPermissions = const [],
    this.requireAll = false,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
    this.fallbackType = FallbackType.hide,
    this.disabledOpacity = 0.5,
    this.lockBadge,
    this.onAccessDenied,
  });

  @override
  Widget build(BuildContext context) {
    final scope = GuardifyScope.of(context);

    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    final activePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: scope,
    );

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(
        allowedRoles,
        requireAll: requireAll,
        activeRoles: activeRoles,
        allowedPermissions: allowedPermissions,
        activePermissions: activePermissions,
      );
    } else {
      final hasRolesToCheck = allowedRoles.isNotEmpty;
      final hasPermissionsToCheck = allowedPermissions.isNotEmpty;

      if (!hasRolesToCheck && !hasPermissionsToCheck) {
        isAuthorized = false;
      } else if (requireAll) {
        final rolesOk = !hasRolesToCheck || allowedRoles.every(activeRoles.contains);
        final permsOk = !hasPermissionsToCheck || allowedPermissions.every(activePermissions.contains);
        isAuthorized = rolesOk && permsOk;
      } else {
        final roleMatch = hasRolesToCheck && allowedRoles.any(activeRoles.contains);
        final permMatch = hasPermissionsToCheck && allowedPermissions.any(activePermissions.contains);
        isAuthorized = roleMatch || permMatch;
      }
    }

    if (isAuthorized) {
      return child;
    }

    onAccessDenied?.call();

    if (fallback != null) {
      return fallback!;
    }

    final missingRoles = allowedRoles.where((r) => !activeRoles.contains(r)).toList();
    final missingPermissions = allowedPermissions.where((p) => !activePermissions.contains(p)).toList();

    if (fallbackBuilder != null) {
      return fallbackBuilder!(context, missingRoles, missingPermissions);
    }

    if (scope?.fallbackBuilder != null) {
      return scope!.fallbackBuilder!(context, missingRoles, missingPermissions);
    }

    return switch (fallbackType) {
      FallbackType.hide => const SizedBox.shrink(),
      FallbackType.disabled => _buildDisabled(context),
      FallbackType.text => const Center(
          child: Text(
            'Access Denied: Restricted Area!',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      FallbackType.scaffold => Scaffold(
          appBar: AppBar(
            title: const Text('Access Denied'),
          ),
          body: const Center(
            child: Text(
              'Access Denied: Restricted Area!',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
    };
  }

  Widget _buildDisabled(BuildContext context) {
    final disabledChild = AbsorbPointer(
      absorbing: true,
      child: Opacity(
        opacity: disabledOpacity,
        child: child,
      ),
    );

    if (lockBadge != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          disabledChild,
          lockBadge!,
        ],
      );
    }

    return disabledChild;
  }
}

/// Alias for [RoleGate] emphasizing feature-level security gating.
typedef SecuredFeature = RoleGate;
