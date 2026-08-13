import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'secured_generator.dart';

/// Primary builder factory for Guardify code generation.
///
/// Registered in `build.yaml` to process `.dart` files containing [@Secured] annotations
/// and output generated `.secured.g.dart` part files.
Builder guardifyBuilder(BuilderOptions options) {
  return PartBuilder(
    [const SecuredGenerator()],
    '.secured.g.dart',
  );
}
