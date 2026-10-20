// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'guardify_example.dart';

// **************************************************************************
// SecuredGenerator
// **************************************************************************

class SecuredDeleteUserButton extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? fallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  final String userId;
  final void Function() onDelete;

  const SecuredDeleteUserButton({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
    required this.userId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['admin', 'superadmin'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: false,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final roleMatch =
            hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
        final permMatch = hasPerms &&
            guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
        guardifyIsAuthorized = roleMatch || permMatch;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return DeleteUserButton(userId: userId, onDelete: onDelete);
    }

    // 6. Return local fallback if provided
    if (fallback != null) {
      return fallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return const SizedBox.shrink();
  }
}

class SecuredFinancialReportCard extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? fallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  final double totalRevenue;

  const SecuredFinancialReportCard({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['manager', 'finance'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: true,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final rolesOk = !hasRoles ||
            guardifyAllowedRoles.every(guardifyActiveRoles.contains);
        final permsOk = !hasPerms ||
            guardifyAllowedPermissions.every(
              guardifyActivePermissions.contains,
            );
        guardifyIsAuthorized = rolesOk && permsOk;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return FinancialReportCard(totalRevenue: totalRevenue);
    }

    // 6. Return local fallback if provided
    if (fallback != null) {
      return fallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return const Center(
      child: Text(
        'Access Denied: Restricted Area!',
        style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SecuredAdminDashboardScreen extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? fallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  const SecuredAdminDashboardScreen({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['admin'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: false,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final roleMatch =
            hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
        final permMatch = hasPerms &&
            guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
        guardifyIsAuthorized = roleMatch || permMatch;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return const AdminDashboardScreen();
    }

    // 6. Return local fallback if provided
    if (fallback != null) {
      return fallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
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
    );
  }
}

class SecuredGenericDataCard<T> extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? fallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  final T data;
  final String title;

  const SecuredGenericDataCard({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['admin', 'DemoRole.admin'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: false,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final roleMatch =
            hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
        final permMatch = hasPerms &&
            guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
        guardifyIsAuthorized = roleMatch || permMatch;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return GenericDataCard<T>(data: data, title: title);
    }

    // 6. Return local fallback if provided
    if (fallback != null) {
      return fallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return const Center(
      child: Text(
        'Access Denied: Restricted Area!',
        style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class SecuredNamedConstructorWidget extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? fallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  final String label;

  const SecuredNamedConstructorWidget({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.fallback,
    this.fallbackBuilder,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['admin'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: false,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final roleMatch =
            hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
        final permMatch = hasPerms &&
            guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
        guardifyIsAuthorized = roleMatch || permMatch;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return NamedConstructorWidget.primary(label: label);
    }

    // 6. Return local fallback if provided
    if (fallback != null) {
      return fallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return const SizedBox.shrink();
  }
}

class SecuredTargetWidgetWithFallback extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final String? currentPermission;
  final Iterable<String>? currentPermissions;
  final Widget? accessDeniedFallback;
  final GuardifyFallbackBuilder? fallbackBuilder;

  final Widget? fallback;

  const SecuredTargetWidgetWithFallback({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.currentPermission,
    this.currentPermissions,
    this.accessDeniedFallback,
    this.fallbackBuilder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>['admin'];
    const guardifyAllowedPermissions = <String>[];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: false,
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        final roleMatch =
            hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
        final permMatch = hasPerms &&
            guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
        guardifyIsAuthorized = roleMatch || permMatch;
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return TargetWidgetWithFallback(fallback: fallback);
    }

    // 6. Return local fallback if provided
    if (accessDeniedFallback != null) {
      return accessDeniedFallback!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        fallbackBuilder ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles
          .where((r) => !guardifyActiveRoles.contains(r))
          .toList();
      final missingPerms = guardifyAllowedPermissions
          .where((p) => !guardifyActivePermissions.contains(p))
          .toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return const SizedBox.shrink();
  }
}
