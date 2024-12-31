import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Lấy userId từ SharedPreferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');  // Trả về userId từ SharedPreferences
  }

  // Lưu userId vào SharedPreferences
  static Future<void> setUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);  // Lưu userId vào SharedPreferences
  }

  // Xóa userId khỏi SharedPreferences
  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');  // Xóa userId khỏi SharedPreferences
  }
}
