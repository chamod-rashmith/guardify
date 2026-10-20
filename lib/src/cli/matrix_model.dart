/// Represents the access evaluation status for a specific role against a component.
enum AccessStatus {
  /// User possesses authorization to view and interact with the component.
  granted,

  /// Access is denied; component is hidden or replaced with error UI.
  denied,

  /// Component is visible but disabled with blocked interactions (e.g. AbsorbPointer).
  disabled,
}

/// Model representing a role-gated or permission-gated component found in the codebase.
class GatedComponent {
  /// The target widget or component identifier.
  final String name;

  /// Relative file path where the component is declared or used.
  final String filePath;

  /// Line number in the source file.
  final int lineNumber;

  /// List of authorized roles.
  final List<String> allowedRoles;

  /// List of authorized permissions.
  final List<String> allowedPermissions;

  /// Whether all roles/permissions must be present.
  final bool requireAll;

  /// The fallback UI strategy (`'hide'`, `'disabled'`, `'scaffold'`, `'text'`).
  final String fallbackType;

  /// Whether this was declared via `@Secured` code-gen (`true`) or runtime `RoleGate` (`false`).
  final bool isCodeGen;

  /// Instantiates a [GatedComponent].
  const GatedComponent({
    required this.name,
    required this.filePath,
    required this.lineNumber,
    required this.allowedRoles,
    this.allowedPermissions = const [],
    this.requireAll = false,
    this.fallbackType = 'hide',
    this.isCodeGen = true,
  });

  /// Evaluates the access status for a single [role].
  AccessStatus evaluateRole(String role) {
    if (allowedRoles.isEmpty && allowedPermissions.isNotEmpty) {
      return AccessStatus.denied;
    }

    final hasRole = allowedRoles.contains(role) ||
        allowedRoles.any((r) => r.endsWith('.$role') || role.endsWith('.$r'));

    if (hasRole) {
      return AccessStatus.granted;
    }

    if (fallbackType == 'disabled') {
      return AccessStatus.disabled;
    }

    return AccessStatus.denied;
  }

  /// Converts this component entry to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'filePath': filePath,
        'lineNumber': lineNumber,
        'allowedRoles': allowedRoles,
        'allowedPermissions': allowedPermissions,
        'requireAll': requireAll,
        'fallbackType': fallbackType,
        'type': isCodeGen ? '@Secured' : 'RoleGate',
      };
}

/// Complete report containing all discovered gated components and global role matrix.
class AccessMatrixReport {
  /// List of all discovered gated components.
  final List<GatedComponent> components;

  /// Set of all unique roles identified across all components.
  final Set<String> allRoles;

  /// Set of all unique permissions identified across all components.
  final Set<String> allPermissions;

  /// Timestamp when the audit scan was completed.
  final DateTime generatedAt;

  /// Instantiates [AccessMatrixReport].
  AccessMatrixReport({
    required this.components,
    required this.allRoles,
    required this.allPermissions,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  /// Converts this report into a structured JSON representation.
  Map<String, dynamic> toJson() => {
        'generatedAt': generatedAt.toIso8601String(),
        'totalComponents': components.length,
        'roles': allRoles.toList()..sort(),
        'permissions': allPermissions.toList()..sort(),
        'components': components.map((c) => c.toJson()).toList(),
        'matrix': {
          for (final comp in components)
            comp.name: {
              for (final role in (allRoles.toList()..sort()))
                role: comp.evaluateRole(role).name,
            },
        },
      };
}
