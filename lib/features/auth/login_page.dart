import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/auth/session.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/components.dart';
import '../../ui/feedback.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).login(_email.text.trim(), _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = errorText(context, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = context.tokens;
    final tt = Theme.of(context).textTheme;
    final form = Glass(
      strong: true,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 22),
      child: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Text(l.signInTitle, style: tt.displaySmall),
            const SizedBox(height: 6),
            Text(l.signInSubtitle, style: tt.bodyMedium?.copyWith(color: t.dim)),
            const SizedBox(height: 18),
            FieldLabel(l.email),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || !v.contains('@')) ? l.errEmail : null,
            ),
            FieldLabel(l.password),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              validator: (v) => (v == null || v.isEmpty) ? l.errRequired : null,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  tooltip: _obscure ? l.showPassword : l.hidePassword,
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            AnimatedSize(
              duration: Motion.fast,
              child: _error == null
                  ? const SizedBox(height: 18)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(children: [
                        Icon(Icons.error_outline, size: 18, color: t.danger),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: tt.bodyMedium?.copyWith(color: t.danger))),
                      ]),
                    ),
            ),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: t.onNight))
                  : Text(l.signIn),
            ),
          ]),
        ),
      ),
    );

    final hero = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(l.appName, style: tt.titleLarge?.copyWith(color: t.accentDeep)),
      const SizedBox(height: 10),
      Text(l.loginHeadline, style: context.isPhone ? tt.displaySmall : tt.displayLarge),
      const SizedBox(height: 22),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final (icon, label) in [
          (Icons.qr_code_2_rounded, l.loginPointQr),
          (Icons.soup_kitchen_outlined, l.loginPointKitchen),
          (Icons.insights_outlined, l.loginPointDashboards),
        ])
          StatusChip(icon: icon, label: label, color: t.accentDeep),
      ]),
    ]);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.gutter),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: context.width < 900
                    ? Column(children: [
                        Reveal(index: 0, child: hero),
                        const SizedBox(height: 26),
                        Reveal(index: 1, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: form)),
                      ])
                    : Row(children: [
                        Expanded(child: Reveal(index: 0, child: hero)),
                        const SizedBox(width: 48),
                        SizedBox(width: 420, child: Reveal(index: 1, child: form)),
                      ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
