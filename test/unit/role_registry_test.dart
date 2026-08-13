import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('RoleRegistry Engine Unit Tests', () {
    setUp(() {
      RoleRegistry.resetRegistry();
    });

    // -------------------------------------------------------------------------
    // GROUP 1: BITMASK ALLOCATION & STRING NORMALIZATION
    // -------------------------------------------------------------------------
    group('1. Bitmask Allocation & String Normalization', () {
      test('assigns unique 64-bit integer flags (powers of 2) for distinct roles', () {
        final adminMask = RoleRegistry.getMaskForRole('admin');
        final managerMask = RoleRegistry.getMaskForRole('manager');
        final userMask = RoleRegistry.getMaskForRole('user');

        expect(adminMask, equals(1)); // 1 << 0
        expect(managerMask, equals(2)); // 1 << 1
        expect(userMask, equals(4)); // 1 << 2

        // Verify distinct bits (no bit overlap)
        expect(adminMask & managerMask, equals(0));
        expect(adminMask & userMask, equals(0));
        expect(managerMask & userMask, equals(0));
      });

      test('normalizes dot-separated enum role strings to share identical bit position', () {
        final qualifiedMask = RoleRegistry.getMaskForRole('UserRole.admin');
        final simpleMask = RoleRegistry.getMaskForRole('admin');
        final repeatQualified = RoleRegistry.getMaskForRole('UserRole.admin');

        expect(qualifiedMask, equals(simpleMask));
        expect(simpleMask, equals(repeatQualified));
      });

      test('trims surrounding whitespace from role strings before lookup', () {
        final mask1 = RoleRegistry.getMaskForRole('  admin  ');
        final mask2 = RoleRegistry.getMaskForRole('admin');

        expect(mask1, equals(mask2));
      });

      test('returns zero bitmask for empty or whitespace-only role strings', () {
        expect(RoleRegistry.getMaskForRole(''), equals(0));
        expect(RoleRegistry.getMaskForRole('   '), equals(0));
      });
    });

    // -------------------------------------------------------------------------
    // GROUP 2: BITMASK AGGREGATION
    // -------------------------------------------------------------------------
    group('2. Bitmask Aggregation (getMaskForRoles)', () {
      test('combines multiple role bitmasks using bitwise OR (|)', () {
        final adminMask = RoleRegistry.getMaskForRole('admin');
        final managerMask = RoleRegistry.getMaskForRole('manager');

        final combined = RoleRegistry.getMaskForRoles(['admin', 'manager']);

        expect(combined, equals(adminMask | managerMask));
      });

      test('handles empty or null role collections safely', () {
        expect(RoleRegistry.getMaskForRoles(null), equals(0));
        expect(RoleRegistry.getMaskForRoles([]), equals(0));
        expect(RoleRegistry.getMaskForRoles(['', '  ']), equals(0));
      });

      test('aggregates mixed qualified enum strings and simple role names', () {
        final mask = RoleRegistry.getMaskForRoles(['UserRole.admin', 'editor', 'Role.finance']);

        final adminBit = RoleRegistry.getMaskForRole('admin');
        final editorBit = RoleRegistry.getMaskForRole('editor');
        final financeBit = RoleRegistry.getMaskForRole('finance');

        expect(mask, equals(adminBit | editorBit | financeBit));
      });
    });

    // -------------------------------------------------------------------------
    // GROUP 3: BITWISE AUTHORIZATION MATCHING (matchMask)
    // -------------------------------------------------------------------------
    group('3. Bitwise Authorization Matching (matchMask)', () {
      test('OR Logic (requireAll: false) grants access if ANY active role matches target', () {
        final activeMask = RoleRegistry.getMaskForRoles(['admin']);
        final targetMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);

        final isAuthorized = RoleRegistry.matchMask(
          activeMask: activeMask,
          targetMask: targetMask,
          requireAll: false,
        );

        expect(isAuthorized, isTrue);
      });

      test('OR Logic (requireAll: false) denies access if NO active role matches target', () {
        final activeMask = RoleRegistry.getMaskForRoles(['guest']);
        final targetMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);

        final isAuthorized = RoleRegistry.matchMask(
          activeMask: activeMask,
          targetMask: targetMask,
          requireAll: false,
        );

        expect(isAuthorized, isFalse);
      });

      test('AND Logic (requireAll: true) requires ALL target roles to be present in activeMask', () {
        final partialActive = RoleRegistry.getMaskForRoles(['admin']);
        final fullActive = RoleRegistry.getMaskForRoles(['admin', 'manager']);
        final targetMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);

        // Partial match -> should fail AND logic
        expect(
          RoleRegistry.matchMask(
            activeMask: partialActive,
            targetMask: targetMask,
            requireAll: true,
          ),
          isFalse,
        );

        // Full match -> should pass AND logic
        expect(
          RoleRegistry.matchMask(
            activeMask: fullActive,
            targetMask: targetMask,
            requireAll: true,
          ),
          isTrue,
        );
      });

      test('returns false when activeMask or targetMask is zero', () {
        final validMask = RoleRegistry.getMaskForRole('admin');

        expect(
          RoleRegistry.matchMask(activeMask: 0, targetMask: validMask),
          isFalse,
        );

        expect(
          RoleRegistry.matchMask(activeMask: validMask, targetMask: 0),
          isFalse,
        );

        expect(
          RoleRegistry.matchMask(activeMask: 0, targetMask: 0),
          isFalse,
        );
      });
    });

    // -------------------------------------------------------------------------
    // GROUP 4: REGISTRY STATE & RESET
    // -------------------------------------------------------------------------
    group('4. Registry Reset & State Management', () {
      test('resetRegistry clears bit mappings and resets bit indices', () {
        final maskBefore = RoleRegistry.getMaskForRole('admin');
        expect(maskBefore, equals(1));

        RoleRegistry.resetRegistry();

        // After reset, 'admin' gets freshly assigned bit index 0 (value 1)
        final maskAfter = RoleRegistry.getMaskForRole('admin');
        expect(maskAfter, equals(1));
      });
    });
  });
}
