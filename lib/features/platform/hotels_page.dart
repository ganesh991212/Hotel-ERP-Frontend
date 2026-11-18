import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';

final platformHotelsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) async => ((await ref.read(apiProvider).get('/api/v1/platform/hotels')) as List).cast<Map<String, dynamic>>());
final platformPlansProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) async => ((await ref.read(apiProvider).get('/api/v1/platform/plans')) as List).cast<Map<String, dynamic>>());

Widget hotelStatusChip(BuildContext context, String status, {bool solid = false}) {
  final l = AppLocalizations.of(context);
  final t = context.tokens;
  final (icon, label, color) = switch (status) {
    'ACTIVE' => (Icons.verified_outlined, l.subActive, t.ok),
    'TRIAL' => (Icons.hourglass_bottom_rounded, l.subTrial, t.info),
    'PAST_DUE' => (Icons.warning_amber_rounded, l.subPastDue, t.warn),
    _ => (Icons.lock_outline, l.subSuspended, t.danger),
  };
  return StatusChip(icon: icon, label: label, color: color, solid: solid);
}

class HotelsPage extends ConsumerStatefulWidget {
  const HotelsPage({super.key});

  @override
  ConsumerState<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends ConsumerState<HotelsPage> {
  String _status = '';
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(platformHotelsProvider);
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(l.tabHotels, actions: [
          SizedBox(
            width: context.isPhone ? double.infinity : 280,
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchHotels),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              await showGlassDialog(context, title: l.registerHotel, maxWidth: 560, body: const _RegisterForm());
              ref.invalidate(platformHotelsProvider);
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l.registerHotel),
          ),
        ]),
      ),
      data.when(
        loading: () => const LoadingBlock(),
        error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
        data: (list) {
          final q = _search.text.trim().toLowerCase();
          final shown = list
              .where((h) => _status.isEmpty || h['status'] == _status)
              .where((h) => q.isEmpty || '${h['name']} ${h['city']} ${h['contact_email']}'.toLowerCase().contains(q))
              .toList();
          final statuses = [('ACTIVE', l.subActive), ('TRIAL', l.subTrial), ('PAST_DUE', l.subPastDue), ('SUSPENDED', l.subSuspended)];
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Reveal(
              index: 1,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                CountChip(label: l.all, count: list.length, selected: _status.isEmpty, onTap: () => setState(() => _status = '')),
                for (final (k, label) in statuses)
                  CountChip(
                      label: label,
                      count: list.where((h) => h['status'] == k).length,
                      selected: _status == k,
                      onTap: () => setState(() => _status = k)),
              ]),
            ),
            const SizedBox(height: 16),
            Reveal(
              index: 2,
              child: Glass(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: shown.isEmpty
                    ? EmptyState(icon: Icons.apartment_rounded, title: l.noHotels, body: l.noHotelsBody)
                    : Column(children: [
                        if (!context.isPhone) const _Header(),
                        for (final h in shown) _HotelRow(h: h),
                      ]),
              ),
            ),
          ]);
        },
      ),
    ]);
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = Theme.of(context).textTheme.labelMedium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(children: [
        Expanded(flex: 4, child: Text(l.hotel, style: st)),
        Expanded(flex: 2, child: Text(l.plan, style: st)),
        Expanded(flex: 2, child: Text(l.city, style: st)),
        Expanded(flex: 2, child: Text(l.tablesCol, style: st)),
        Expanded(flex: 2, child: Text(l.orders30d, style: st)),
        Expanded(flex: 2, child: Text(l.started, style: st)),
        Expanded(flex: 2, child: Text(l.status, style: st)),
      ]),
    );
  }
}

class _HotelRow extends ConsumerWidget {
  const _HotelRow({required this.h});
  final Map<String, dynamic> h;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final t = context.tokens;
    final name = Row(children: [
      Avatar(h['name'], size: 34),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h['name'], style: tt.titleSmall, overflow: TextOverflow.ellipsis),
          Text(h['contact_email'] ?? '', style: tt.labelSmall, overflow: TextOverflow.ellipsis),
        ]),
      ),
    ]);
    return InkWell(
      borderRadius: BorderRadius.circular(Rad.tile),
      hoverColor: t.accentSoft.withValues(alpha: .6),
      onTap: () async {
        await showGlassDialog(context, title: h['name'], maxWidth: 560, body: _HotelDetail(h: h));
        ref.invalidate(platformHotelsProvider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: context.isPhone
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                name,
                Padding(
                  padding: const EdgeInsets.only(left: 46, top: 6),
                  child: Row(children: [
                    hotelStatusChip(context, h['status']),
                    const SizedBox(width: 8),
                    Text(h['plan_name'] ?? '-', style: tt.bodySmall),
                  ]),
                ),
              ])
            : Row(children: [
                Expanded(flex: 4, child: name),
                Expanded(flex: 2, child: Text(h['plan_name'] ?? '-', style: tt.bodyMedium)),
                Expanded(flex: 2, child: Text(h['city'] ?? '–', style: tt.bodyMedium)),
                Expanded(flex: 2, child: Text('${h['tables']}', style: tt.bodyMedium)),
                Expanded(flex: 2, child: Text('${h['orders_30d']}', style: tt.bodyMedium)),
                Expanded(flex: 2, child: Text(DateFormat.yMMM().format(DateTime.parse(h['created_at'])), style: tt.bodyMedium)),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: hotelStatusChip(context, h['status']))),
              ]),
      ),
    );
  }
}

