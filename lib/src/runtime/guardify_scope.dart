import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for custom permission evaluation callbacks.
///
/// Implement this function to inject dynamic permission rules, JWT token claim
/// evaluations, dynamic feature flags, or async authorization engines into Guardify.
///
/// Parameters:
/// - [allowedRoles]: The list of roles authorized by the target [@Secured] or [RoleGate] widget.
/// - [requireAll]: Whether all roles and permissions are required (`true`) or any single role/permission matches (`false`).
/// - [activeRoles]: The set of active roles currently present in the scope/widget.
/// - [allowedPermissions]: Optional list of fine-grained permissions required.
/// - [activePermissions]: The set of active permissions currently present in the scope/widget.
typedef PermissionChecker = bool Function(
  List<String> allowedRoles, {
  bool requireAll,
  Set<String>? activeRoles,
  List<String>? allowedPermissions,
  Set<String>? activePermissions,
});

/// Signature for generating dynamic fallback UI when access is denied.
///
/// Receives the build context along with lists of [missingRoles] and [missingPermissions].
typedef GuardifyFallbackBuilder = Widget Function(
  BuildContext context,
  List<String> missingRoles,
  List<String> missingPermissions,
);

/// An [InheritedWidget] that supplies active user role state, permission state,
/// and authorization logic to descendant widgets.
///
/// Place [GuardifyScope] near the root of your application (or above role-restricted
/// widget subtrees) to broadcast active roles and permissions down the widget tree.
///
/// ### Example Usage:
/// ```dart
/// GuardifyScope(
///   currentRole: 'admin',
///   currentPermissions: const {'users:delete', 'reports:export'},
///   child: MaterialApp(
///     home: MyHomeScreen(),
///   ),
/// )
/// ```
///
/// Descendant widgets (and generated `Secured<Widget>` wrappers or [RoleGate]) look up the nearest
/// [GuardifyScope] via [GuardifyScope.of] or [BuildContext] extension methods.
class GuardifyScope extends InheritedWidget {
  /// The active user role as a single role string or enum string representation.
  final String? currentRole;

  /// Multiple active user roles (e.g. for users with multiple concurrent permissions).
  final Iterable<String>? currentRoles;

  /// A single active permission string.
  final String? currentPermission;

  /// Multiple active permission strings (PBAC).
  final Iterable<String>? currentPermissions;

  /// Optional custom permission checking function.
  ///
  /// When provided, this callback overrides standard role-matching logic.
  final PermissionChecker? permissionChecker;

  /// Global fallback UI builder invoked when authorization is denied and no
  /// local fallback is specified.
  final GuardifyFallbackBuilder? fallbackBuilder;

