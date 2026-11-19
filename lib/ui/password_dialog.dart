import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/auth/session.dart';
import '../l10n/app_localizations.dart';
import 'components.dart';
import 'feedback.dart';

/// Change your own password (profile menu). Stays open on a mistake so it can be corrected.
Future<void> showChangePasswordDialog(BuildContext context) {
  return showGlassDialog(context, title: AppLocalizations.of(context).changePassword, body: const _ChangePasswordForm());
}

class _ChangePasswordForm extends ConsumerStatefulWidget {
  const _ChangePasswordForm();

  @override
  ConsumerState<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<_ChangePasswordForm> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _again = TextEditingController();
  bool _busy = false;
  String? _problem;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() => _problem = null);
    if (_next.text.length < 8) return setState(() => _problem = l.errPasswordLength);
    if (_next.text != _again.text) return setState(() => _problem = l.passwordsDontMatch);
    setState(() => _busy = true);
    final ok = await guard(context, () => ref.read(apiProvider).changePassword(_current.text, _next.text));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showDone(context, l.passwordChanged);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AutofillGroup(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(l.currentPassword),
        TextField(
          controller: _current,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
        ),
        FieldLabel(l.newPassword, help: l.errPasswordLength),
        TextField(controller: _next, obscureText: true, autofillHints: const [AutofillHints.newPassword]),
        FieldLabel(l.confirmNewPassword),
        TextField(controller: _again, obscureText: true, onSubmitted: (_) => _submit()),
        if (_problem != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_problem!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        DialogActions(primary: l.changePassword, busy: _busy, onPrimary: _submit),
      ]),
    );
  }
}

/// Admin sets a new password for a staff member who forgot theirs.
Future<void> showResetPasswordDialog(BuildContext context, Map<String, dynamic> user) {
  return showGlassDialog(
    context,
    title: AppLocalizations.of(context).resetPasswordFor(user['name'] as String),
    body: _ResetPasswordForm(user: user),
  );
}

class _ResetPasswordForm extends ConsumerStatefulWidget {
  const _ResetPasswordForm({required this.user});
  final Map<String, dynamic> user;

  @override
  ConsumerState<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<_ResetPasswordForm> {
  final _next = TextEditingController();
  bool _busy = false;
  String? _problem;

  @override
  void dispose() {
    _next.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_next.text.length < 8) return setState(() => _problem = l.errPasswordLength);
    setState(() => _busy = true);
    final ok = await guard(
        context, () => ref.read(apiProvider).post('/api/v1/users/${widget.user['id']}/password', {'new_password': _next.text}));
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showDone(context, l.passwordResetDone(widget.user['name'] as String));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.resetPasswordHelp, style: Theme.of(context).textTheme.bodySmall),
      FieldLabel(l.newPassword, help: l.errPasswordLength),
      TextField(controller: _next, obscureText: true, onSubmitted: (_) => _submit()),
      if (_problem != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(_problem!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      DialogActions(primary: l.resetPassword, busy: _busy, onPrimary: _submit),
    ]);
  }
}
