import 'package:dart_style/dart_style.dart';

import 'annotation_parser.dart';
import 'constructor_analyzer.dart';

/// Helper component responsible for generating formatted Dart code strings for secured wrapper widgets.
class SecuredCodeComposer {
  const SecuredCodeComposer();

  /// Composes and formats Dart source code for the role-gated wrapper widget.
  ///
  /// Combines metadata from [annotationData] and constructor metadata from [ctorResult].
  String compose(
    SecuredAnnotationData annotationData,
    ConstructorAnalysisResult ctorResult,
  ) {
    final formattedRoles =
        annotationData.allowedRoles.map((role) => "'$role'").join(', ');

    final fallbackWidgetCode = switch (annotationData.fallbackStrategy) {
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

    final roleCheckCondition = annotationData.requireAll
        ? 'allowedRoles.every((r) => activeRoles.contains(r))'
        : 'allowedRoles.any((r) => activeRoles.contains(r))';

    final fieldsBlock = ctorResult.fieldsDeclarations.isNotEmpty
        ? '\n${ctorResult.fieldsDeclarations.join('\n')}\n'
        : '';

    final currentRoleFieldDecl = ctorResult.hasTargetCurrentRoleParam
        ? ''
        : '  final String? currentRole;\n';
    final currentRolesFieldDecl = ctorResult.hasTargetCurrentRolesParam
        ? ''
        : '  final Iterable<String>? currentRoles;\n';
    final fallbackFieldDecl =
        '  final Widget? ${ctorResult.accessDeniedFallbackPropName};\n';

    final currentRoleCtorParam = ctorResult.hasTargetCurrentRoleParam
        ? ''
        : '    this.currentRole,\n';
    final currentRolesCtorParam = ctorResult.hasTargetCurrentRolesParam
        ? ''
        : '    this.currentRoles,\n';
    final fallbackCtorParam =
        '    this.${ctorResult.accessDeniedFallbackPropName},\n';

    final generatedCode = '''
class ${annotationData.generatedClassName}${ctorResult.typeParamsDecl} extends StatelessWidget {
$currentRoleFieldDecl$currentRolesFieldDecl$fallbackFieldDecl$fieldsBlock
  const ${annotationData.generatedClassName}({
    super.key,
$currentRoleCtorParam$currentRolesCtorParam$fallbackCtorParam${ctorResult.constructorParams.join('\n')}
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
        requireAll: ${annotationData.requireAll},
        activeRoles: activeRoles,
      );
    } else {
      isAuthorized = $roleCheckCondition;
    }

    if (isAuthorized) {
      return ${ctorResult.constPrefix}${ctorResult.targetConstructorInvocation}(${ctorResult.callArgsList});
    }

    if (${ctorResult.accessDeniedFallbackPropName} != null) {
      return ${ctorResult.accessDeniedFallbackPropName}!;
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
