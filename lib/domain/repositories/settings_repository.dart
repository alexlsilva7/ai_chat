abstract class SettingsRepository {
  String get apiKey;
  String get userName;
  Future<void> saveApiKey(String key);
  Future<void> saveUserName(String name);
}
