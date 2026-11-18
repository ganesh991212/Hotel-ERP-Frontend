import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';
import '../../ui/shell.dart';
import '../../ui/status.dart';

final _usersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) async => ((await ref.read(apiProvider).get('/api/v1/users')) as List).cast<Map<String, dynamic>>());
final _rolesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) async => ((await ref.read(apiProvider).get('/api/v1/roles')) as List).cast<Map<String, dynamic>>());
final _permsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
    (ref) async => ((await ref.read(apiProvider).get('/api/v1/permissions')) as List).cast<Map<String, dynamic>>());

class TeamPage extends ConsumerStatefulWidget {
  const TeamPage({super.key});

  @override
  ConsumerState<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends ConsumerState<TeamPage> {
  String _view = 'people';
  String _role = '';
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(sessionProvider).value!;
    final users = ref.watch(_usersProvider);
    final roles = ref.watch(_rolesProvider);
    return PageBody(children: [
      Reveal(
        index: 0,
        child: PageHeading(_view == 'people' ? l.tabTeam : l.rolesAndAccess, actions: [
          PillTabs<String>(
            items: [('people', l.people), ('roles', l.rolesAndAccess)],
            selected: _view,
            onSelect: (v) => setState(() => _view = v),
          ),
          if (_view == 'people') ...[
            SizedBox(
              width: context.isPhone ? double.infinity : 260,
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchPeople),
              ),
            ),
            FilledButton.icon(
              onPressed: () => roles.whenData((r) => _addMember(context, r)),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.addMember),
            ),
          ] else if (s.can('role.manage'))
            OutlinedButton.icon(
              onPressed: s.feature('CUSTOM_ROLES') ? () => _addRole(context) : null,
              icon: Icon(s.feature('CUSTOM_ROLES') ? Icons.add_rounded : Icons.lock_outline, size: 18),
              label: Text(s.feature('CUSTOM_ROLES') ? l.newRole : l.newRoleLocked),
            ),
        ]),
      ),
      AnimatedSwitcher(
        duration: Motion.medium,
        switchInCurve: Motion.ease,
        child: _view == 'people'
            ? KeyedSubtree(key: const ValueKey('people'), child: _people(context, users, roles))
            : KeyedSubtree(key: const ValueKey('roles'), child: _RolesMatrix(canEdit: s.can('role.manage'))),
      ),
    ]);
  }

  Widget _people(BuildContext context, AsyncValue<List<Map<String, dynamic>>> users,
      AsyncValue<List<Map<String, dynamic>>> roles) {
    final l = AppLocalizations.of(context);
    return users.when(
      loading: () => const LoadingBlock(),
      error: (e, _) => EmptyState(icon: Icons.cloud_off_rounded, title: errorText(context, e)),
      data: (list) {
        final q = _search.text.trim().toLowerCase();
        final codes = <String>{for (final u in list) u['role_code'] ?? ''};
        final shown = list
            .where((u) => _role.isEmpty || u['role_code'] == _role)
            .where((u) =>
                q.isEmpty ||
                (u['name'] as String).toLowerCase().contains(q) ||
                (u['role_name'] ?? '').toString().toLowerCase().contains(q))
            .toList();
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Reveal(
            index: 1,
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              CountChip(label: l.all, count: list.length, selected: _role.isEmpty, onTap: () => setState(() => _role = '')),
              for (final c in codes.where((c) => c.isNotEmpty))
                CountChip(
                  label: roleLabel(context, c, list.firstWhere((u) => u['role_code'] == c)['role_name']),
                  count: list.where((u) => u['role_code'] == c).length,
                  selected: _role == c,
                  onTap: () => setState(() => _role = c),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          Reveal(
            index: 2,
            child: Glass(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Column(children: [
                if (!context.isPhone) const _PeopleHeader(),
                for (final u in shown) _PersonRow(user: u, roles: roles.value ?? const []),
              ]),
            ),
          ),
        ]);
      },
    );
  }

  Future<void> _addMember(BuildContext context, List<Map<String, dynamic>> roles) async {
    await showGlassDialog(context, title: AppLocalizations.of(context).addMember, body: _MemberForm(roles: roles));
    ref.invalidate(_usersProvider);
  }

  Future<void> _addRole(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final name = TextEditingController();
    await showGlassDialog(
      context,
      title: l.newRole,
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.name, help: l.newRoleHelp),
        TextField(controller: name, autofocus: true),
        Builder(
          builder: (ctx) => DialogActions(
            primary: l.save,
            onPrimary: () async {
              final ok = await guard(
                  ctx, () => ref.read(apiProvider).post('/api/v1/roles', {'name': name.text.trim(), 'permissions': []}));
              if (ok && ctx.mounted) {
                ref.invalidate(_rolesProvider);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ),
      ]),
    );
  }
}

