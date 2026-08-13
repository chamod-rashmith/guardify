import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('SecuredFeature Runtime Widget Tests', () {
    testWidgets('Renders child widget when authorized via ambient GuardifyScope', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'admin',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              child: Text('Admin Control Panel'),
            ),
          ),
        ),
      );

      expect(find.text('Admin Control Panel'), findsOneWidget);
    });

    testWidgets('Hides child widget (FallbackType.hide) when unauthorized', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.hide,
              child: Text('Admin Control Panel'),
            ),
          ),
        ),
      );

      expect(find.text('Admin Control Panel'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('Renders text fallback when unauthorized with FallbackType.text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.text,
              child: Text('Admin Control Panel'),
            ),
          ),
        ),
      );

      expect(find.text('Admin Control Panel'), findsNothing);
      expect(find.text('Access Denied: Restricted Area!'), findsOneWidget);
    });

    testWidgets('Renders scaffold fallback when unauthorized with FallbackType.scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'guest',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.scaffold,
              child: Text('Admin Settings'),
            ),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Access Denied'), findsOneWidget);
    });

    testWidgets('Renders disabled lock overlay when unauthorized with FallbackType.disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.disabled,
              showLockBadge: true,
              child: Text('Premium Export Feature'),
            ),
          ),
        ),
      );

      expect(find.text('Premium Export Feature'), findsOneWidget);
      final absorbingFinder = find.byWidgetPredicate((widget) => widget is AbsorbPointer && widget.absorbing);
      expect(absorbingFinder, findsOneWidget);
      expect(find.byType(Opacity), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Invokes local fallbackBuilder with missingRoles when unauthorized', (tester) async {
      List<String>? capturedMissingRoles;

      await tester.pumpWidget(
        MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: const ['admin', 'superadmin'],
              fallbackBuilder: (context, missingRoles, missingPermissions) {
                capturedMissingRoles = missingRoles;
                return Text('Required roles: ${missingRoles.join(', ')}');
              },
              child: const Text('Secret Dashboard'),
            ),
          ),
        ),
      );

      expect(find.text('Secret Dashboard'), findsNothing);
      expect(find.text('Required roles: admin, superadmin'), findsOneWidget);
      expect(capturedMissingRoles, equals(['admin', 'superadmin']));
    });

    testWidgets('Invokes global GuardifyScope.fallbackBuilder when local fallback is absent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GuardifyScope(
            currentRole: 'guest',
            fallbackBuilder: (context, missingRoles, missingPermissions) {
              return Text('Global Scope Locked: ${missingRoles.join()}');
            },
            child: const SecuredFeature(
              allowedRoles: ['vip'],
              child: Text('VIP Content'),
            ),
          ),
        ),
      );

      expect(find.text('VIP Content'), findsNothing);
      expect(find.text('Global Scope Locked: vip'), findsOneWidget);
    });

    testWidgets('Wraps result in AnimatedSwitcher when animated is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'admin',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              animated: true,
              animationDuration: Duration(milliseconds: 200),
              child: Text('Animated Feature'),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
      expect(find.text('Animated Feature'), findsOneWidget);
    });
  });
}
