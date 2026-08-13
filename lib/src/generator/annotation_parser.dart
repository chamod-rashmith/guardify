import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Data class holding parsed metadata extracted from a [@Secured] annotation on a Flutter widget element.
class SecuredAnnotationData {
  /// The target Flutter widget class name (e.g. `DeleteUserButton`).
  final String className;

  /// The generated role-gated wrapper class name (e.g. `SecuredDeleteUserButton` or custom name).
  final String generatedClassName;

  /// List of string role identifiers authorized to access the widget.
  final List<String> allowedRoles;

  /// Whether all allowed roles are required (`true`) or any single role matches (`false`).
  final bool requireAll;

  /// Fallback UI strategy identifier (`'hide'`, `'scaffold'`, or `'text'`).
  final String fallbackStrategy;

  /// Instantiates [SecuredAnnotationData] with validated parameters.
  const SecuredAnnotationData({
    required this.className,
    required this.generatedClassName,
    required this.allowedRoles,
    required this.requireAll,
    required this.fallbackStrategy,
  });
}

/// Helper component responsible for reading and validating [@Secured] annotation elements.
///
/// Uses Dart analyzer APIs ([Element], [ConstantReader]) to reflect upon target widget classes,
/// validate structural preconditions, and extract annotation parameters.
class SecuredAnnotationParser {
  const SecuredAnnotationParser();

  /// Parses and validates the target [element] annotated with [@Secured].
  ///
  /// Throws [InvalidGenerationSourceError] if:
  /// - The annotated element is not a [ClassElement].
  /// - The class does not extend/subclass Flutter `Widget`.
  /// - The class name is empty or invalid.
  /// - `allowedRoles` is empty or invalid.
  SecuredAnnotationData parse(Element element, ConstantReader annotation) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Secured annotation can only be applied to Flutter Widget classes.',
        element: element,
      );
    }

    // Validate that target class is a Flutter Widget subclass
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

    // Extract custom name if specified, or default to `Secured<ClassName>`
    final customName = annotation.peek('name')?.stringValue;
    final generatedClassName = customName ?? 'Secured$className';

    // Extract allowedRoles list (supporting String literals, Enum values, and qualified Enum names)
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

    // Read requireAll boolean flag
    final requireAll = annotation.peek('requireAll')?.boolValue ?? false;

    // Read fallback strategy enum value
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

    return SecuredAnnotationData(
      className: className,
      generatedClassName: generatedClassName,
      allowedRoles: allowedRoles,
      requireAll: requireAll,
      fallbackStrategy: fallbackStrategy,
    );
  }
}
