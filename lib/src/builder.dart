import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'secured_generator.dart';

/// Builder factory for Guardify code generation.
Builder guardifyBuilder(BuilderOptions options) {
  return PartBuilder(
    [SecuredGenerator()],
    '.secured.g.dart',
  );
}