class _PeopleHeader extends StatelessWidget {
  const _PeopleHeader();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = Theme.of(context).textTheme.labelMedium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(children: [
        Expanded(flex: 4, child: Text(l.name, style: st)),
        Expanded(flex: 3, child: Text(l.role, style: st)),
        Expanded(flex: 4, child: Text(l.email, style: st)),
        Expanded(flex: 2, child: Text(l.phone, style: st)),
        Expanded(flex: 2, child: Text(l.status, style: st)),
        const SizedBox(width: 40),
      ]),
    );
  }
}

class _PersonRow extends ConsumerStatefulWidget {
  const _PersonRow({required this.user, required this.roles});
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> roles;

  @override
  ConsumerState<_PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends ConsumerState<_PersonRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final u = widget.user;
    final active = u['status'] == 'ACTIVE';
    final status = !active
        ? StatusChip(icon: Icons.block, label: l.disabled, color: t.faint)
        : u['on_shift'] == true
            ? StatusChip(icon: Icons.circle, label: l.onShift, color: t.ok)
            : u['on_shift'] == false
                ? StatusChip(icon: Icons.circle_outlined, label: l.offShift, color: t.warn)
                : StatusChip(icon: Icons.circle, label: l.active, color: t.ok);
    final menu = PopupMenuButton<String>(
      tooltip: l.more,
      color: t.solid,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) async {
        final api = ref.read(apiProvider);
        if (v == 'toggle') {
          await guard(context, () => api.patch('/api/v1/users/${u['id']}', {'status': active ? 'DISABLED' : 'ACTIVE'}));
        } else {
          await guard(context, () => api.patch('/api/v1/users/${u['id']}', {'role_id': v}));
        }
        ref.invalidate(_usersProvider);
      },
      itemBuilder: (_) => [
        for (final r in widget.roles.where((r) => r['id'] != u['role_id']))
          PopupMenuItem(value: r['id'] as String, child: Text(l.makeRole(roleLabel(context, r['code'], r['name'])))),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'toggle', child: Text(active ? l.disableAccount : l.enableAccount)),
      ],
    );
    final name = Row(children: [
      Avatar(u['name'], size: 34),
      const SizedBox(width: 12),
      Expanded(child: Text(u['name'], style: tt.titleSmall, overflow: TextOverflow.ellipsis)),
    ]);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Motion.fast,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _hover ? t.accentSoft.withValues(alpha: .7) : Colors.transparent,
          borderRadius: BorderRadius.circular(Rad.tile),
        ),
        child: context.isPhone
            ? Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    name,
                    Padding(
                      padding: const EdgeInsets.only(left: 46, top: 2),
                      child: Text('${roleLabel(context, u['role_code'], u['role_name'])} · ${u['email']}',
                          style: tt.bodySmall, overflow: TextOverflow.ellipsis),
                    ),
                    Padding(padding: const EdgeInsets.only(left: 46, top: 6), child: status),
                  ]),
                ),
                menu,
              ])
            : Row(children: [
                Expanded(flex: 4, child: name),
                Expanded(flex: 3, child: Text(roleLabel(context, u['role_code'], u['role_name']), style: tt.bodyMedium)),
                Expanded(flex: 4, child: Text(u['email'], style: tt.bodyMedium, overflow: TextOverflow.ellipsis)),
                Expanded(flex: 2, child: Text(u['phone'] ?? '–', style: tt.bodyMedium)),
                Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: status)),
                menu,
              ]),
      ),
    );
  }
}

class _MemberForm extends ConsumerStatefulWidget {
  const _MemberForm({required this.roles});
  final List<Map<String, dynamic>> roles;

