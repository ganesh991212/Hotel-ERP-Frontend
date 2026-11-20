import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/api/api_client.dart';
import '../core/money.dart';
import '../core/theme/tokens.dart';
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
      'wrong_password' => l.errWrongPassword,
      'discount_limit' => l.errDiscountLimit(percentLabel((e.details['max_bp'] as num?)?.toInt() ?? 0)),
      'bad_discount' => l.errBadDiscount,
      'overpayment' => l.errOverpayment(formatInr((e.details['due_minor'] as num?)?.toInt() ?? 0)),
      'has_payments' => l.errHasPayments,
      'payments_exceed_total' => l.errPaymentsExceedTotal,
      'same_password' => l.errSamePassword,
      'lines_changed' => l.errLinesChanged,
      'split_partly_paid' => l.errSplitPartlyPaid,
      'bill_discounted' => l.errBillDiscounted,
      'variant_required' => l.errVariantRequired,
      'bad_combo' => l.errBadCombo,
      'note_required' => l.errNoteRequired,
      'table_in_use' => l.errTableInUse,
      'already_closed' => l.errAlreadyClosed,
      'outside_hours' => e.details['hours'] is String
          ? '${l.errOutsideHours} (${e.details['category']} ${e.details['hours']})'
          : l.errOutsideHours,
      'item_in_combo' => l.errItemInCombo,
      'addon_count' || 'bad_addon' || 'bad_variant' => l.errAddonCount,
      'guest_empty' || 'bad_split' => l.splitIncomplete,
      'range_too_long' => e.details['max_days'] is num
          ? l.errRangeTooLongDays((e.details['max_days'] as num).toInt())
          : l.errRangeTooLong,
      'server_error' => l.errGeneric, // server crash: show translated copy, not the server's English text
      _ => e.message.isEmpty ? l.errGeneric : e.message,
    };
  }
  return l.errGeneric;
}

void showError(BuildContext context, Object e) => _toast(context, errorText(context, e), error: true);

void showDone(BuildContext context, String message) => _toast(context, message, error: false);

/// Something needs attention that is not a failed request (e.g. an order nobody picked up).
void showWarning(BuildContext context, String message) => _toast(context, message, error: true);

/// The toast on screen, if any. A new message replaces it rather than queueing behind it.
OverlayEntry? _current;

/// Shows a message in the app's top layer, above any open dialog and its blurred backdrop.
/// (A SnackBar belongs to the page under the dialog, so the dialog's blur covered it.)
void _toast(BuildContext context, String message, {required bool error}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _current?.remove();
  late final OverlayEntry entry;
  void done() {
    if (identical(_current, entry)) _current = null;
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(builder: (_) => _Toast(message: message, error: error, onDone: done));
  _current = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.error, required this.onDone});
  final String message;
  final bool error;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _a = AnimationController(vsync: this, duration: Motion.fast);
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _a.forward();
    // Errors stay longer: they usually need reading, not just noticing.
    _timer = Timer(widget.error ? const Duration(seconds: 6) : const Duration(seconds: 3), _close);
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    await _a.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = t.onNight;
    final c = CurvedAnimation(parent: _a, curve: Motion.ease);
    // Status is icon + label, never colour alone (rule 8).
    final icon = widget.error ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;
    return Positioned(
      left: 16,
      right: 16,
      // Clear of the bottom navigation dock.
      bottom: MediaQuery.paddingOf(context).bottom + 96,
      child: SafeArea(
        top: false,
        child: Center(
          child: FadeTransition(
            opacity: c,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(c),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Semantics(
                  liveRegion: true,
                  child: Material(
                    color: t.night,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(Rad.tile),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Rad.tile),
                      onTap: _close,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icon, size: 20, color: widget.error ? t.danger : t.accent),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(widget.message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg)),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Runs an action, shows an error toast on failure, returns success.
Future<bool> guard(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}
