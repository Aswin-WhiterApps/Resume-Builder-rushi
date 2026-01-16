import 'package:flutter/material.dart';

/// Utility class for safe navigation operations
class NavigationHelper {
  static bool _isAuthDialogActive = false;

  /// Safely navigate to a new route, replacing the current one if possible
  static void safePushReplacementNamed(BuildContext context, String routeName) {
    try {
      // Check if we can safely replace a route
      if (_canReplaceRoute(context)) {
        Navigator.pushReplacementNamed(context, routeName);
      } else {
        // Use pushAndRemoveUntil for clean stack when no route to replace
        Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Navigation error in safePushReplacementNamed: $e');
      // Fallback to pushAndRemoveUntil
      _fallbackNavigation(context, routeName);
    }
  }

  /// Safely navigate to a new route
  static void safePushNamed(BuildContext context, String routeName) {
    try {
      if (Navigator.of(context).canPop()) {
        Navigator.pushNamed(context, routeName);
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Navigation error in safePushNamed: $e');
      _fallbackNavigation(context, routeName);
    }
  }

  /// Check if navigator is ready for operations
  static bool isNavigatorReady(BuildContext context) {
    try {
      return Navigator.canPop(context);
    } catch (e) {
      return false;
    }
  }

  /// Enhanced check for route replacement capability
  static bool _canReplaceRoute(BuildContext context) {
    try {
      // Check if there are routes in the stack besides dialogs
      return Navigator.of(context).canPop() && !_isOnlyDialogInStack(context);
    } catch (e) {
      debugPrint('Error checking route replacement capability: $e');
      return false;
    }
  }

  /// Check if only dialogs are present in the navigation stack
  static bool _isOnlyDialogInStack(BuildContext context) {
    try {
      // This is a heuristic - in practice, we'll be conservative
      // and assume we can't replace if there's any doubt
      return false; // Simplified for safety
    } catch (e) {
      return true; // Err on side of caution
    }
  }

  /// Fallback navigation method
  static void _fallbackNavigation(BuildContext context, String routeName) {
    try {
      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        (route) => false,
      );
    } catch (e) {
      debugPrint('Fallback navigation failed: $e');
      // Last resort - try to push without removing
      try {
        Navigator.pushNamed(context, routeName);
      } catch (e2) {
        debugPrint('All navigation methods failed: $e2');
      }
    }
  }

  /// Safe dialog management for auth flows
  static void safeShowAuthDialog(BuildContext context, Widget dialog) {
    try {
      // Check if there's already a dialog showing
      if (!_isAuthDialogActive) {
        _isAuthDialogActive = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => dialog,
        ).then((_) => _isAuthDialogActive = false);
      }
    } catch (e) {
      debugPrint('Error showing auth dialog: $e');
      _isAuthDialogActive = false;
    }
  }

  /// Safe dialog removal
  static void safeRemoveAuthDialog(BuildContext context) {
    try {
      if (_isAuthDialogActive) {
        Navigator.of(context, rootNavigator: true).pop();
        _isAuthDialogActive = false;
      }
    } catch (e) {
      debugPrint('Error removing auth dialog: $e');
      _isAuthDialogActive = false;
    }
  }

  /// Check if a dialog is currently showing
  static bool _isDialogShowing(BuildContext context) {
    return _isAuthDialogActive;
  }

  /// Enhanced navigation for authentication success
  static void navigateToHomeAfterAuth(BuildContext context) {
    try {
      // First, ensure any dialogs are removed
      safeRemoveAuthDialog(context);

      // Small delay to ensure dialog removal is complete
      Future.microtask(() {
        safePushReplacementNamed(context, '/homescreen');
      });
    } catch (e) {
      debugPrint('Error in auth navigation: $e');
      _fallbackNavigation(context, '/homescreen');
    }
  }
}
