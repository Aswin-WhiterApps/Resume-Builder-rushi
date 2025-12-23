import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _uidKey = "logged_in_user_uid";

  static Future<void> saveUserUid(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
  }

  static Future<String?> getUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uidKey);
  }

  static Future<void> clearUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uidKey);
  }
}
