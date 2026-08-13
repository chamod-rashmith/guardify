import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Data representation of constructor analysis for code generation.
class ConstructorAnalysisResult {
  /// Generic type parameters declaration string (e.g. `<T extends Num>`).
  final String typeParamsDecl;

  /// Generic type parameters arguments string (e.g. `<T>`).
  final String typeParamsArgs;

  /// Target constructor invocation snippet (e.g. `MyWidget<T>` or `MyWidget<T>.named`).
  final String targetConstructorInvocation;

  /// Whether the target class constructor is marked `const`.
  final String constPrefix;

  /// Parameter property name for custom runtime fallback widget (`'fallback'` or `'accessDeniedFallback'`).
  final String accessDeniedFallbackPropName;

  /// List of field declaration lines for the generated wrapper class.
  final List<String> fieldsDeclarations;

  /// List of constructor parameter lines for the generated wrapper class.
  final List<String> constructorParams;

  /// Formatted argument list string for invoking the target widget constructor.
  final String callArgsList;

  /// Whether target widget constructor already accepts a `currentRole` parameter.
  final bool hasTargetCurrentRoleParam;

  /// Whether target widget constructor already accepts a `currentRoles` parameter.
  final bool hasTargetCurrentRolesParam;

  /// Instantiates [ConstructorAnalysisResult].
  const ConstructorAnalysisResult({
    required this.typeParamsDecl,
    required this.typeParamsArgs,
    required this.targetConstructorInvocation,
    required this.constPrefix,
    required this.accessDeniedFallbackPropName,
    required this.fieldsDeclarations,
    required this.constructorParams,
    required this.callArgsList,
    required this.hasTargetCurrentRoleParam,
    required this.hasTargetCurrentRolesParam,
  });
}

/// Helper component responsible for reflecting on target widget class constructors and formal parameters.
class WidgetConstructorAnalyzer {
  const WidgetConstructorAnalyzer();

  /// Analyzes constructors and formal parameters of target [element].
  ///
  /// Inspects:
  /// - Generic type parameters and bounds.
  /// - Unnamed constructor or first public constructor fallback.
  /// - Positional and named parameters, required vs optional flags, default values.
  /// - Resolves parameter name collision on `fallback` by renaming fallback property to `accessDeniedFallback`.
  ConstructorAnalysisResult analyze(ClassElement element) {
    final className = element.name ?? '';

    // Process generic type parameters and bounds
    final typeParams = element.typeParameters;
    final typeParamsDecl = typeParams.isNotEmpty
        ? '<${typeParams.map((tp) => tp.bound != null ? '${tp.name} extends ${tp.bound!.getDisplayString()}' : tp.name).join(', ')}>'
        : '';
    final typeParamsArgs = typeParams.isNotEmpty
        ? '<${typeParams.map((tp) => tp.name).join(', ')}>'
        : '';

    // Inspect target class constructors (unnamed constructor or first public constructor fallback)
    ConstructorElement? constructor = element.unnamedConstructor;
    if (constructor == null || constructor.isPrivate) {
      final publicConstructors =
          element.constructors.where((c) => !c.isPrivate).toList();
      if (publicConstructors.isNotEmpty) {
        constructor = publicConstructors.first;
      }
    }

    if (constructor == null) {
      throw InvalidGenerationSourceError(
        'Target class `$className` must have at least one public constructor.',
        element: element,
      );
    }

    final constructorName = constructor.name;
    final isNamedConstructor = constructorName != null &&
        constructorName.isNotEmpty &&
        constructorName != 'new';

    final targetConstructorInvocation = isNamedConstructor
        ? '$className$typeParamsArgs.$constructorName'
        : '$className$typeParamsArgs';

    List<dynamic> params = [];
    try {
      params = (constructor as dynamic).parameters as List<dynamic>;
    } catch (_) {
      try {
        params = (constructor as dynamic).formalParameters as List<dynamic>;
      } catch (_) {
        params = [];
      }
    }

    final hasTargetFallbackParam = params.any((p) => p.name == 'fallback');
    final accessDeniedFallbackPropName =
        hasTargetFallbackParam ? 'accessDeniedFallback' : 'fallback';

    final hasTargetCurrentRoleParam = params.any((p) => p.name == 'currentRole');
    final hasTargetCurrentRolesParam = params.any((p) => p.name == 'currentRoles');

    final fieldsDeclarations = <String>[];
    final constructorParams = <String>[];
    final positionalCallArgs = <String>[];
    final namedCallArgs = <String>[];

    for (final param in params) {
      final paramName = param.name;
      if (paramName == null || paramName == 'key') continue;

      final paramType = param.type.getDisplayString();
      final defaultCode =
          param.defaultValueCode != null ? ' = ${param.defaultValueCode}' : '';

      if (paramName == 'currentRole' || paramName == 'currentRoles') {
        if (param.isPositional) {
          fieldsDeclarations.add('  final $paramType $paramName;');
          if (param.isRequiredPositional) {
            constructorParams.add('    required this.$paramName,');
          } else {
            constructorParams.add('    this.$paramName$defaultCode,');
          }
          positionalCallArgs.add(paramName);
        } else if (param.isNamed) {
          fieldsDeclarations.add('  final $paramType $paramName;');
          if (param.isRequiredNamed) {
            constructorParams.add('    required this.$paramName,');
          } else {
            constructorParams.add('    this.$paramName$defaultCode,');
          }
          namedCallArgs.add('$paramName: $paramName');
        }
        continue;
      }

      fieldsDeclarations.add('  final $paramType $paramName;');

      if (param.isRequiredPositional || param.isRequiredNamed) {
        constructorParams.add('    required this.$paramName,');
      } else {
        constructorParams.add('    this.$paramName$defaultCode,');
      }

      if (param.isPositional) {
        positionalCallArgs.add(paramName);
      } else if (param.isNamed) {
        namedCallArgs.add('$paramName: $paramName');
      }
    }

    final callArgsList = [
      ...positionalCallArgs,
      ...namedCallArgs,
    ].join(', ');

    final constPrefix =
        constructor.isConst && callArgsList.isEmpty ? 'const ' : '';

    return ConstructorAnalysisResult(
      typeParamsDecl: typeParamsDecl,
      typeParamsArgs: typeParamsArgs,
      targetConstructorInvocation: targetConstructorInvocation,
      constPrefix: constPrefix,
      accessDeniedFallbackPropName: accessDeniedFallbackPropName,
      fieldsDeclarations: fieldsDeclarations,
      constructorParams: constructorParams,
      callArgsList: callArgsList,
      hasTargetCurrentRoleParam: hasTargetCurrentRoleParam,
      hasTargetCurrentRolesParam: hasTargetCurrentRolesParam,
    );
  }
}
