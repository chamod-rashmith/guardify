import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator/annotation_parser.dart';
import 'generator/code_composer.dart';
import 'generator/constructor_analyzer.dart';
import 'runtime/secured_annotation.dart';

/// Code generator that creates role-gated UI widget wrappers for classes annotated with [@Secured].
///
/// Under the hood, this generator orchestrates a modular pipeline:
/// 1. [SecuredAnnotationParser]: Extracts and validates annotation properties ([SecuredAnnotationData]).
/// 2. [WidgetConstructorAnalyzer]: Inspects target class constructors, formal parameters, generic parameters, and resolves collisions ([ConstructorAnalysisResult]).
/// 3. [SecuredCodeComposer]: Composes formatted Dart code strings for the wrapper `StatelessWidget`.
class SecuredGenerator extends GeneratorForAnnotation<Secured> {
  final SecuredAnnotationParser parser;
  final WidgetConstructorAnalyzer analyzer;
  final SecuredCodeComposer composer;

  /// Creates a new [SecuredGenerator] with configurable pipeline components.
  const SecuredGenerator({
    this.parser = const SecuredAnnotationParser(),
    this.analyzer = const WidgetConstructorAnalyzer(),
    this.composer = const SecuredCodeComposer(),
  });

  /// Generator entry point invoked by `source_gen` / `build_runner` for elements annotated with [@Secured].
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Step 1: Parse and validate annotation metadata
    final annotationData = parser.parse(element, annotation);

    // Step 2: Analyze class constructors and formal parameters
    final ctorResult = analyzer.analyze(element as ClassElement);

    // Step 3: Compose formatted Dart source code
    return composer.compose(annotationData, ctorResult);
  }
}