  @override
  ConsumerState<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends ConsumerState<_MemberForm> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  late String _role = (widget.roles.firstWhere((r) => r['code'] == 'WAITER', orElse: () => widget.roles.first))['id'];
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final quick = widget.roles.where((r) => ['CHEF', 'WAITER', 'CASHIER', 'MANAGER'].contains(r['code'])).toList();
    return Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.role),
        ChoiceRow<String>(
          options: [for (final r in quick) (r['id'] as String, roleLabel(context, r['code'], r['name']))],
          value: _role,
          onChanged: (v) => setState(() => _role = v),
        ),
        if (widget.roles.length > quick.length) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _role,
            items: [
              for (final r in widget.roles)
                DropdownMenuItem(value: r['id'] as String, child: Text(roleLabel(context, r['code'], r['name']))),
            ],
            onChanged: (v) => setState(() => _role = v!),
          ),
        ],
        FieldLabel(l.name),
        TextFormField(controller: _name, validator: (v) => (v ?? '').trim().isEmpty ? l.errRequired : null),
        FieldLabel(l.email, help: l.emailLoginHelp),
        TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v ?? '').contains('@') ? null : l.errEmail),
        FieldLabel(l.phoneOptional),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone),
        FieldLabel(l.tempPassword, help: l.tempPasswordHelp),
        TextFormField(controller: _password, validator: (v) => (v ?? '').length < 8 ? l.errPasswordLength : null),
        DialogActions(
          primary: l.sendInvite,
          busy: _busy,
          onPrimary: () async {
            if (!_form.currentState!.validate()) return;
            setState(() => _busy = true);
            final ok = await guard(
                context,
                () => ref.read(apiProvider).post('/api/v1/users', {
                      'name': _name.text.trim(),
                      'email': _email.text.trim(),
                      if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
                      'password': _password.text,
                      'role_id': _role,
                    }));
            if (!mounted) return;
            setState(() => _busy = false);
            if (ok) Navigator.of(this.context).pop();
          },
        ),
      ]),
    );
  }
}

/// Permission matrix: rows are capabilities, columns are roles. The hotel admin column is locked.
class _RolesMatrix extends ConsumerWidget {
  const _RolesMatrix({required this.canEdit});
  final bool canEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final roles = ref.watch(_rolesProvider);
    final perms = ref.watch(_permsProvider);
    if (roles.isLoading || perms.isLoading) return const LoadingBlock();
    final rs = roles.value ?? const [];
    final ps = perms.value ?? const [];
    return Reveal(
      index: 1,
      child: Glass(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: tt.labelMedium,
            dataTextStyle: tt.bodyMedium,
            dividerThickness: .6,
            columnSpacing: 22,
            columns: [
              DataColumn(label: Text(l.permission)),
              for (final r in rs)
                DataColumn(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(roleLabel(context, r['code'], r['name'])),
                    if (r['locked'] == true) ...[
                      const SizedBox(width: 4),
                      Tooltip(message: l.adminLocked, child: Icon(Icons.lock_outline, size: 14, color: t.faint)),
                    ],
                  ]),
                ),
            ],
            rows: [
              for (final p in ps)
                DataRow(cells: [
                  DataCell(ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(permissionLabel(context, p['key']), style: tt.titleSmall),
                      Text(p['key'], style: tt.labelSmall),
                    ]),
                  )),
                  for (final r in rs)
                    DataCell(Checkbox(
                      value: (r['permissions'] as List).contains(p['key']),
                      semanticLabel: '${roleLabel(context, r['code'], r['name'])}: ${permissionLabel(context, p['key'])}',
                      onChanged: !canEdit || r['locked'] == true
                          ? null
                          : (v) => guard(context, () async {
                                final set = Set<String>.from(r['permissions']);
                                v == true ? set.add(p['key']) : set.remove(p['key']);
                                await ref
                                    .read(apiProvider)
                                    .put('/api/v1/roles/${r['id']}/permissions', {'permissions': set.toList()});
                                ref.invalidate(_rolesProvider);
                              }),
                    )),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

String permissionLabel(BuildContext context, String key) {
  final l = AppLocalizations.of(context);
  return switch (key) {
    'dashboard.view' => l.permDashboard,
    'order.view' => l.permOrderView,
    'order.create' => l.permOrderCreate,
    'order.confirm' => l.permOrderConfirm,
    'order.serve' => l.permOrderServe,
    'order.cancel' => l.permOrderCancel,
    'kitchen.cook' => l.permKitchenCook,
    'kitchen.manage' => l.permKitchenManage,
    'table.manage' => l.permTableManage,
    'menu.manage' => l.permMenuManage,
    'menu.availability' => l.permMenuAvailability,
    'staff.manage' => l.permStaffManage,
    'role.manage' => l.permRoleManage,
    'expense.view' => l.permExpenseView,
    'expense.manage' => l.permExpenseManage,
    'report.view' => l.permReportView,
    'settings.manage' => l.permSettingsManage,
    _ => key,
  };
}
