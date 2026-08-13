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

    test('GuardifyScope.collectRoles normalizes enum strings and combines scope parameters correctly', () {
      final scope = const GuardifyScope(
        currentRole: 'UserRole.superadmin',
        currentRoles: ['manager', 'Role.finance'],
        child: SizedBox(),
      );

      final collected = GuardifyScope.collectRoles(
        currentRole: 'UserRole.admin',
        currentRoles: ['editor'],
        scope: scope,
      );

      expect(
        collected,
        containsAll([
          'UserRole.admin',
          'admin',
          'editor',
          'UserRole.superadmin',
          'superadmin',
          'manager',
          'Role.finance',
          'finance',
        ]),
      );
    });

    test('GuardifyScope.isAuthorized evaluates requireAll and single matching correctly', () {
      const scope = GuardifyScope(
        currentRoles: ['admin', 'editor'],
        child: SizedBox(),
      );

      expect(scope.isAuthorized(['admin', 'viewer'], requireAll: false), isTrue);
      expect(scope.isAuthorized(['admin', 'editor'], requireAll: true), isTrue);
      expect(scope.isAuthorized(['admin', 'viewer'], requireAll: true), isFalse);
      expect(scope.isAuthorized([], requireAll: false), isFalse);
    });

    test('GuardifyScope updateShouldNotify notifies when fallbackBuilder changes', () {
      Widget dummyBuilder1(BuildContext context, List<String> r, List<String> p) => const SizedBox();
      Widget dummyBuilder2(BuildContext context, List<String> r, List<String> p) => const SizedBox();

      final scope1 = GuardifyScope(
        currentRole: 'admin',
        fallbackBuilder: dummyBuilder1,
        child: const SizedBox(),
      );

      final scope2 = GuardifyScope(
        currentRole: 'admin',
        fallbackBuilder: dummyBuilder2,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });
  });
}
