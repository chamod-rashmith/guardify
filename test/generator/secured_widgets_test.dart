import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

import '../../example/guardify_example.dart';

void main() {
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

    testWidgets('Generated widget normalizes qualified enum string UserRole.admin when widget requires admin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecuredDeleteUserButton(
              currentRole: 'UserRole.admin',
              userId: 'USR-888',
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('Generated widget with enum role in GuardifyScope renders target widget requiring base role', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'UserRole.admin',
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-999',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('Generated widget invokes GuardifyScope.fallbackBuilder when unauthorized', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          fallbackBuilder: (context, missingRoles, missingPermissions) {
            return Text('Generated Fallback: ${missingRoles.join(', ')}');
          },
          child: MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-000',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsNothing);
      expect(find.text('Generated Fallback: admin, superadmin'), findsOneWidget);
    });
  });
}
