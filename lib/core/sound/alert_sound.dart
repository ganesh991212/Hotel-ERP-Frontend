import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loud in-app alerts. Adapted from GigBridge's NotificationSoundService (one lazily created player per
/// sound, failures never crash). Sounds are original, synthesised near full scale (~-6 dBFS RMS), and the
/// new-order alert plays twice. Browsers block audio until the user has tapped the page once after it loads;
/// [prime] runs on the first tap anywhere in the app so nobody has to press a special button after a refresh.
enum AlertKind { newOrder, ready }

class AlertSound extends ChangeNotifier {
  final _players = <AlertKind, AudioPlayer>{};
  bool enabled = true;
  bool lastFailed = false;

  /// True once audio has been allowed in this page session (browsers allow it only after a user tap).
  /// Resets on every page load by browser rule; that is why it must not decide whether to nag the user.
  bool unlocked = false;

  /// Preferences have been read; until then the alerts banner stays hidden (no flash on load).
  bool loaded = false;

  /// When this browser last answered the alerts banner (Enable or Not now). Stored per browser,
  /// like the browser's own notification permission.
  DateTime? askedAt;

  /// "Not now" is honoured for this long; then the banner may ask again if notifications are still off.
  static const askAgainAfter = Duration(days: 7);

  static const _files = {AlertKind.newOrder: 'sounds/kitchen_alert.wav', AlertKind.ready: 'sounds/ready_alert.wav'};

  Future<void> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    enabled = p.getBool('alerts.sound') ?? true;
    final at = p.getInt('alerts.askedAt');
    askedAt = at == null ? null : DateTime.fromMillisecondsSinceEpoch(at);
    loaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool v) async {
    enabled = v;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('alerts.sound', v);
  }

  /// Whether the banner already got an answer in this browser recently.
  bool get recentlyAsked => askedAt != null && DateTime.now().difference(askedAt!) < askAgainAfter;

  Future<void> markAsked() async {
    askedAt = DateTime.now();
    notifyListeners();
    (await SharedPreferences.getInstance()).setInt('alerts.askedAt', askedAt!.millisecondsSinceEpoch);
  }

  /// Silently unlocks audio for this page session. Call from a user tap: browsers (Safari strictest) only
  /// allow a media element to start playing from inside a user gesture, so each player is started muted
  /// once and stopped. Real alerts then play at full volume without another tap.
  Future<void> prime() async {
    if (unlocked) return;
    unlocked = true; // one attempt per page load; a failure is reported by [lastFailed] on the next real play
    try {
      for (final kind in AlertKind.values) {
        final player = _players[kind] ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
        await player.play(AssetSource(_files[kind]!), volume: 0);
        await player.stop();
      }
    } catch (_) {
      unlocked = false;
    }
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

  @override
  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
    super.dispose();
  }
}

final alertSoundProvider = Provider<AlertSound>((ref) {
  final s = AlertSound()..loadPrefs();
  ref.onDispose(s.dispose);
  return s;
});
