import 'dart:core';

/// A high-performance bitwise role mapping and authorization evaluation engine.
///
/// [RoleRegistry] dynamically assigns unique integer bitmask flags (`1 << index`)
/// to string role identifiers (e.g. `'admin'`, `'manager'`, `'UserRole.admin'`).
///
/// By translating role sets into primitive 64-bit integer masks, authorization
/// evaluations (`isAuthorized`, `hasAnyRole`, `hasAllRoles`) are reduced from $O(N)$
/// string allocations and hash set lookups to single-cycle $O(1)$ bitwise CPU operations.
///
/// ### Bitwise Authorization Mechanics:
/// - **OR Matching (`!requireAll`)**: Evaluates `(activeMask & targetMask) != 0`
/// - **AND Matching (`requireAll`)**: Evaluates `(activeMask & targetMask) == targetMask`
///
/// ### Example Usage:
/// ```dart
/// final activeMask = RoleRegistry.getMaskForRoles(['admin', 'manager']);
/// final allowedMask = RoleRegistry.getMaskForRole('admin');
///
/// final isAuthorized = RoleRegistry.matchMask(
///   activeMask: activeMask,
///   targetMask: allowedMask,
///   requireAll: false,
/// ); // Returns true instantly via bitwise AND (&) operation
/// ```
class RoleRegistry {
  RoleRegistry._();

  /// Internal lookup cache mapping normalized role identifiers to their bitmask flags.
  static final Map<String, int> _roleBitMap = <String, int>{};

  /// Monotonically increasing counter keeping track of the next bit index allocation.
  static int _nextBitIndex = 0;

  /// Maximum supported unique bit positions in standard Dart 64-bit integer bitmasks.
  static const int maxBitCapacity = 62;

  /// Retrieves or assigns a deterministic bitmask flag for a single [role] identifier.
  ///
  /// Automatically normalizes dot-separated enum role strings (e.g. `'UserRole.admin'`)
  /// by binding both qualified `'UserRole.admin'` and simple `'admin'` to the same bit position.
  ///
  /// Parameters:
  /// - [role]: The role string identifier or qualified enum name to convert into a bitmask.
  ///
  /// Returns a 64-bit integer with a single bit enabled (`1 << bitIndex`).
  static int getMaskForRole(String role) {
    final normalized = role.trim();
    if (normalized.isEmpty) return 0;

    // Handle qualified enum strings (e.g., 'UserRole.admin' -> binds 'admin' as well)
    final simpleName = normalized.contains('.') ? normalized.split('.').last : normalized;

    // Check if simple role name is already registered to reuse bit position
    final existingBit = _roleBitMap[simpleName] ?? _roleBitMap[normalized];
    if (existingBit != null) {
      _roleBitMap[normalized] = existingBit;
      _roleBitMap[simpleName] = existingBit;
      return existingBit;
    }

    // Allocate next available bit shift position
    final bitIndex = _nextBitIndex % maxBitCapacity;
    final mask = 1 << bitIndex;
    _nextBitIndex++;

    _roleBitMap[normalized] = mask;
    _roleBitMap[simpleName] = mask;

    return mask;
  }

  /// Calculates a combined bitmask representing a collection of active or allowed [roles].
  ///
  /// Combines individual role bitmasks using a bitwise OR (`|`) operation.
  ///
  /// Parameters:
  /// - [roles]: Iterable of role strings to aggregate into a single bitmask integer.
  ///
  /// Returns an integer representing the combined bitwise flags for all specified roles.
  static int getMaskForRoles(Iterable<String>? roles) {
    if (roles == null) return 0;
    int combinedMask = 0;

    for (final role in roles) {
      combinedMask |= getMaskForRole(role);
    }

    return combinedMask;
  }

  /// Performs an $O(1)$ constant-time bitwise authorization check matching [activeMask] against [targetMask].
  ///
  /// Parameters:
  /// - [activeMask]: Integer bitmask representing the user's active/granted roles.
  /// - [targetMask]: Integer bitmask representing required/allowed roles for a resource.
  /// - [requireAll]: If `true`, all bits in [targetMask] must be present in [activeMask] (AND logic).
  ///   If `false` (default), any matching bit grants access (OR logic).
  ///
  /// Returns `true` if authorization condition is satisfied, otherwise `false`.
  static bool matchMask({
    required int activeMask,
    required int targetMask,
    bool requireAll = false,
  }) {
    if (targetMask == 0) return false;
    if (activeMask == 0) return false;

    if (requireAll) {
      return (activeMask & targetMask) == targetMask;
    } else {
      return (activeMask & targetMask) != 0;
    }
  }

  /// Resets internal bit allocation maps and bit counters.
  ///
  /// Intended primarily for testing environments to isolate role allocation states between tests.
  static void resetRegistry() {
    _roleBitMap.clear();
    _nextBitIndex = 0;
  }
}
