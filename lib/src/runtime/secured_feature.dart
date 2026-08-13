import 'package:flutter/material.dart';

import 'guardify_scope.dart';
import 'lock_overlay.dart';
import 'role_registry.dart';
import 'secured_annotation.dart';

/// A runtime widget that protects a [child] widget subtree with Role-Based Access Control (RBAC).
///
/// Use [SecuredFeature] when you prefer declarative runtime role gating over
/// compile-time `@Secured` code generation, or when wrapping dynamic subtrees.
///
/// ### Example Usage:
/// ```dart
/// SecuredFeature(
///   allowedRoles: const ['admin', 'manager'],
///   fallback: FallbackType.disabled,
///   child: const EditProfileButton(),
/// )
/// ```
class SecuredFeature extends StatelessWidget {
  /// The collection of roles authorized to view/access [child].
  final List<String> allowedRoles;

  /// Controls whether all roles are required (`true`) or any single role grants access (`false`).
  final bool requireAll;

  /// Optional active user role override passed directly to this widget instance.
  final String? currentRole;

  /// Optional active user roles override passed directly to this widget instance.
  final Iterable<String>? currentRoles;

  /// Strategy used when authorization fails. Defaults to [FallbackType.hide].
  final FallbackType fallback;

  /// Custom fallback widget rendered directly when authorization fails.
  final Widget? accessDeniedFallback;

  /// Context-aware builder function invoked with missing roles/permissions when authorization fails.
  final SecuredFallbackBuilder? fallbackBuilder;

  /// Whether to render a lock badge icon over the widget when [fallback] is [FallbackType.disabled].
  final bool showLockBadge;

  /// Opacity level applied to [child] when [fallback] is [FallbackType.disabled]. Defaults to `0.5`.
  final double disabledOpacity;

  /// Custom lock icon widget applied when [fallback] is [FallbackType.disabled].
  final Widget? lockIcon;

  /// Enables smooth cross-fade animation when switching authorization states. Defaults to `false`.
  final bool animated;

  /// Duration of cross-fade transition animation when [animated] is `true`. Defaults to 300ms.
  final Duration animationDuration;

  /// The widget subtree protected by access control.
  final Widget child;

  /// Creates a role-gated [SecuredFeature] widget.
  const SecuredFeature({
    super.key,
    required this.allowedRoles,
    this.requireAll = false,
    this.currentRole,
    this.currentRoles,
    this.fallback = FallbackType.hide,
    this.accessDeniedFallback,
    this.fallbackBuilder,
    this.showLockBadge = true,
    this.disabledOpacity = 0.5,
    this.lockIcon,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scope = GuardifyScope.of(context);

    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(
        allowedRoles,
        requireAll: requireAll,
        activeRoles: activeRoles,
      );
    } else {
      final activeMask = RoleRegistry.getMaskForRoles(activeRoles);
      final targetMask = RoleRegistry.getMaskForRoles(allowedRoles);
      isAuthorized = RoleRegistry.matchMask(
        activeMask: activeMask,
        targetMask: targetMask,
        requireAll: requireAll,
      );
    }

    final resultWidget = switch ((
      isAuthorized,
      accessDeniedFallback,
      fallbackBuilder ?? scope?.fallbackBuilder,
    )) {
      (true, _, _) => child,
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => switch (fallback) {
          FallbackType.hide => const SizedBox.shrink(),
          FallbackType.scaffold => Scaffold(
              appBar: AppBar(
                title: const Text('Access Denied'),
              ),
              body: const Center(
                child: Text(
                  'Access Denied: Restricted Area!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          FallbackType.text => const Center(
              child: Text(
                'Access Denied: Restricted Area!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          FallbackType.disabled => LockOverlay(
              opacity: disabledOpacity,
              showLockBadge: showLockBadge,
              lockIcon: lockIcon,
              child: child,
            ),
        },
    };

    if (animated) {
      return AnimatedSwitcher(
        duration: animationDuration,
        child: KeyedSubtree(
          key: ValueKey<bool>(isAuthorized),
          child: resultWidget,
        ),
      );
    }

    return resultWidget;
  }
}
