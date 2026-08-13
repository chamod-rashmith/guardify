import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
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
