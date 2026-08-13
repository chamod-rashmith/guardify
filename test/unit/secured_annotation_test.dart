import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/guardify.dart';

void main() {
  group('1. Secured Annotation Unit Tests', () {
    test('Secured annotation holds default values', () {
      const secured = Secured(['admin']);
      expect(secured.allowedRoles, contains('admin'));
      expect(secured.fallback, equals(FallbackType.hide));
      expect(secured.requireAll, isFalse);
      expect(secured.name, isNull);
    });

    test('Secured annotation holds custom values', () {
      const secured = Secured(
        ['manager', 'finance'],
        fallback: FallbackType.scaffold,
        requireAll: true,
        name: 'CustomSecuredCard',
      );
      expect(secured.allowedRoles, containsAll(['manager', 'finance']));
      expect(secured.fallback, equals(FallbackType.scaffold));
      expect(secured.requireAll, isTrue);
      expect(secured.name, equals('CustomSecuredCard'));
    });
  });
}
