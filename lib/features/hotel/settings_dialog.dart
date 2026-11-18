import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/session.dart';
import '../../core/money.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

Future<void> showSettingsDialog(BuildContext context, {bool billing = false}) {
  return showGlassDialog(context,
      title: AppLocalizations.of(context).settings, maxWidth: 560, body: _Settings(startOnBilling: billing));
}

class _Settings extends ConsumerStatefulWidget {
  const _Settings({required this.startOnBilling});
  final bool startOnBilling;

  @override
  ConsumerState<_Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<_Settings> {
  late String _tab = widget.startOnBilling ? 'billing' : 'kitchen';
  Map<String, dynamic>? _settings;
  Map<String, dynamic>? _sub;
  final _name = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ref.read(apiProvider);
    try {
      final s = Map<String, dynamic>.from(await api.get('/api/v1/settings'));
      final b = Map<String, dynamic>.from(await api.get('/api/v1/billing/subscription'));
      if (!mounted) return;
      setState(() {
        _settings = s;
        _sub = b;
        _name.text = s['name'];
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_settings == null || _sub == null) return const LoadingBlock(height: 200);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PillTabs<String>(
        expand: true,
        items: [('kitchen', l.kitchenAndOrdering), ('billing', l.planAndBilling)],
        selected: _tab,
        onSelect: (v) => setState(() => _tab = v),
      ),
      const SizedBox(height: 8),
      AnimatedSwitcher(
        duration: Motion.medium,
        child: _tab == 'kitchen'
            ? KeyedSubtree(key: const ValueKey('k'), child: _kitchen(context))
            : KeyedSubtree(key: const ValueKey('b'), child: _billing(context)),
      ),
    ]);
  }

  Widget _kitchen(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _settings!;
    final modes = (s['available_modes'] as List).cast<String>();
    String modeLabel(String m) => switch (m) {
          'CHEF_ACCEPT' => l.modeChefAccept,
          'AUTO_ASSIGN' => l.modeAutoAssign,
          _ => l.modeAdminPrint,
        };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      FieldLabel(l.restaurantName),
      TextField(controller: _name),
      FieldLabel(l.kitchenMode, help: l.kitchenModeHelp),
      ChoiceRow<String>(
        options: [for (final m in ['CHEF_ACCEPT', 'AUTO_ASSIGN', 'ADMIN_PRINT']) (m, modeLabel(m))],
        value: s['kitchen_mode'],
        onChanged: (v) {
          if (!modes.contains(v)) {
            showDone(context, l.errFeatureLocked);
            return;
          }
          setState(() => s['kitchen_mode'] = v);
        },
      ),
      FieldLabel(l.maxQueue, help: l.maxQueueHelp),
      ChoiceRow<int>(
        options: [for (final n in [1, 2, 3, 4, 5]) (n, '$n')],
        value: s['max_queue_orders'],
        onChanged: (v) => setState(() => s['max_queue_orders'] = v),
      ),
      const SizedBox(height: 10),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l.confirmQrOrders),
        subtitle: Text(l.confirmQrOrdersHelp),
        value: s['qr_confirm_required'] == true,
        onChanged: (v) => setState(() => s['qr_confirm_required'] = v),
      ),
      DialogActions(
        primary: l.saveChanges,
        busy: _busy,
        onPrimary: () async {
          setState(() => _busy = true);
          final ok = await guard(
              context,
              () => ref.read(apiProvider).put('/api/v1/settings', {
                    'name': _name.text.trim(),
                    'kitchen_mode': s['kitchen_mode'],
                    'max_queue_orders': s['max_queue_orders'],
                    'qr_confirm_required': s['qr_confirm_required'],
                  }));
          if (!mounted) return;
          setState(() => _busy = false);
          if (ok) {
            await ref.read(sessionProvider.notifier).reload();
            if (mounted) Navigator.of(this.context).pop();
          }
        },
      ),
    ]);
  }

  Widget _billing(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final b = _sub!;
    final plan = b['plan'] as Map;
    final status = b['status'] as String;
    final trialEnds = b['trial_ends_at'] == null ? null : DateTime.parse(b['trial_ends_at']).toLocal();
    final periodEnd = b['current_period_end'] == null ? null : DateTime.parse(b['current_period_end']).toLocal();
    final (icon, label, color) = switch (status) {
      'ACTIVE' => (Icons.verified_outlined, l.subActive, t.ok),
      'TRIAL' => (Icons.hourglass_bottom_rounded, l.subTrial, t.info),
      'PAST_DUE' => (Icons.warning_amber_rounded, l.subPastDue, t.warn),
      _ => (Icons.lock_outline, l.subSuspended, t.danger),
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 8),
      NightPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(plan['name'], style: tt.headlineSmall?.copyWith(color: t.onNight))),
            StatusChip(icon: icon, label: label, color: color, solid: true),
          ]),
          const SizedBox(height: 6),
          Text(l.perMonth(formatInr(plan['price_minor'], showPaise: false)), style: tt.bodyMedium?.copyWith(color: t.nightDim)),
          if (status == 'TRIAL' && trialEnds != null)
            Text(l.trialEndsOn(DateFormat.yMMMd().format(trialEnds)), style: tt.bodySmall?.copyWith(color: t.nightDim)),
          if (status != 'TRIAL' && periodEnd != null)
            Text(l.renewsOn(DateFormat.yMMMd().format(periodEnd)), style: tt.bodySmall?.copyWith(color: t.nightDim)),
        ]),
      ),
      FieldLabel(l.choosePlan, help: b['payments_enabled'] == true ? l.choosePlanHelp : l.paymentsNotConfigured),
      for (final p in (b['plans'] as List).cast<Map>())
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p['code'] == plan['code'] ? t.accentSoft : t.well,
              borderRadius: BorderRadius.circular(Rad.tile),
              border: Border.all(color: t.line),
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['name'], style: tt.titleMedium),
                  Text(l.perMonth(formatInr(p['price_minor'], showPaise: false)), style: tt.bodySmall),
                ]),
              ),
              FilledButton(
                onPressed: b['payments_enabled'] != true
                    ? null
                    : () async {
                        try {
                          final r = await ref.read(apiProvider).post('/api/v1/billing/subscription/checkout', {'plan_code': p['code']});
                          final url = r['checkout_url'] as String?;
                          if (url != null) await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
                        } on ApiException catch (e) {
                          if (context.mounted) showError(context, e);
                        }
                      },
                child: Text(p['code'] == plan['code'] && status == 'ACTIVE' ? l.renew : l.payAndActivate),
              ),
            ]),
          ),
        ),
      if ((b['invoices'] as List).isNotEmpty) ...[
        FieldLabel(l.payments),
        for (final i in (b['invoices'] as List).cast<Map>())
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(i['status'] == 'PAID' ? Icons.check_circle_outline : Icons.error_outline,
                  size: 18, color: i['status'] == 'PAID' ? t.ok : t.danger),
              const SizedBox(width: 8),
              Expanded(child: Text(DateFormat.yMMMd().format(DateTime.parse(i['created_at']).toLocal()))),
              Text(formatInr(i['amount_minor']), style: tt.labelLarge),
            ]),
          ),
      ],
    ]);
  }
}
