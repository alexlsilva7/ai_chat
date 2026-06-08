import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  @override
  String get apiKey => _prefs.getString('gemini_api_key') ?? '';

  @override
  String get userName => _prefs.getString('user_name') ?? 'Alex';

  @override
  Future<void> saveApiKey(String key) async {
    await _prefs.setString('gemini_api_key', key);
  }

  @override
  Future<void> saveUserName(String name) async {
    await _prefs.setString('user_name', name);
  }
}