  /// Creates a [GuardifyScope] to propagate role and permission state down the widget tree.
  const GuardifyScope({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
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
  static Set<String> collectRoles({
    String? currentRole,
    Iterable<String>? currentRoles,
    GuardifyScope? scope,
  }) {
    final activeRoles = <String>{};

    void addRole(String? role) {
      if (role == null) return;
      final trimmed = role.trim();
      if (trimmed.isEmpty) return;
      activeRoles.add(trimmed);
      if (trimmed.contains('.')) {
        activeRoles.add(trimmed.split('.').last.trim());
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

  /// Collects active user permission strings from direct parameters and ambient scope.
  static Set<String> collectPermissions({
    String? currentPermission,
    Iterable<String>? currentPermissions,
    GuardifyScope? scope,
  }) {
    final activePermissions = <String>{};

    void addPermission(String? perm) {
      if (perm == null) return;
      final trimmed = perm.trim();
      if (trimmed.isEmpty) return;
      activePermissions.add(trimmed);
    }

    addPermission(currentPermission);
    if (currentPermissions != null) {
      for (final perm in currentPermissions) {
        addPermission(perm);
      }
    }

    if (scope != null) {
      addPermission(scope.currentPermission);
      if (scope.currentPermissions != null) {
        for (final perm in scope.currentPermissions!) {
          addPermission(perm);
        }
      }
    }

    return activePermissions;
  }

  /// Evaluates whether the active scope configuration grants authorization for [allowedRoles]
  /// and [allowedPermissions].
  bool isAuthorized(
    List<String> allowedRoles, {
    bool requireAll = false,
    List<String> allowedPermissions = const [],
  }) {
    if (allowedRoles.isEmpty && allowedPermissions.isEmpty) return false;

    final activeRoles = collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
    );

    final activePermissions = collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
    );

    if (permissionChecker != null) {
      return permissionChecker!(
        allowedRoles,
        requireAll: requireAll,
        activeRoles: activeRoles,
        allowedPermissions: allowedPermissions,
        activePermissions: activePermissions,
      );
    }

    final hasRolesToCheck = allowedRoles.isNotEmpty;
    final hasPermissionsToCheck = allowedPermissions.isNotEmpty;

    if (requireAll) {
      final rolesSatisfied = !hasRolesToCheck || allowedRoles.every(activeRoles.contains);
      final permissionsSatisfied = !hasPermissionsToCheck || allowedPermissions.every(activePermissions.contains);
      return rolesSatisfied && permissionsSatisfied;
    } else {
      final roleMatch = hasRolesToCheck && allowedRoles.any(activeRoles.contains);
      final permissionMatch = hasPermissionsToCheck && allowedPermissions.any(activePermissions.contains);
      return roleMatch || permissionMatch;
    }
  }

  /// Creates a reactive [GuardifyScope] driven by a [Listenable] (e.g. [ChangeNotifier] or [ValueListenable]).
  ///
  /// Automatically rebuilds descendant scope widgets whenever [listenable] notifies.
  /// If [listenable] is a `ValueListenable<String?>` or `ValueListenable<List<String>>`,
  /// roles are inferred automatically unless explicit provider functions are supplied.
  static Widget listenable({
    Key? key,
    required Listenable listenable,
    String? Function()? roleProvider,
    Iterable<String>? Function()? rolesProvider,
    String? Function()? permissionProvider,
    Iterable<String>? Function()? permissionsProvider,
    PermissionChecker? permissionChecker,
    GuardifyFallbackBuilder? fallbackBuilder,
    required Widget child,
  }) {
    return ListenableBuilder(
      key: key,
      listenable: listenable,
      builder: (context, _) {
        String? role;
        Iterable<String>? roles;

        if (roleProvider != null) {
          role = roleProvider();
        } else if (listenable is ValueListenable<String?>) {
          role = listenable.value;
        }

        if (rolesProvider != null) {
          roles = rolesProvider();
        } else if (listenable is ValueListenable<List<String>>) {
          roles = listenable.value;
        } else if (listenable is ValueListenable<Set<String>>) {
          roles = listenable.value;
        }

        final permission = permissionProvider?.call();
        final permissions = permissionsProvider?.call();

        return GuardifyScope(
          currentRole: role,
          currentRoles: roles,
          currentPermission: permission,
          currentPermissions: permissions,
          permissionChecker: permissionChecker,
          fallbackBuilder: fallbackBuilder,
          child: child,
        );
      },
    );
  }

  /// Creates a reactive [GuardifyScope] driven by asynchronous [Stream] updates.
  static Widget stream({
    Key? key,
    Stream<dynamic>? roleStream,
    Stream<Iterable<String>>? rolesStream,
    Stream<Iterable<String>>? permissionsStream,
    PermissionChecker? permissionChecker,
    GuardifyFallbackBuilder? fallbackBuilder,
    required Widget child,
  }) {
    return StreamBuilder<dynamic>(
      key: key,
      stream: roleStream,
      builder: (context, roleSnap) {
        return StreamBuilder<Iterable<String>>(
          stream: rolesStream,
          builder: (context, rolesSnap) {
            return StreamBuilder<Iterable<String>>(
              stream: permissionsStream,
              builder: (context, permsSnap) {
                final roleVal = roleSnap.data?.toString();
                return GuardifyScope(
                  currentRole: roleVal,
                  currentRoles: rolesSnap.data,
                  currentPermissions: permsSnap.data,
                  permissionChecker: permissionChecker,
                  fallbackBuilder: fallbackBuilder,
                  child: child,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  bool updateShouldNotify(GuardifyScope oldWidget) {
    if (currentRole != oldWidget.currentRole ||
        currentPermission != oldWidget.currentPermission ||
        permissionChecker != oldWidget.permissionChecker ||
        fallbackBuilder != oldWidget.fallbackBuilder) {
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

    if (newRoles.length != oldRoles.length || !newRoles.every(oldRoles.contains)) {
      return true;
    }

    final newPerms = <String>{
      if (currentPermission != null) currentPermission!,
      if (currentPermissions != null) ...currentPermissions!,
    };
    final oldPerms = <String>{
      if (oldWidget.currentPermission != null) oldWidget.currentPermission!,
      if (oldWidget.currentPermissions != null) ...oldWidget.currentPermissions!,
    };

    if (newPerms.length != oldPerms.length || !newPerms.every(oldPerms.contains)) {
      return true;
    }

    return false;
  }
}
