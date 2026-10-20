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
    final formattedPermissions =
        annotationData.allowedPermissions.map((perm) => "'$perm'").join(', ');

    final targetInvocation =
        '${ctorResult.constPrefix}${ctorResult.targetConstructorInvocation}(${ctorResult.callArgsList})';

    final fallbackWidgetCode = switch (annotationData.fallbackStrategy) {
      'disabled' => '''AbsorbPointer(
        absorbing: true,
        child: Opacity(
          opacity: ${annotationData.disabledOpacity},
          child: $targetInvocation,
        ),
      )''',
      'scaffold' => '''Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Text(
            'Access Denied: Restricted Area!',
            style: TextStyle(
              color: Color(0xFFD32F2F),
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
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
          ),
        ),
      )''',
      _ => 'const SizedBox.shrink()',
    };

    final fieldsBlock = ctorResult.fieldsDeclarations.isNotEmpty
        ? '\n${ctorResult.fieldsDeclarations.join('\n')}\n'
        : '';

    final currentRoleFieldDecl = ctorResult.hasTargetCurrentRoleParam
        ? ''
        : '  final String? currentRole;\n';
    final currentRolesFieldDecl = ctorResult.hasTargetCurrentRolesParam
        ? ''
        : '  final Iterable<String>? currentRoles;\n';
    final currentPermissionFieldDecl = ctorResult.hasTargetCurrentPermissionParam
        ? ''
        : '  final String? currentPermission;\n';
    final currentPermissionsFieldDecl = ctorResult.hasTargetCurrentPermissionsParam
        ? ''
        : '  final Iterable<String>? currentPermissions;\n';
    final fallbackFieldDecl =
        '  final Widget? ${ctorResult.accessDeniedFallbackPropName};\n';
    final fallbackBuilderFieldDecl =
        '  final GuardifyFallbackBuilder? ${ctorResult.accessDeniedFallbackBuilderPropName};\n';

    final currentRoleCtorParam = ctorResult.hasTargetCurrentRoleParam
        ? ''
        : '    this.currentRole,\n';
    final currentRolesCtorParam = ctorResult.hasTargetCurrentRolesParam
        ? ''
        : '    this.currentRoles,\n';
    final currentPermissionCtorParam = ctorResult.hasTargetCurrentPermissionParam
        ? ''
        : '    this.currentPermission,\n';
    final currentPermissionsCtorParam = ctorResult.hasTargetCurrentPermissionsParam
        ? ''
        : '    this.currentPermissions,\n';
    final fallbackCtorParam =
        '    this.${ctorResult.accessDeniedFallbackPropName},\n';
    final fallbackBuilderCtorParam =
        '    this.${ctorResult.accessDeniedFallbackBuilderPropName},\n';

    final authCheckLogic = annotationData.requireAll
        ? '''final rolesOk = !hasRoles || guardifyAllowedRoles.every(guardifyActiveRoles.contains);
      final permsOk = !hasPerms || guardifyAllowedPermissions.every(guardifyActivePermissions.contains);
      guardifyIsAuthorized = rolesOk && permsOk;'''
        : '''final roleMatch = hasRoles && guardifyAllowedRoles.any(guardifyActiveRoles.contains);
      final permMatch = hasPerms && guardifyAllowedPermissions.any(guardifyActivePermissions.contains);
      guardifyIsAuthorized = roleMatch || permMatch;''';

    final generatedCode = '''
class ${annotationData.generatedClassName}${ctorResult.typeParamsDecl} extends StatelessWidget {
$currentRoleFieldDecl$currentRolesFieldDecl$currentPermissionFieldDecl$currentPermissionsFieldDecl$fallbackFieldDecl$fallbackBuilderFieldDecl$fieldsBlock
  const ${annotationData.generatedClassName}({
    super.key,
$currentRoleCtorParam$currentRolesCtorParam$currentPermissionCtorParam$currentPermissionsCtorParam$fallbackCtorParam$fallbackBuilderCtorParam${ctorResult.constructorParams.join('\n')}
  });

  @override
  Widget build(BuildContext context) {
    // 1. Obtain ambient GuardifyScope from BuildContext (if present)
    final guardifyScope = GuardifyScope.of(context);

    // 2. Define allowed roles and permissions configured via [@Secured] annotation
    const guardifyAllowedRoles = <String>[$formattedRoles];
    const guardifyAllowedPermissions = <String>[$formattedPermissions];

    // 3. Aggregate and normalize active roles and permissions
    final guardifyActiveRoles = GuardifyScope.collectRoles(
      currentRole: currentRole,
      currentRoles: currentRoles,
      scope: guardifyScope,
    );

    final guardifyActivePermissions = GuardifyScope.collectPermissions(
      currentPermission: currentPermission,
      currentPermissions: currentPermissions,
      scope: guardifyScope,
    );

    // 4. Evaluate authorization state using custom permissionChecker or set matching
    final bool guardifyIsAuthorized;
    if (guardifyScope?.permissionChecker != null) {
      guardifyIsAuthorized = guardifyScope!.permissionChecker!(
        guardifyAllowedRoles,
        requireAll: ${annotationData.requireAll},
        activeRoles: guardifyActiveRoles,
        allowedPermissions: guardifyAllowedPermissions,
        activePermissions: guardifyActivePermissions,
      );
    } else {
      final hasRoles = guardifyAllowedRoles.isNotEmpty;
      final hasPerms = guardifyAllowedPermissions.isNotEmpty;

      if (!hasRoles && !hasPerms) {
        guardifyIsAuthorized = false;
      } else {
        $authCheckLogic
      }
    }

    // 5. Render target component if authorized
    if (guardifyIsAuthorized) {
      return $targetInvocation;
    }

    // 6. Return local fallback if provided
    if (${ctorResult.accessDeniedFallbackPropName} != null) {
      return ${ctorResult.accessDeniedFallbackPropName}!;
    }

    // 7. Check local fallbackBuilder or ambient GuardifyScope fallbackBuilder
    final guardifyFallbackBuilder =
        ${ctorResult.accessDeniedFallbackBuilderPropName} ?? guardifyScope?.fallbackBuilder;
    if (guardifyFallbackBuilder != null) {
      final missingRoles = guardifyAllowedRoles.where((r) => !guardifyActiveRoles.contains(r)).toList();
      final missingPerms = guardifyAllowedPermissions.where((p) => !guardifyActivePermissions.contains(p)).toList();
      return guardifyFallbackBuilder(context, missingRoles, missingPerms);
    }

    // 8. Default fallback strategy
    return $fallbackWidgetCode;
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
