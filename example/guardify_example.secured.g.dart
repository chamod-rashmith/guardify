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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return DeleteUserButton(userId: userId, onDelete: onDelete);
    }

    if (fallback != null) {
      return fallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return const SizedBox.shrink();
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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: true,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.every(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return FinancialReportCard(totalRevenue: totalRevenue);
    }

    if (fallback != null) {
      return fallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return const Center(
      child: Text(
        'Access Denied: Restricted Area!',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return const AdminDashboardScreen();
    }

    if (fallback != null) {
      return fallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return Scaffold(
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
    );
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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return GenericDataCard<T>(data: data, title: title);
    }

    if (fallback != null) {
      return fallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return const Center(
      child: Text(
        'Access Denied: Restricted Area!',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return NamedConstructorWidget.primary(label: label);
    }

    if (fallback != null) {
      return fallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return const SizedBox.shrink();
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

    // 3. Aggregate and normalize active roles from widget properties and scope
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    // Guards against empty allowedRoles and handles requireAll constraint
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: false,
            activeRoles: activeRoles,
          )
        : allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains);

    // 5. Render target component or fallback widget using Dart 3 switch expression
    // Returns target widget if authorized; otherwise returns custom fallback, scope fallbackBuilder, or strategy default
    if (isAuthorized) {
      return TargetWidgetWithFallback(fallback: fallback);
    }

    if (accessDeniedFallback != null) {
      return accessDeniedFallback!;
    }

    if (scope?.fallbackBuilder != null) {
      final missingRoles =
          allowedRoles.where((r) => !activeRoles.contains(r)).toList();
      return scope!.fallbackBuilder!(context, missingRoles, const <String>[]);
    }

    return const SizedBox.shrink();
  }
}
