import 'package:flutter/material.dart';

/// A UI wrapper widget that disables interaction and overlays a lock badge.
///
/// Used by [SecuredFeature] and generated `@Secured` widgets when using
/// [FallbackType.disabled].
class LockOverlay extends StatelessWidget {
  /// The target widget to disable and overlay.
  final Widget child;

  /// Opacity level applied to [child] when disabled. Defaults to `0.5`.
  final double opacity;

  /// Whether to render a lock badge icon over the child widget. Defaults to `true`.
  final bool showLockBadge;

  /// Optional custom lock icon or badge widget.
  /// If `null` and [showLockBadge] is `true`, defaults to a styled lock icon container.
  final Widget? lockIcon;

  /// Creates a [LockOverlay] instance.
  const LockOverlay({
    super.key,
    required this.child,
    this.opacity = 0.5,
    this.showLockBadge = true,
    this.lockIcon,
  });

  @override
  Widget build(BuildContext context) {
    final disabledChild = AbsorbPointer(
      absorbing: true,
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );

    if (!showLockBadge) {
      return disabledChild;
    }

    final defaultLockBadge = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.lock_outline,
        color: Colors.white,
        size: 18,
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        disabledChild,
        lockIcon ?? defaultLockBadge,
      ],
    );
  }
}
