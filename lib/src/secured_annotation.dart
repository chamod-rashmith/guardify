/// Strategy for fallback UI when access is denied.
enum FallbackType {
  /// Hide the widget completely (renders [SizedBox.shrink()]). Ideal for buttons, cards, inline UI.
  hide,

  /// Show a full page "Access Denied" Scaffold. Ideal for full screen pages.
  scaffold,

  /// Show an inline "Access Denied" text widget.
  text,
}

/// Annotation used to secure Flutter widgets with Role-Based Access Control (RBAC).
class Secured {
  /// The list of role strings or enum values authorized to view/access the annotated widget.
  final List<dynamic> allowedRoles;

  /// Optional custom name for the generated secured widget class. Defaults to `Secured<ClassName>`.
  final String? name;

  /// The fallback UI strategy to use when access is denied. Defaults to [FallbackType.hide].
  final FallbackType fallback;

  /// Whether all roles in [allowedRoles] are required (true) or any single role matches (false). Defaults to false.
  final bool requireAll;

  /// Creates a new [Secured] annotation.
  const Secured(
    this.allowedRoles, {
    this.name,
    this.fallback = FallbackType.hide,
    this.requireAll = false,
  });
}
