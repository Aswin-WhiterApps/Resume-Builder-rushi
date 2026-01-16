import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:resume_builder/services/api_client.dart';
import 'package:resume_builder/services/secure_storage_service.dart';

class AuthService {
  /// Returns a valid access token.
  /// If the current access token is expired, it attempts to refresh it.
  /// Returns null if no token exists or refresh fails.
  static Future<String?> getValidAccessToken() async {
    final accessToken = await SecureStorageService.getAccessToken();

    if (accessToken == null) return null;

    if (JwtDecoder.isExpired(accessToken)) {
      return await refreshAccessToken();
    }

    return accessToken;
  }

  /// Refreshes the access token using the stored refresh token.
  /// Saves the new tokens to secure storage if successful.
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await SecureStorageService.getRefreshToken();
    if (refreshToken == null) {
      _logToCrashlytics('Token refresh failed: No refresh token found');
      return null;
    }

    try {
      // Call refresh API
      final response = await ApiClient.refreshToken(refreshToken);

      if (response != null) {
        await SecureStorageService.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );
        return response.accessToken;
      } else {
        // If refresh fails (e.g., refresh token expired), clear tokens
        await SecureStorageService.clearTokens();
        _logToCrashlytics('Token refresh failed: Invalid response from server');
      }
    } catch (e, stack) {
      _logToCrashlytics('Token refresh error: $e', stack);
      await SecureStorageService.clearTokens();
    }
    return null;
  }

  /// Log critical auth events to Crashlytics (only in production)
  static void _logToCrashlytics(String message, [StackTrace? stack]) {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      FirebaseCrashlytics.instance.log(message);
      if (stack != null) {
        FirebaseCrashlytics.instance.recordError(
          message,
          stack,
          reason: 'Authentication Service Error',
        );
      }
    }
  }
}
