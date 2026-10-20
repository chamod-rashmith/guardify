import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

import 'matrix_model.dart';

/// AST Visitor that discovers `@Secured` annotated classes and `RoleGate` / `SecuredFeature` widgets.
class _GatedElementVisitor extends RecursiveAstVisitor<void> {
  final String relativeFilePath;
  final LineInfo lineInfo;
  final List<GatedComponent> components = [];

  _GatedElementVisitor({
    required this.relativeFilePath,
    required this.lineInfo,
  });

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    for (final annotation in node.metadata) {
      final name = annotation.name.name;
      if (name == 'Secured') {
        _processSecuredAnnotation(node, annotation);
      }
    }
    super.visitClassDeclaration(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    if (typeName == 'RoleGate' || typeName == 'SecuredFeature') {
      _processRoleGateCreation(node, typeName);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _processSecuredAnnotation(ClassDeclaration classNode, Annotation annotation) {
    final className = classNode.namePart.typeName.lexeme;
    final lineNumber = lineInfo.getLocation(classNode.offset).lineNumber;

    final args = annotation.arguments?.arguments ?? [];
    final allowedRoles = <String>[];
    final allowedPermissions = <String>[];
    var requireAll = false;
    var fallbackType = 'hide';

    for (final arg in args) {
      if (arg is NamedArgument) {
        final argName = arg.name.lexeme;
        final expr = arg.argumentExpression;
        if (argName == 'requireAll' && expr is BooleanLiteral) {
          requireAll = expr.value;
        } else if (argName == 'fallback') {
          fallbackType = _extractFallbackType(expr);
        } else if (argName == 'allowedPermissions' && expr is ListLiteral) {
          allowedPermissions.addAll(_extractStringList(expr));
        } else if (argName == 'allowedRoles' && expr is ListLiteral) {
          allowedRoles.addAll(_extractRolesList(expr));
        }
      } else if (arg is ListLiteral) {
        allowedRoles.addAll(_extractRolesList(arg));
      }
    }

    components.add(
      GatedComponent(
        name: className,
        filePath: relativeFilePath,
        lineNumber: lineNumber,
        allowedRoles: allowedRoles,
        allowedPermissions: allowedPermissions,
        requireAll: requireAll,
        fallbackType: fallbackType,
        isCodeGen: true,
      ),
    );
  }

  void _processRoleGateCreation(InstanceCreationExpression node, String typeName) {
    final lineNumber = lineInfo.getLocation(node.offset).lineNumber;
    final args = node.argumentList.arguments;

    final allowedRoles = <String>[];
    final allowedPermissions = <String>[];
    var requireAll = false;
    var fallbackType = 'hide';
    String? childName;

    for (final arg in args) {
      if (arg is! NamedArgument) continue;
      final argName = arg.name.lexeme;
      final expr = arg.argumentExpression;

      if (argName == 'allowedRoles' && expr is ListLiteral) {
        allowedRoles.addAll(_extractRolesList(expr));
      } else if (argName == 'allowedPermissions' && expr is ListLiteral) {
        allowedPermissions.addAll(_extractStringList(expr));
      } else if (argName == 'requireAll' && expr is BooleanLiteral) {
        requireAll = expr.value;
      } else if (argName == 'fallbackType') {
        fallbackType = _extractFallbackType(expr);
      } else if (argName == 'child') {
        childName = _extractWidgetName(expr);
      }
    }

    final componentName = childName != null ? '$typeName<$childName>' : '$typeName@line$lineNumber';

    components.add(
      GatedComponent(
        name: componentName,
        filePath: relativeFilePath,
        lineNumber: lineNumber,
        allowedRoles: allowedRoles,
        allowedPermissions: allowedPermissions,
        requireAll: requireAll,
        fallbackType: fallbackType,
        isCodeGen: false,
      ),
    );
  }

  List<String> _extractRolesList(ListLiteral listLiteral) {
    final roles = <String>[];
    for (final element in listLiteral.elements) {
      if (element is SimpleStringLiteral) {
        roles.add(element.value);
      } else if (element is PrefixedIdentifier) {
        roles.add(element.identifier.name);
      } else if (element is PropertyAccess) {
        roles.add(element.propertyName.name);
      }
    }
    return roles;
  }

  List<String> _extractStringList(ListLiteral listLiteral) {
    final list = <String>[];
    for (final element in listLiteral.elements) {
      if (element is SimpleStringLiteral) {
        list.add(element.value);
      }
    }
    return list;
  }

  String _extractFallbackType(Expression expr) {
    if (expr is PrefixedIdentifier) {
      return expr.identifier.name;
    } else if (expr is PropertyAccess) {
      return expr.propertyName.name;
    }
    final text = expr.toSource();
    if (text.contains('disabled')) return 'disabled';
    if (text.contains('scaffold')) return 'scaffold';
    if (text.contains('text')) return 'text';
    return 'hide';
  }

  String? _extractWidgetName(Expression expr) {
    if (expr is InstanceCreationExpression) {
      return expr.constructorName.type.name.lexeme;
    }
    if (expr is MethodInvocation) {
      return expr.methodName.name;
    }
    return null;
  }
}

/// Discovers and analyzes role-gated components in a directory or file.
class CodeScanner {
  const CodeScanner();

  /// Scans [targetPath] (directory or file) and produces an [AccessMatrixReport].
  Future<AccessMatrixReport> scanPath(String targetPath, {String? rootPath}) async {
    final root = rootPath ?? Directory.current.path;
    final target = Directory(p.isAbsolute(targetPath) ? targetPath : p.join(root, targetPath));

    final components = <GatedComponent>[];
    final allRoles = <String>{};
    final allPermissions = <String>{};

    if (await target.exists()) {
      await for (final entity in target.list(recursive: true, followLinks: false)) {
        if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('.g.dart')) {
          final fileComponents = await scanFile(entity.path, rootPath: root);
          for (final comp in fileComponents) {
            components.add(comp);
            allRoles.addAll(comp.allowedRoles);
            allPermissions.addAll(comp.allowedPermissions);
          }
        }
      }
    } else {
      final file = File(p.isAbsolute(targetPath) ? targetPath : p.join(root, targetPath));
      if (await file.exists() && file.path.endsWith('.dart')) {
        final fileComponents = await scanFile(file.path, rootPath: root);
        for (final comp in fileComponents) {
          components.add(comp);
          allRoles.addAll(comp.allowedRoles);
          allPermissions.addAll(comp.allowedPermissions);
        }
      }
    }

    return AccessMatrixReport(
      components: components,
      allRoles: allRoles,
      allPermissions: allPermissions,
    );
  }

  /// Scans a single Dart file and extracts all gated components.
  Future<List<GatedComponent>> scanFile(String filePath, {String? rootPath}) async {
    final root = rootPath ?? Directory.current.path;
    final file = File(filePath);
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final relativePath = p.relative(file.path, from: root).replaceAll('\\', '/');

    try {
      final parseResult = parseString(
        content: content,
        path: filePath,
        throwIfDiagnostics: false,
      );

      final visitor = _GatedElementVisitor(
        relativeFilePath: relativePath,
        lineInfo: parseResult.lineInfo,
      );

      parseResult.unit.accept(visitor);
      return visitor.components;
    } catch (_) {
      return [];
    }
  }
}
