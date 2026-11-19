import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_erp/core/sound/alert_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fresh AlertSound is what the app has after every refresh or in a new tab.
Future<AlertSound> _afterReload() async {
  final s = AlertSound();
  await s.loadPrefs();
  return s;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an answer to the alerts banner survives a page reload', () async {
    SharedPreferences.setMockInitialValues({});
    final first = await _afterReload();
    expect(first.loaded, isTrue);
    expect(first.recentlyAsked, isFalse, reason: 'new browser: the banner may ask');

    await first.markAsked();
    final reloaded = await _afterReload();
    expect(reloaded.recentlyAsked, isTrue, reason: 'same browser after refresh: do not ask again');
    expect(reloaded.unlocked, isFalse, reason: 'audio unlock is per page load and must not drive the banner');
  });

  test('"Not now" is honoured for a week, then the banner may ask again', () async {
    final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({'alerts.askedAt': eightDaysAgo});
    expect((await _afterReload()).recentlyAsked, isFalse);

    final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6)).millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({'alerts.askedAt': sixDaysAgo});
    expect((await _afterReload()).recentlyAsked, isTrue);
  });
}
