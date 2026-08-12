import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'secured_annotation.dart';

/// Code generator that creates role-gated UI widget wrappers for classes annotated with [@Secured].
class SecuredGenerator extends GeneratorForAnnotation<Secured> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Secured annotation can only be applied to Flutter Widget classes.',
        element: element,
      );
    }

    final isWidget = element.name == 'Widget' ||
        element.allSupertypes.any((t) => t.element.name == 'Widget');
    if (!isWidget) {
      throw InvalidGenerationSourceError(
        '@Secured annotation can only be applied to Flutter Widget classes.',
        element: element,
      );
    }

    final className = element.name;
    if (className == null || className.isEmpty) {
      throw InvalidGenerationSourceError(
        'Target class must have a valid non-empty name.',
        element: element,
      );
    }

    // Read custom name if provided, or default to Secured<ClassName>
    final customName = annotation.peek('name')?.stringValue;
    final generatedClassName = customName ?? 'Secured$className';

    // Read allowedRoles list (supporting String literals and Enum objects)
    final allowedRolesReader = annotation.read('allowedRoles');
    final allowedRoles = allowedRolesReader.listValue.map((object) {
      final str = object.toStringValue();
      if (str != null) return str;

      final enumFieldName = object.getField('name')?.toStringValue() ??
          object.getField('_name')?.toStringValue();
      if (enumFieldName != null) return enumFieldName;

      return null;
    }).whereType<String>().toList();

    if (allowedRoles.isEmpty) {
      throw InvalidGenerationSourceError(
        '@Secured annotation requires at least one allowed role in `allowedRoles`.',
        element: element,
      );
    }

    final formattedRoles = allowedRoles.map((role) => "'$role'").join(', ');

    // Read requireAll bool
    final requireAll = annotation.peek('requireAll')?.boolValue ?? false;

    // Read fallback enum
    final fallbackReader = annotation.peek('fallback');
    String fallbackStrategy = 'hide';
    if (fallbackReader != null && !fallbackReader.isNull) {
      final enumObj = fallbackReader.objectValue;
      final name = enumObj.getField('_name')?.toStringValue() ??
          enumObj.getField('name')?.toStringValue();
      if (name != null) {
        fallbackStrategy = name;
      }
    }

    // Process generic type parameters
    final typeParams = element.typeParameters;
    final typeParamsDecl = typeParams.isNotEmpty
        ? '<${typeParams.map((tp) => tp.bound != null ? '${tp.name} extends ${tp.bound!.getDisplayString()}' : tp.name).join(', ')}>'
        : '';
    final typeParamsArgs = typeParams.isNotEmpty
        ? '<${typeParams.map((tp) => tp.name).join(', ')}>'
        : '';

    // Inspect target class constructor parameters
    final constructor = element.unnamedConstructor;
    final fieldsDeclarations = <String>[];
    final constructorParams = <String>[];
    final positionalCallArgs = <String>[];
    final namedCallArgs = <String>[];

    if (constructor != null) {
      final params = constructor.formalParameters;
      for (final param in params) {
        final paramName = param.name;
        // Skip null or 'key' parameter as super handles key
        if (paramName == null || paramName == 'key') continue;

        final paramType = param.type.getDisplayString();

        fieldsDeclarations.add('  final $paramType $paramName;');

        final defaultCode = param.defaultValueCode != null
            ? ' = ${param.defaultValueCode}'
            : '';

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
    }

    final callArgsList = [
      ...positionalCallArgs,
      ...namedCallArgs,
    ].join(', ');

    final fieldsBlock = fieldsDeclarations.isNotEmpty
        ? '\n${fieldsDeclarations.join('\n')}\n'
        : '';

    final fallbackWidgetCode = switch (fallbackStrategy) {
      'scaffold' => '''
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: const Center(
        child: Text(
          'Access Denied: Restricted Area!',
          style: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );''',
      'text' => '''
    return const Center(
      child: Text(
        'Access Denied: Restricted Area!',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );''',
      _ => '    return const SizedBox.shrink();',
    };

    final roleCheckCondition = requireAll
        ? 'allowedRoles.every((r) => activeRoles.contains(r))'
        : 'allowedRoles.any((r) => activeRoles.contains(r))';

    final generatedCode = '''
class $generatedClassName$typeParamsDecl extends StatelessWidget {
  final String? currentRole;
  final Iterable<String>? currentRoles;
  final Widget? fallback;
$fieldsBlock
  const $generatedClassName({
    super.key,
    this.currentRole,
    this.currentRoles,
    this.fallback,
${constructorParams.join('\n')}
  });

  @override
  Widget build(BuildContext context) {
    const allowedRoles = <String>[$formattedRoles];
    final scope = GuardifyScope.of(context);

    final activeRoles = <String>{
      if (currentRole != null) currentRole!,
      if (currentRoles != null) ...currentRoles!,
      if (scope != null && scope.currentRole != null) scope.currentRole!,
      if (scope != null && scope.currentRoles != null) ...scope.currentRoles!,
    };

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(allowedRoles, requireAll: $requireAll);
    } else {
      isAuthorized = $roleCheckCondition;
    }

    if (isAuthorized) {
      return $className$typeParamsArgs($callArgsList);
    }

    if (fallback != null) {
      return fallback!;
    }

$fallbackWidgetCode
  }
}
''';

    try {
      return DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
          .format(generatedCode);
    } catch (_) {
      return generatedCode;
    }
  }
}
