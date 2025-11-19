import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favKey = 'favorites';
  static const _userKey = 'mock_user';

  late final SharedPreferences _pref;

  /// Initialize SharedPreferences instance
  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  /// --- FAVORITES ---

  List<String> getFavorites() {
    return _pref.getStringList(_favKey) ?? <String>[];
  }

  Future<void> saveFavorites(List<String> ids) async {
    await _pref.setStringList(_favKey, ids);
  }

  /// --- USER DATA (mock login/register) ---

  Map<String, dynamic>? getUser() {
    final data = _pref.getString(_userKey);
    if (data == null || data.isEmpty) return null;
    final parts = data.split('|');
    if (parts.length != 2) return null;
    return {'name': parts[0], 'email': parts[1]};
  }

  Future<void> saveUser(String name, String email) async {
    await _pref.setString(_userKey, '$name|$email');
  }

  Future<void> clearUser() async {
    await _pref.remove(_userKey);
  }
}