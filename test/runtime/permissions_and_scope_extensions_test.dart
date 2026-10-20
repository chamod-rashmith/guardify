import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

import '../../example/guardify_example.dart';

void main() {
  group('Permissions (PBAC) & Reactive Scope Tests', () {
    testWidgets('context.hasPermission, hasAnyPermission, and hasAllPermissions work correctly', (tester) async {
      late bool hasDelete;
      late bool hasEdit;
      late bool hasAny;
      late bool hasAll;

      await tester.pumpWidget(
        GuardifyScope(
          currentPermissions: const ['users:read', 'users:delete'],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                hasDelete = context.hasPermission('users:delete');
                hasEdit = context.hasPermission('users:edit');
                hasAny = context.hasAnyPermission(['users:edit', 'users:read']);
                hasAll = context.hasAllPermissions(['users:read', 'users:delete']);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(hasDelete, isTrue);
      expect(hasEdit, isFalse);
      expect(hasAny, isTrue);
      expect(hasAll, isTrue);
    });

    testWidgets('GuardifyScope.listenable reacts dynamically when ValueNotifier updates', (tester) async {
      final roleNotifier = ValueNotifier<String>('guest');

      await tester.pumpWidget(
        GuardifyScope.listenable(
          listenable: roleNotifier,
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-REACTIVE',
                onDelete: _dummyCallback,
              ),
            ),
          ),
        ),
      );

      // Initially guest -> hidden
      expect(find.byType(DeleteUserButton), findsNothing);

      // Change role to admin -> automatically rebuilds and displays
      roleNotifier.value = 'admin';
      await tester.pumpAndSettle();

      expect(find.byType(DeleteUserButton), findsOneWidget);
    });

    testWidgets('GuardifyScope.stream reacts when stream emits new roles', (tester) async {
      final roleController = StreamController<String>.broadcast();

      await tester.pumpWidget(
        GuardifyScope.stream(
          roleStream: roleController.stream,
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-STREAM',
                onDelete: _dummyCallback,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DeleteUserButton), findsNothing);

      roleController.add('admin');
      await tester.pump();

      expect(find.byType(DeleteUserButton), findsOneWidget);

      await roleController.close();
    });

    testWidgets('Ambient GuardifyScope.fallbackBuilder is invoked for generated secured widgets', (tester) async {
      await tester.pumpWidget(
        GuardifyScope(
          currentRole: 'guest',
          fallbackBuilder: (context, missingRoles, missingPerms) {
            return Text('Global Fallback for: ${missingRoles.join(', ')}');
          },
          child: const MaterialApp(
            home: Scaffold(
              body: SecuredDeleteUserButton(
                userId: 'USR-GLOBAL-FB',
                onDelete: _dummyCallback,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Global Fallback for: admin, superadmin'), findsOneWidget);
      expect(find.byType(DeleteUserButton), findsNothing);
    });
  });
}

void _dummyCallback() {}
