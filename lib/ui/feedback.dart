import 'package:material_ui/material_ui.dart';

import '../core/api/api_client.dart';
import '../l10n/app_localizations.dart';

/// User-facing message for an error. Known server codes get translated copy; others fall back to
/// the server's message (already human-readable).
String errorText(BuildContext context, Object e) {
  final l = AppLocalizations.of(context);
  if (e is ApiException) {
    return switch (e.code) {
      'offline' || 'timeout' => l.errOffline,
      'invalid_credentials' => l.errCredentials,
      'feature_locked' => l.errFeatureLocked,
      'limit_reached' => l.errLimit,
      'permission_denied' => l.errPermission,
      'taken' => l.errTaken,
      'queue_full' => l.errQueueFull,
      'not_head' => l.errNotHead,
      'item_unavailable' => l.errSoldOut,
      'session_expired' || 'no_session' => l.errSessionExpired,
      _ => e.message.isEmpty ? l.errGeneric : e.message,
    };
  }
  return l.errGeneric;
}

void showError(BuildContext context, Object e) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(errorText(context, e))));
}

void showDone(BuildContext context, String message) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
}

/// Runs an action, shows a snackbar on failure, returns success.
Future<bool> guard(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}
