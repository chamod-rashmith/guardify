/// Strategy for fallback UI when access is denied to a role-gated widget.
///
/// When a user attempts to access a [@Secured] widget without possessing the
/// required role(s), the generated wrapper widget uses this enum strategy to
/// determine what UI to display instead.
enum FallbackType {
  /// Completely hides the widget from the UI hierarchy.
  ///
  /// Renders a [SizedBox.shrink()], occupying zero spatial dimensions (0x0 pixels).
  /// This is the default strategy and is ideal for inline UI elements such as
  /// action buttons, cards, list items, or menu options.
  hide,

  /// Displays a full-screen "Access Denied" page wrapped in a [Scaffold].
  ///
  /// Includes a pre-styled [AppBar] and a central warning message in red text.
  /// This strategy is designed for top-level pages or full-screen routes where
  /// hiding the body would leave an empty blank scaffold.
  scaffold,

  /// Renders an inline "Access Denied: Restricted Area!" text message.
  ///
  /// Displays a bold red centered [Text] widget within the layout container.
  /// Useful when a visual placeholder is desired in place of restricted content
  /// without unmounting the parent layout structure.
  text,

  /// Disables user interaction with the child widget while maintaining its layout presence.
  ///
  /// Wraps the child in an [AbsorbPointer] and reduces visual opacity, optionally
  /// displaying a lock overlay badge over the widget. Ideal for disabled buttons,
  /// locked card features, or premium action controls.
  disabled,
}

/// Annotation used to secure Flutter widgets with Role-Based Access Control (RBAC).
///
/// Annotating any Flutter [Widget] class with [@Secured] instructs the `guardify`
/// build runner builder to automatically generate a role-gated wrapper class
/// named `Secured<ClassName>` (or a custom name specified via [name]).
///
/// ### Example Usage:
/// ```dart
/// @Secured(['admin', 'superadmin'], fallback: FallbackType.hide)
/// class DeleteUserButton extends StatelessWidget {
///   final String userId;
///   const DeleteUserButton({super.key, required this.userId});
///
///   @override
///   Widget build(BuildContext context) => ElevatedButton(...);
/// }
/// ```
///
/// At build time, `SecuredDeleteUserButton` will be generated in `.secured.g.dart`.
class Secured {
  /// The collection of role strings or enum values authorized to view/access the widget.
  ///
  /// Elements in this list can be:
  /// - String literals (e.g. `'admin'`, `'manager'`)
  /// - Enum values (e.g. `UserRole.admin`)
  /// - Qualified enum identifier strings (e.g. `'UserRole.admin'`)
  final List<dynamic> allowedRoles;

  /// Optional custom class name for the generated wrapper widget.
  ///
  /// If `null` (default), the generator defaults to `Secured<TargetClassName>`.
  /// For example, `@Secured(['admin'], name: 'AdminGate')` generates `class AdminGate`.
  final String? name;

  /// The default fallback UI strategy used when authorization fails.
  ///
  /// Defaults to [FallbackType.hide] (renders [SizedBox.shrink()]).
  /// Can be overridden at runtime on individual generated widget instances via their
  /// `fallback` (or `accessDeniedFallback`) constructor property.
  final FallbackType fallback;

  /// Controls the logical authorization evaluation strategy.
  ///
  /// - If `false` (default): The active user needs **any single matching role** in [allowedRoles] (OR logic).
  /// - If `true`: The active user must possess **all roles** specified in [allowedRoles] (AND logic).
  final bool requireAll;

  /// Instantiates a new [@Secured] annotation definition.
  ///
  /// [allowedRoles] must not be empty.
  const Secured(
    this.allowedRoles, {
    this.name,
    this.fallback = FallbackType.hide,
    this.requireAll = false,
  });
}
