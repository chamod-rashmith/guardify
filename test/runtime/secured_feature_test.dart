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

    testWidgets('Respects requireAll=true constraint on SecuredFeature', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRoles: ['manager'],
            child: SecuredFeature(
              allowedRoles: ['manager', 'finance'],
              requireAll: true,
              child: Text('Financial Overview'),
            ),
          ),
        ),
      );

      expect(find.text('Financial Overview'), findsNothing);

      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRoles: ['manager', 'finance'],
            child: SecuredFeature(
              allowedRoles: ['manager', 'finance'],
              requireAll: true,
              child: Text('Financial Overview'),
            ),
          ),
        ),
      );

      expect(find.text('Financial Overview'), findsOneWidget);
    });

    testWidgets('Renders when authorized via direct widget currentRole / currentRoles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecuredFeature(
            allowedRoles: ['editor'],
            currentRole: 'editor',
            child: Text('Editor Workspace'),
          ),
        ),
      );

      expect(find.text('Editor Workspace'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: SecuredFeature(
            allowedRoles: ['editor', 'admin'],
            requireAll: true,
            currentRoles: ['editor', 'admin'],
            child: Text('Super Editor Workspace'),
          ),
        ),
      );

      expect(find.text('Super Editor Workspace'), findsOneWidget);
    });

    testWidgets('Renders accessDeniedFallback widget override when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'guest',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              accessDeniedFallback: Text('Direct Fallback Override'),
              child: Text('Secret Content'),
            ),
          ),
        ),
      );

      expect(find.text('Secret Content'), findsNothing);
      expect(find.text('Direct Fallback Override'), findsOneWidget);
    });

    testWidgets('Renders LockOverlay without badge when showLockBadge is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.disabled,
              showLockBadge: false,
              disabledOpacity: 0.3,
              child: Text('Disabled Without Badge'),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Without Badge'), findsOneWidget);
      final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacityWidget.opacity, equals(0.3));
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('Renders custom lockIcon in LockOverlay when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuardifyScope(
            currentRole: 'user',
            child: SecuredFeature(
              allowedRoles: ['admin'],
              fallback: FallbackType.disabled,
              lockIcon: Icon(Icons.key, key: ValueKey('custom_key_icon')),
              child: Text('Key Locked Feature'),
            ),
          ),
        ),
      );

      expect(find.text('Key Locked Feature'), findsOneWidget);
      expect(find.byKey(const ValueKey('custom_key_icon')), findsOneWidget);
    });
  });
}