class _HotelDetail extends ConsumerStatefulWidget {
  const _HotelDetail({required this.h});
  final Map<String, dynamic> h;

  @override
  ConsumerState<_HotelDetail> createState() => _HotelDetailState();
}

class _HotelDetailState extends ConsumerState<_HotelDetail> {
  final _reason = TextEditingController();
  late String _plan = widget.h['plan_code'] ?? 'STARTER';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final h = widget.h;
    final plans = ref.watch(platformPlansProvider).value ?? const [];
    final suspended = h['status'] == 'SUSPENDED';
    final api = ref.read(apiProvider);
    final tt = Theme.of(context).textTheme;
    final trial = h['trial_ends_at'] == null ? null : DateTime.parse(h['trial_ends_at']).toLocal();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        hotelStatusChip(context, h['status']),
        const SizedBox(width: 10),
        if (trial != null && h['status'] == 'TRIAL') Text(l.trialEndsOn(DateFormat.yMMMd().format(trial)), style: tt.bodySmall),
      ]),
      FieldLabel(l.plan),
      ChoiceRow<String>(
        options: [for (final p in plans) (p['code'] as String, p['name'] as String)],
        value: _plan,
        onChanged: (v) => setState(() => _plan = v),
      ),
      FieldLabel(l.reason, help: l.reasonAuditedHelp),
      TextField(controller: _reason),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
        OutlinedButton(
          onPressed: () async {
            final ok = await guard(context,
                () => api.post('/api/v1/platform/hotels/${h['id']}/${suspended ? 'resume' : 'suspend'}', {'reason': _reasonText(l)}));
            if (ok && context.mounted) Navigator.of(context).pop();
          },
          child: Text(suspended ? l.resumeHotel : l.suspendHotel),
        ),
        OutlinedButton(
          onPressed: () => showGlassDialog(context, title: l.overrides, maxWidth: 560, body: _Overrides(hotelId: h['id'])),
          child: Text(l.overrides),
        ),
        FilledButton(
          onPressed: _plan == h['plan_code']
              ? null
              : () async {
                  final ok = await guard(
                      context,
                      () => api.post('/api/v1/platform/hotels/${h['id']}/subscription',
                          {'plan_code': _plan, 'reason': _reasonText(l)}));
                  if (ok && context.mounted) Navigator.of(context).pop();
                },
          child: Text(l.changePlan),
        ),
      ]),
    ]);
  }

  String _reasonText(AppLocalizations l) => _reason.text.trim().length >= 3 ? _reason.text.trim() : l.defaultReason;
}

class _Overrides extends ConsumerStatefulWidget {
  const _Overrides({required this.hotelId});
  final String hotelId;

  @override
  ConsumerState<_Overrides> createState() => _OverridesState();
}

class _OverridesState extends ConsumerState<_Overrides> {
  List<Map<String, dynamic>>? _rows;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = ((await ref.read(apiProvider).get('/api/v1/platform/hotels/${widget.hotelId}/overrides')) as List).cast<Map<String, dynamic>>();
    if (mounted) setState(() => _rows = r);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plans = ref.watch(platformPlansProvider).value ?? const [];
    if (_rows == null || plans.isEmpty) return const LoadingBlock(height: 160);
    final features = (plans.first['features'] as Map).keys.cast<String>().toList();
    final current = {for (final r in _rows!) r['feature_key']: r};
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.overridesHelp, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 8),
      for (final f in features)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(featureLabel(context, f)),
          subtitle: Text(current.containsKey(f) ? l.overridden : l.fromPlan),
          value: current[f]?['bool_value'] == true,
          onChanged: (v) async {
            await guard(
                context,
                () => ref.read(apiProvider).put('/api/v1/platform/hotels/${widget.hotelId}/overrides',
                    {'feature_key': f, 'bool_value': v, 'reason': l.defaultReason}));
            await _load();
          },
        ),
    ]);
  }
}

