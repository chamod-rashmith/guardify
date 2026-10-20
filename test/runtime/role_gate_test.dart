import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('RoleGate Runtime Widget Tests', () {
    testWidgets('renders child when authorized via ambient GuardifyScope', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'admin',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: ['admin'],
                child: Text('Protected Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsOneWidget);
    });

    testWidgets('hides child (renders SizedBox.shrink) when unauthorized and fallbackType is hide', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: ['admin'],
                fallbackType: FallbackType.hide,
                child: Text('Protected Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('renders custom fallback widget when unauthorized', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: ['admin'],
                fallback: Text('Locked Placeholder'),
                child: Text('Protected Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Locked Placeholder'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('invokes fallbackBuilder with missing roles', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'user',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: const ['admin', 'manager'],
                requireAll: true,
                fallbackBuilder: (context, missingRoles, missingPerms) {
                  return Text('Missing: ${missingRoles.join(', ')}');
                },
                child: const Text('Protected Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Missing: admin, manager'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('renders FallbackType.disabled with AbsorbPointer and Opacity', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: ['admin'],
                fallbackType: FallbackType.disabled,
                disabledOpacity: 0.4,
                child: Text('Disabled Action'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Action'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RoleGate),
          matching: find.byType(AbsorbPointer),
        ),
        findsOneWidget,
      );

      final opacityWidget = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(RoleGate),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacityWidget.opacity, 0.4);
    });

    testWidgets('renders FallbackType.disabled with lockBadge in Stack', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: ['admin'],
                fallbackType: FallbackType.disabled,
                lockBadge: Icon(Icons.lock),
                child: Text('Premium Feature'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Premium Feature'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RoleGate),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('triggers onAccessDenied callback when access is denied', (tester) async {
      var accessDeniedCalled = false;

      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          child: MaterialApp(
            home: Scaffold(
              body: RoleGate(
                allowedRoles: const ['admin'],
                onAccessDenied: () {
                  accessDeniedCalled = true;
                },
                child: const Text('Admin Only'),
              ),
            ),
          ),
        ),
      );

      expect(accessDeniedCalled, isTrue);
    });

    testWidgets('supports SecuredFeature alias identically', (tester) async {
      await tester.pumpWidget(
        const GuardifyScope(
          currentRole: 'editor',
          child: MaterialApp(
            home: Scaffold(
              body: SecuredFeature(
                allowedRoles: ['editor'],
                child: Text('Editor Area'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Editor Area'), findsOneWidget);
    });
  });
}
