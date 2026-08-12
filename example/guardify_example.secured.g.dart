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
    const allowedRoles = <String>['admin', 'superadmin'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: false);
    } else {
      isAuthorized = allowedRoles.any((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return DeleteUserButton(userId: userId, onDelete: onDelete);
    }

    if (fallback != null) {
      return fallback!;
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
    const allowedRoles = <String>['manager', 'finance'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: true);
    } else {
      isAuthorized = allowedRoles.every((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return FinancialReportCard(totalRevenue: totalRevenue);
    }

    if (fallback != null) {
      return fallback!;
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
    const allowedRoles = <String>['admin'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: false);
    } else {
      isAuthorized = allowedRoles.any((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return const AdminDashboardScreen();
    }

    if (fallback != null) {
      return fallback!;
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
    const allowedRoles = <String>['admin', 'DemoRole.admin'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: false);
    } else {
      isAuthorized = allowedRoles.any((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return GenericDataCard<T>(data: data, title: title);
    }

    if (fallback != null) {
      return fallback!;
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
    const allowedRoles = <String>['admin'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: false);
    } else {
      isAuthorized = allowedRoles.any((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return NamedConstructorWidget.primary(label: label);
    }

    if (fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}

class SecuredTargetWidgetWithFallback extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;

  const SecuredTargetWidgetWithFallback({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    const allowedRoles = <String>['admin'];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole case final role?) role,
      ...?currentRoles,
      if (scope?.currentRole case final role?) role,
      ...?scope?.currentRoles,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: false);
    } else {
      isAuthorized = allowedRoles.any((r) => activeRoles.contains(r));
    }

    if (isAuthorized) {
      return TargetWidgetWithFallback(fallback: fallback);
    }

    if (fallback != null) {
      return fallback!;
    }

    return const SizedBox.shrink();
  }
}
