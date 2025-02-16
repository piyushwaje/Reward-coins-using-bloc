import 'package:shared_preferences/shared_preferences.dart';

mixin SharedPreferencesMixin {
  Future<int> loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('balance') ?? 1000; // Default balance is 1000
  }

  Future<DateTime?> loadLastScratchTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLastScratchTime = prefs.getString('lastScratchTime');
    return savedLastScratchTime != null ? DateTime.parse(savedLastScratchTime) : null;
  }

  Future<void> saveBalance(int balance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('balance', balance);
  }

  Future<void> saveLastScratchTime(DateTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastScratchTime', time.toIso8601String());
  }
}