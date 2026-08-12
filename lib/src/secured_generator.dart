import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
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
        '@Secured annotation can only be applied to classes.',
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

    // Read allowedRoles list
    final allowedRolesReader = annotation.read('allowedRoles');
    final allowedRoles = allowedRolesReader.listValue
        .map((object) => object.toStringValue())
        .whereType<String>()
        .toList();

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

    return '''
class $generatedClassName extends StatelessWidget {
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
      return $className($callArgsList);
    }

    if (fallback != null) {
      return fallback!;
    }

$fallbackWidgetCode
  }
}
''';
  }
}
