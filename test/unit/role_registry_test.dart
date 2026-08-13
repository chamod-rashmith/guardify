import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('RoleRegistry Bitwise Engine Tests', () {
    setUp(() {
      RoleRegistry.resetRegistry();
    });

    test('getMaskForRole assigns unique power of 2 bitmask values', () {
      final adminMask = RoleRegistry.getMaskForRole('admin');
      final managerMask = RoleRegistry.getMaskForRole('manager');
      final userMask = RoleRegistry.getMaskForRole('user');

      expect(adminMask, equals(1)); // 1 << 0
      expect(managerMask, equals(2)); // 1 << 1
      expect(userMask, equals(4)); // 1 << 2
      expect(adminMask & managerMask, equals(0));
      expect(adminMask & userMask, equals(0));
    });

    test('getMaskForRole reuses bitmask for identical roles and enum dot notations', () {
      final mask1 = RoleRegistry.getMaskForRole('UserRole.admin');
      final mask2 = RoleRegistry.getMaskForRole('admin');
      final mask3 = RoleRegistry.getMaskForRole('UserRole.admin');

      expect(mask1, equals(mask2));
      expect(mask2, equals(mask3));
    });

    test('getMaskForRoles combines role masks via bitwise OR', () {
      final combined = RoleRegistry.getMaskForRoles(['admin', 'manager']);
      final adminMask = RoleRegistry.getMaskForRole('admin');
      final managerMask = RoleRegistry.getMaskForRole('manager');

      expect(combined, equals(adminMask | managerMask));
    });

    test('matchMask handles any role (OR logic) correctly', () {
      final activeMask = RoleRegistry.getMaskForRoles(['admin']);
      final targetMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);

      expect(
        RoleRegistry.matchMask(
          activeMask: activeMask,
          targetMask: targetMask,
          requireAll: false,
        ),
        isTrue,
      );
    });

    test('matchMask handles requireAll (AND logic) correctly', () {
      final activeMask1 = RoleRegistry.getMaskForRoles(['admin']);
      final activeMask2 = RoleRegistry.getMaskForRoles(['admin', 'manager']);
      final targetMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);

      // Only 1 of 2 active -> requireAll fails
      expect(
        RoleRegistry.matchMask(
          activeMask: activeMask1,
          targetMask: targetMask,
          requireAll: true,
        ),
        isFalse,
      );

      // Both active -> requireAll succeeds
      expect(
        RoleRegistry.matchMask(
          activeMask: activeMask2,
          targetMask: targetMask,
          requireAll: true,
        ),
        isTrue,
      );
    });

    test('matchMask returns false when targetMask or activeMask is zero', () {
      expect(
        RoleRegistry.matchMask(
          activeMask: 0,
          targetMask: RoleRegistry.getMaskForRole('admin'),
        ),
        isFalse,
      );

      expect(
        RoleRegistry.matchMask(
          activeMask: RoleRegistry.getMaskForRole('admin'),
          targetMask: 0,
        ),
        isFalse,
      );
    });
  });
}
