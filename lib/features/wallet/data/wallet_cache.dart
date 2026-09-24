import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/wallet_snapshot.dart';
import 'wallet_json.dart';

/// Saves the latest [WalletSnapshot] on the device as one JSON value in
/// shared preferences.
///
/// This is enough for 20 items. For more, such as caching the full history
/// or searching it offline, use SQLite (drift). See the README.
class WalletCache {
  WalletCache(this._prefs);

  static const _key = 'wallet_snapshot_v1';

  final SharedPreferencesAsync _prefs;

  Future<WalletSnapshot?> read() async {
    try {
      final raw = await _prefs.getString(_key);
      if (raw == null) return null;
      return walletSnapshotFromJson(jsonDecode(raw) as Map<String, Object?>);
    } catch (e) {
      // An unreadable cache is a cache miss, not a crash. This happens if
      // the saved data is corrupt or was written by an older app version.
      developer.log('Discarding unreadable cache', error: e, name: 'cache');
      await clear();
      return null;
    }
  }

  Future<void> write(WalletSnapshot snapshot) =>
      _prefs.setString(_key, jsonEncode(snapshot.toJson()));

  Future<void> clear() => _prefs.remove(_key);
}
