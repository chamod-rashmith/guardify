// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'guardify_example.dart';

// **************************************************************************
// SecuredGenerator
// **************************************************************************

class SecuredDeleteUserButton extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  final String userId;
  final void Function() onDelete;

  const SecuredDeleteUserButton({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
    required this.userId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['admin', 'superadmin'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: false,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((isAuthorized, fallback, scope?.fallbackBuilder)) {
      (true, _, _) => DeleteUserButton(userId: userId, onDelete: onDelete),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class SecuredFinancialReportCard extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  final double totalRevenue;

  const SecuredFinancialReportCard({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['manager', 'finance'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: true,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: true,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((isAuthorized, fallback, scope?.fallbackBuilder)) {
      (true, _, _) => FinancialReportCard(totalRevenue: totalRevenue),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => const Center(
          child: Text(
            'Access Denied: Restricted Area!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
    };
  }
}

class SecuredAdminDashboardScreen extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  const SecuredAdminDashboardScreen({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['admin'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: false,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((isAuthorized, fallback, scope?.fallbackBuilder)) {
      (true, _, _) => const AdminDashboardScreen(),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => Scaffold(
          appBar: AppBar(title: const Text('Access Denied')),
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
    };
  }
}

class SecuredGenericDataCard<T> extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  final T data;
  final String title;

  const SecuredGenericDataCard({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['admin', 'DemoRole.admin'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: false,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((isAuthorized, fallback, scope?.fallbackBuilder)) {
      (true, _, _) => GenericDataCard<T>(data: data, title: title),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => const Center(
          child: Text(
            'Access Denied: Restricted Area!',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
    };
  }
}

class SecuredNamedConstructorWidget extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  final String label;

  const SecuredNamedConstructorWidget({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['admin'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: false,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((isAuthorized, fallback, scope?.fallbackBuilder)) {
      (true, _, _) => NamedConstructorWidget.primary(label: label),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class SecuredTargetWidgetWithFallback extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? accessDeniedFallback;

  final Widget? fallback;

  const SecuredTargetWidgetWithFallback({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.accessDeniedFallback,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>['admin'];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: false,
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((
      isAuthorized,
      accessDeniedFallback,
      scope?.fallbackBuilder,
    )) {
      (true, _, _) => TargetWidgetWithFallback(fallback: fallback),
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
