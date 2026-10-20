import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('GuardifyRouteGuard & guardifyRedirect Tests', () {
    testWidgets('guard returns null when user possesses authorized role', (tester) async {
      String? redirectResult;

      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'admin',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final guard = const GuardifyRouteGuard(
                  allowedRoles: ['admin'],
                  fallbackPath: '/login',
                );
                redirectResult = guard(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(redirectResult, isNull);
    });

    testWidgets('guard returns fallbackPath when user lacks authorized role', (tester) async {
      String? redirectResult;

      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final guard = const GuardifyRouteGuard(
                  allowedRoles: ['admin'],
                  fallbackPath: '/forbidden',
                );
                redirectResult = guard(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(redirectResult, equals('/forbidden'));
    });

    testWidgets('guardifyRedirect helper returns fallbackPath when unauthorized', (tester) async {
      String? redirectResult;

      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'user',
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                redirectResult = guardifyRedirect(
                  context,
                  allowedRoles: ['superadmin'],
                  fallbackPath: '/upgrade',
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(redirectResult, equals('/upgrade'));
    });
  });
}
