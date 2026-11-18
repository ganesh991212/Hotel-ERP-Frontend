import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loud in-app alerts. Adapted from GigBridge's NotificationSoundService (one lazily created player per
/// sound, failures never crash). Sounds are original, synthesised near full scale (~-6 dBFS RMS), and the
/// new-order alert plays twice. Browsers block audio until the user has tapped the page once; "Test sound"
/// in the profile menu doubles as that unlock.
enum AlertKind { newOrder, ready }

class AlertSound {
  final _players = <AlertKind, AudioPlayer>{};
  bool enabled = true;
  bool lastFailed = false;

  /// True once a sound has played in this page session (browsers allow audio only after a user tap).
  bool unlocked = false;

  static const _files = {AlertKind.newOrder: 'sounds/kitchen_alert.wav', AlertKind.ready: 'sounds/ready_alert.wav'};

  Future<void> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    enabled = p.getBool('alerts.sound') ?? true;
  }

  Future<void> setEnabled(bool v) async {
    enabled = v;
    (await SharedPreferences.getInstance()).setBool('alerts.sound', v);
  }

  Future<void> play(AlertKind kind, {bool force = false}) async {
    if (!enabled && !force) return;
    try {
      final player = _players[kind] ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      await player.setVolume(1.0);
      await player.play(AssetSource(_files[kind]!), volume: 1.0);
      lastFailed = false;
      unlocked = true;
      if (kind == AlertKind.newOrder) {
        // Second ring so a busy kitchen does not miss it.
        await player.onPlayerComplete.first.timeout(const Duration(seconds: 4));
        await player.play(AssetSource(_files[kind]!), volume: 1.0);
      }
    } catch (_) {
      lastFailed = true; // e.g. browser autoplay policy before the first tap
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}

final alertSoundProvider = Provider<AlertSound>((ref) {
  final s = AlertSound()..loadPrefs();
  ref.onDispose(s.dispose);
  return s;
});