String featureLabel(BuildContext context, String key) {
  final l = AppLocalizations.of(context);
  return switch (key) {
    'QR_ORDERING' => l.featQr,
    'WAITER_ORDERING' => l.featWaiter,
    'CHEF_ACCEPT_MODE' => l.featChefAccept,
    'AUTO_ROUTING' => l.featAutoRouting,
    'ADMIN_PRINT_MODE' => l.featAdminPrint,
    'EXPENSES' => l.featExpenses,
    'CUSTOM_ROLES' => l.featCustomRoles,
    'REPORTS_ADVANCED' => l.featReports,
    'RATINGS' => l.featRatings,
    'API_WEBHOOKS' => l.featApi,
    'ROOMS' => l.featRooms,
    'MAX_OUTLETS' => l.limOutlets,
    'MAX_TABLES' => l.limTables,
    'MAX_STAFF' => l.limStaff,
    'MAX_CHEFS' => l.limChefs,
    'MAX_MENU_ITEMS' => l.limMenuItems,
    'MAX_ORDERS_PER_MONTH' => l.limOrders,
    _ => key,
  };
}

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm();

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _phone = TextEditingController();
  final _gstin = TextEditingController();
  final _adminName = TextEditingController();
  final _adminEmail = TextEditingController();
  final _adminPassword = TextEditingController();
  String _plan = 'STARTER';
  String _gst = 'UNREGISTERED';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plans = ref.watch(platformPlansProvider).value ?? const [];
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.hotelName),
        TextFormField(controller: _name, validator: (v) => (v ?? '').trim().length < 2 ? l.errRequired : null),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [FieldLabel(l.city), TextFormField(controller: _city)])),
          const SizedBox(width: 10),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FieldLabel(l.phoneOptional),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone),
          ])),
        ]),
        FieldLabel(l.plan, help: l.trialHelp),
        ChoiceRow<String>(
          options: [for (final p in plans.where((p) => p['is_active'] == true)) (p['code'] as String, p['name'] as String)],
          value: _plan,
          onChanged: (v) => setState(() => _plan = v),
        ),
        FieldLabel(l.gstRegistration),
        ChoiceRow<String>(
          options: [('REGULAR', l.gstRegular), ('COMPOSITION', l.gstComposition), ('UNREGISTERED', l.gstUnregistered)],
          value: _gst,
          onChanged: (v) => setState(() => _gst = v),
        ),
        if (_gst != 'UNREGISTERED') ...[
          FieldLabel(l.gstin),
          TextFormField(
            controller: _gstin,
            textCapitalization: TextCapitalization.characters,
            validator: (v) => RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$').hasMatch((v ?? '').trim().toUpperCase())
                ? null
                : l.errGstin,
          ),
        ],
        const SizedBox(height: 14),
        Text(l.hotelAdmin, style: Theme.of(context).textTheme.titleMedium),
        FieldLabel(l.name),
        TextFormField(controller: _adminName, validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null),
        FieldLabel(l.email),
        TextFormField(controller: _adminEmail, validator: (v) => (v ?? '').contains('@') ? null : l.errEmail),
        FieldLabel(l.tempPassword, help: l.tempPasswordHelp),
        TextFormField(controller: _adminPassword, validator: (v) => (v ?? '').length < 8 ? l.errPasswordLength : null),
        DialogActions(
          primary: l.registerHotel,
          busy: _busy,
          onPrimary: () async {
            if (!_form.currentState!.validate()) return;
            setState(() => _busy = true);
            final ok = await guard(
              context,
              () => ref.read(apiProvider).post('/api/v1/platform/hotels', {
                'name': _name.text.trim(),
                if (_city.text.trim().isNotEmpty) 'city': _city.text.trim(),
                if (_phone.text.trim().isNotEmpty) 'contact_phone': _phone.text.trim(),
                'plan_code': _plan,
                'gst_registration': _gst,
                if (_gst != 'UNREGISTERED') 'gstin': _gstin.text.trim().toUpperCase(),
                'admin': {'name': _adminName.text.trim(), 'email': _adminEmail.text.trim(), 'password': _adminPassword.text},
              }),
            );
            if (!mounted) return;
            setState(() => _busy = false);
            if (ok) {
              Navigator.of(this.context).pop();
              showDone(this.context, l.hotelRegistered);
            }
          },
        ),
      ]),
    );
  }
}
