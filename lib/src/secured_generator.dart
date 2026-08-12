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

    // ignore: experimental_member_use
    final isWidget = element.name == 'Widget' ||
        // ignore: experimental_member_use
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

    // Read allowedRoles list (supporting String literals, Enum values, and qualified Enum names)
    final allowedRolesReader = annotation.read('allowedRoles');
    final allowedRolesSet = <String>{};

    for (final object in allowedRolesReader.listValue) {
      final str = object.toStringValue();
      if (str != null) {
        allowedRolesSet.add(str);
      } else {
        final enumFieldName = object.getField('name')?.toStringValue() ??
            object.getField('_name')?.toStringValue();
        // ignore: experimental_member_use
        final enumTypeName = object.type?.element?.name;
        if (enumFieldName != null) {
          allowedRolesSet.add(enumFieldName);
          if (enumTypeName != null && enumTypeName.isNotEmpty) {
            allowedRolesSet.add('$enumTypeName.$enumFieldName');
          }
        }
      }
    }

    final allowedRoles = allowedRolesSet.toList();

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

    final constPrefix =
        constructor.isConst && callArgsList.isEmpty ? 'const ' : '';

    final currentRoleFieldDecl = params.any((p) => p.name == 'currentRole')
        ? ''
        : '  final String? currentRole;\n';
    final currentRolesFieldDecl = params.any((p) => p.name == 'currentRoles')
        ? ''
        : '  final Iterable<String>? currentRoles;\n';
    final fallbackFieldDecl =
        '  final Widget? $accessDeniedFallbackPropName;\n';

    final currentRoleCtorParam = params.any((p) => p.name == 'currentRole')
        ? ''
        : '    this.currentRole,\n';
    final currentRolesCtorParam = params.any((p) => p.name == 'currentRoles')
        ? ''
        : '    this.currentRoles,\n';
    final fallbackCtorParam =
        '    this.$accessDeniedFallbackPropName,\n';

    final generatedCode = '''
class $generatedClassName$typeParamsDecl extends StatelessWidget {
$currentRoleFieldDecl$currentRolesFieldDecl$fallbackFieldDecl$fieldsBlock
  const $generatedClassName({
    super.key,
$currentRoleCtorParam$currentRolesCtorParam$fallbackCtorParam${constructorParams.join('\n')}
  });

  @override
  Widget build(BuildContext context) {
    const allowedRoles = <String>[$formattedRoles];
    final scope = GuardifyScope.of(context);

    final directRole = currentRole;
    final directRoles = currentRoles;
    final scopeRole = scope?.currentRole;
    final scopeRoles = scope?.currentRoles;

    final activeRoles = <String>{};
    if (directRole != null) activeRoles.add(directRole);
    if (directRoles != null) activeRoles.addAll(directRoles);
    if (scopeRole != null) activeRoles.add(scopeRole);
    if (scopeRoles != null) activeRoles.addAll(scopeRoles);

    final bool isAuthorized;
    if (scope?.permissionChecker != null) {
      isAuthorized = scope!.permissionChecker!(
        allowedRoles,
        requireAll: $requireAll,
        activeRoles: activeRoles,
      );
    } else {
      isAuthorized = $roleCheckCondition;
    }

    if (isAuthorized) {
      return $constPrefix$targetConstructorInvocation($callArgsList);
    }

    if ($accessDeniedFallbackPropName != null) {
      return $accessDeniedFallbackPropName!;
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

