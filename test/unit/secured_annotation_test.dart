import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('1. Secured Annotation Unit Tests', () {
    test('Secured annotation holds default values', () {
      const secured = Secured(['admin']);
      expect(secured.allowedRoles, contains('admin'));
      expect(secured.allowedPermissions, isEmpty);
      expect(secured.fallback, equals(FallbackType.hide));
      expect(secured.requireAll, isFalse);
      expect(secured.disabledOpacity, equals(0.5));
      expect(secured.name, isNull);
    });

    test('Secured annotation holds custom values', () {
      const secured = Secured(
        ['manager', 'finance'],
        allowedPermissions: ['reports:export'],
        fallback: FallbackType.disabled,
        disabledOpacity: 0.3,
        requireAll: true,
        name: 'CustomSecuredCard',
      );
      expect(secured.allowedRoles, containsAll(['manager', 'finance']));
      expect(secured.allowedPermissions, contains('reports:export'));
      expect(secured.fallback, equals(FallbackType.disabled));
      expect(secured.disabledOpacity, equals(0.3));
      expect(secured.requireAll, isTrue);
      expect(secured.name, equals('CustomSecuredCard'));
    });
  });
}
