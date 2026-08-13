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

    final targetInvocation =
        '${ctorResult.constPrefix}${ctorResult.targetConstructorInvocation}(${ctorResult.callArgsList})';

    final fallbackWidgetCode = switch (annotationData.fallbackStrategy) {
      'scaffold' => '''Scaffold(
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
      )''',
      'text' => '''const Center(
        child: Text(
          'Access Denied: Restricted Area!',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      )''',
      'disabled' => '''LockOverlay(
        child: $targetInvocation,
      )''',
      _ => 'const SizedBox.shrink()',
    };

    final roleCheckCondition = annotationData.requireAll
        ? 'allowedRoles.isNotEmpty && allowedRoles.every(activeRoles.contains)'
        : 'allowedRoles.isNotEmpty && allowedRoles.any(activeRoles.contains)';

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
    // 1. Define allowed roles configured via [@Secured] annotation
    const allowedRoles = <String>[$formattedRoles];

    // 2. Obtain ambient GuardifyScope from BuildContext (if present)
    final scope = GuardifyScope.of(context);

    // 3. Collect active roles set for custom permissionChecker or missing roles fallbacks
    final activeRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: scope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or fast O(1) bitwise matching
    final isAuthorized = (scope?.permissionChecker != null)
        ? scope!.permissionChecker!(
            allowedRoles,
            requireAll: ${annotationData.requireAll},
            activeRoles: activeRoles,
          )
        : RoleRegistry.matchMask(
            activeMask: RoleRegistry.getMaskForRoles(activeRoles),
            targetMask: RoleRegistry.getMaskForRoles(allowedRoles),
            requireAll: ${annotationData.requireAll},
          );

    // 5. Render target component or fallback widget using Dart 3 pattern matching switch expression
    return switch ((
      isAuthorized,
      ${ctorResult.accessDeniedFallbackPropName},
      scope?.fallbackBuilder,
    )) {
      (true, _, _) => $targetInvocation,
      (false, final fallback?, _) => fallback,
      (false, _, final builder?) => builder(
          context,
          allowedRoles.where((r) => !activeRoles.contains(r)).toList(),
          const <String>[],
        ),
      _ => $fallbackWidgetCode,
    };
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
