import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedSessionData {
  const CachedSessionData({
    required this.userJson,
    required this.roles,
    required this.permissions,
  });

  final Map<String, dynamic> userJson;
  final List<String> roles;
  final List<String> permissions;

  Map<String, dynamic> toJson() => {
        'user': userJson,
        'roles': roles,
        'permissions': permissions,
      };

  factory CachedSessionData.fromJson(Map<String, dynamic> json) {
    return CachedSessionData(
      userJson: Map<String, dynamic>.from(json['user'] as Map),
      roles: (json['roles'] as List<dynamic>).cast<String>(),
      permissions: (json['permissions'] as List<dynamic>).cast<String>(),
    );
  }
}

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _sessionKey = 'session_json';

  Future<CachedSessionData?> getCachedSession() async {
    final raw = _prefs.getString(_sessionKey);
    if (raw == null) return null;
    return CachedSessionData.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> saveCachedSession(CachedSessionData session) async {
    await _prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }
}
