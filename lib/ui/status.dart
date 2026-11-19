import 'package:material_ui/material_ui.dart';

import '../core/theme/tokens.dart';
import '../l10n/app_localizations.dart';
import 'components.dart';

/// One place that maps order states to icon + label + colour (never colour alone).
(IconData, String, Color) orderStatusLook(BuildContext context, String status) {
  final t = context.tokens;
  final l = AppLocalizations.of(context);
  return switch (status) {
    'PLACED' => (Icons.hourglass_top_rounded, l.statusPlaced, t.warn),
    'CONFIRMED' => (Icons.inbox_rounded, l.statusConfirmed, t.info),
    'ASSIGNED' => (Icons.queue_rounded, l.statusQueued, t.dim),
    'PREPARING' => (Icons.local_fire_department_rounded, l.statusPreparing, t.accent),
    'READY' => (Icons.notifications_active_rounded, l.statusReady, t.ok),
    'SERVED' => (Icons.done_all_rounded, l.statusServed, t.faint),
    'CANCELLED' => (Icons.cancel_outlined, l.statusCancelled, t.danger),
    _ => (Icons.help_outline, status, t.dim),
  };
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip(this.status, {super.key, this.solid = false});
  final String status;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = orderStatusLook(context, status);
    return StatusChip(icon: icon, label: label, color: color, solid: solid);
  }
}

String channelLabel(BuildContext context, String channel) {
  final l = AppLocalizations.of(context);
  return switch (channel) {
    'QR' => l.channelQr,
    'WAITER' => l.channelWaiter,
    'ADMIN' => l.channelAdmin,
    _ => channel,
  };
}

IconData channelIcon(String channel) => switch (channel) {
      'QR' => Icons.qr_code_2_rounded,
      'WAITER' => Icons.room_service_outlined,
      _ => Icons.badge_outlined,
    };

/// Minutes since an ISO timestamp, for "5 min ago" labels. Time, not money.
int minutesSince(String? iso) {
  if (iso == null) return 0;
  final d = DateTime.tryParse(iso);
  if (d == null) return 0;
  return DateTime.now().toUtc().difference(d.toUtc()).inMinutes;
}

String roleLabel(BuildContext context, String? code, [String? fallback]) {
  final l = AppLocalizations.of(context);
  return switch (code) {
    'HOTEL_ADMIN' => l.roleHotelAdmin,
    'MANAGER' => l.roleManager,
    'CASHIER' => l.roleCashier,
    'WAITER' => l.roleWaiter,
    'CHEF' => l.roleChef,
    'PLATFORM_ADMIN' => l.rolePlatformAdmin,
    _ => fallback ?? code ?? '',
  };
}

/// "What happens next, and who does it" for an order (docs/04 "Order workflow"). One place for the Floor,
/// the table window and the Orders screen, so every screen tells staff the same thing.
String? nextStepText(BuildContext context, Map<String, dynamic> o, {String? kitchenMode}) {
  final l = AppLocalizations.of(context);
  final chef = (o['chef'] as Map?)?['name'] as String?;
  return switch (o['status']) {
    'PLACED' => l.nextConfirm,
    'CONFIRMED' => switch (kitchenMode) {
        'ADMIN_PRINT' => l.nextPrintKot,
        'AUTO_ASSIGN' => l.nextFreeChef,
        _ => l.nextChefPickup,
      },
    'ASSIGNED' => chef != null ? l.nextChefStarts(chef) : l.nextFreeChef,
    'PREPARING' => o['on_paper'] == true ? l.nowCookingPaper : (chef != null ? l.nowCooking(chef) : null),
    'READY' => l.nextServe,
    'SERVED' => o['bill_id'] == null ? l.nextBill : null,
    _ => null,
  };
}

/// Shown on an order no chef took within the outlet's alert time (the server sets pickup_alerted_at).
bool isPickupOverdue(Map<String, dynamic> o) => o['status'] == 'CONFIRMED' && o['pickup_alerted_at'] != null;

class PickupOverdueChip extends StatelessWidget {
  const PickupOverdueChip({super.key});

  @override
  Widget build(BuildContext context) =>
      StatusChip(icon: Icons.alarm_rounded, label: AppLocalizations.of(context).notPickedUp, color: context.tokens.danger);
}
