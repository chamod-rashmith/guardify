import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

import '../example/guardify_example.dart';

void main() {
  group('1. Secured Annotation Unit Tests', () {
    test('Secured annotation holds default values', () {
      const secured = Secured(['admin']);
      expect(secured.allowedRoles, contains('admin'));
      expect(secured.fallback, equals(FallbackType.hide));
      expect(secured.requireAll, isFalse);
      expect(secured.name, isNull);
    });

    test('Secured annotation holds custom values', () {
      const secured = Secured(
        ['manager', 'finance'],
        fallback: FallbackType.scaffold,
        requireAll: true,
        name: 'CustomSecuredCard',
      );
      expect(secured.allowedRoles, containsAll(['manager', 'finance']));
      expect(secured.fallback, equals(FallbackType.scaffold));
      expect(secured.requireAll, isTrue);
      expect(secured.name, equals('CustomSecuredCard'));
    });
  });

  group('2. GuardifyScope & BuildContext Extension Tests', () {
    testWidgets('GuardifyScope supplies single and multiple active roles', (tester) async {
      late bool isAdmin;
      late bool isGuest;

      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                isAdmin = context.hasRole('admin');
                isGuest = context.hasRole('guest');
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isAdmin, isTrue);
      expect(isGuest, isFalse);
    });

    testWidgets('context.hasAnyRole and context.hasAllRoles work correctly', (tester) async {
      late bool hasAny;
      late bool hasAll;

      await tester.pumpWidget(
        GuardifyScope(
          currentRoles: const ['manager', 'finance'],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                hasAny = context.hasAnyRole(['admin', 'manager']);
                hasAll = context.hasAllRoles(['manager', 'finance']);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(hasAny, isTrue);
      expect(hasAll, isTrue);
    });

    testWidgets('GuardifyScope supports custom permissionChecker', (tester) async {
      late bool isAuthorized;

      await tester.pumpWidget(
        GuardifyScope(
          permissionChecker: (allowedRoles, {requireAll = false, activeRoles}) {
            return allowedRoles.contains('superadmin');
          },
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                isAuthorized = context.isAuthorized(['superadmin']);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isAuthorized, isTrue);
    });

    testWidgets('Returns false when GuardifyScope is missing', (tester) async {
      late bool isAuth;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isAuth = context.hasRole('admin');
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isAuth, isFalse);
    });
  });

  group('3. Generated Secured Widgets Tests', () {
    testWidgets('SecuredDeleteUserButton renders when authorized with direct currentRole', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecuredDeleteUserButton(
              currentRole: 'admin',
              userId: 'USR-100',
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('SecuredDeleteUserButton renders when authorized via GuardifyScope', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-200',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('SecuredDeleteUserButton hides when unauthorized (guest)', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-100',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsNothing);
    });

    testWidgets('Renders custom runtime fallback when provided and unauthorized', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-100',
                onDelete: () {},
                fallback: const Text('Access Denied Custom Fallback'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Access Denied Custom Fallback'), findsOneWidget);
      expect(find.byType(DeleteUserButton), findsNothing);
    });

    testWidgets('SecuredGenericDataCard<T> renders when role matches enum admin role', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredGenericDataCard<int>(
                title: 'Secret Code',
                data: 1337,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Secret Code: 1337'), findsOneWidget);
    });

    testWidgets('SecuredGenericDataCard<T> renders when role matches qualified enum string DemoRole.admin', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'DemoRole.admin',
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredGenericDataCard<int>(
                title: 'Secret Code',
                data: 1337,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Secret Code: 1337'), findsOneWidget);
    });

    testWidgets('SecuredNamedConstructorWidget renders target via named constructor', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredNamedConstructorWidget(
                label: 'TestLabel',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Primary: TestLabel'), findsOneWidget);
    });

    testWidgets('SecuredTargetWidgetWithFallback handles fallback property collision cleanly', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredTargetWidgetWithFallback(
                fallback: Text('Internal Target Fallback'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Internal Target Fallback'), findsOneWidget);
    });

    testWidgets('SecuredAdminDashboardScreen renders const target widget when authorized', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: const MaterialApp(
            home: SecuredAdminDashboardScreen(),
          ),
        ),
      );

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsOneWidget);
    });

    testWidgets('SecuredAdminDashboardScreen renders scaffold fallback when unauthorized', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          child: const MaterialApp(
            home: SecuredAdminDashboardScreen(),
          ),
        ),
      );

      expect(find.byType(AdminDashboardScreen), findsNothing);
      expect(find.text('Access Denied: Restricted Area!'), findsOneWidget);
    });

    testWidgets('SecuredFinancialReportCard requires all roles to render', (tester) async {
      // Test when only 1 of 2 required roles is active -> Should hide
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'manager',
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredFinancialReportCard(totalRevenue: 5000),
            ),
          ),
        ),
      );

      expect(find.byType(FinancialReportCard), findsNothing);

      // Test when both required roles are active via currentRoles -> Should render
      await tester.pumpWidget(
        GuardifyScope(
          currentRoles: const ['manager', 'finance'],
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredFinancialReportCard(totalRevenue: 5000),
            ),
          ),
        ),
      );

      expect(find.byType(FinancialReportCard), findsOneWidget);
      expect(find.text('Total Revenue: \$5000.00'), findsOneWidget);
    });

    testWidgets('Returns false when allowedRoles is empty', (tester) async {
      late bool isAuthorized;
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                isAuthorized = context.isAuthorized([]);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(isAuthorized, isFalse);
    });

    test('GuardifyScope updateShouldNotify checks content equality rather than reference equality', () {
      const scope1 = GuardifyScope(
        currentRoles: ['admin', 'manager'],
        child: SizedBox(),
      );
      const scope2 = GuardifyScope(
        currentRoles: ['admin', 'manager'],
        child: SizedBox(),
      );
      expect(scope1.updateShouldNotify(scope2), isFalse);
    });

    testWidgets('permissionChecker receives activeRoles including direct widget role', (tester) async {
      Set<String>? receivedActiveRoles;
      await tester.pumpWidget(
        GuardifyScope(
          permissionChecker: (allowedRoles, {requireAll = false, activeRoles}) {
            receivedActiveRoles = activeRoles;
            return activeRoles?.contains('admin') ?? false;
          },
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                currentRole: 'admin',
                userId: 'USR-777',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(receivedActiveRoles, contains('admin'));
      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('GuardifyScope normalizes qualified enum strings in currentRole for context extensions', (tester) async {
      late bool hasRoleAdmin;
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'DemoRole.admin',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                hasRoleAdmin = context.hasRole('admin');
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(hasRoleAdmin, isTrue);
    });
  });
}




