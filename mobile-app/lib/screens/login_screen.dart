import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../core/app_theme.dart';
import '../data/remote/api_exception.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_selector.dart';

/// Phone OTP sign-in, with a password fallback for administration accounts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  final _employeeId = TextEditingController();
  final _password = TextEditingController();
  bool _otpSent = false;
  bool _passwordMode = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _employeeId.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final l = AppLocalizations.of(context);
    if (_phone.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      _show(l.mobileNumberInvalid);
      return;
    }
    final ok =
        await AppScope.of(context).sessionController.requestOtp(_phone.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _otpSent = true);
      _show(l.otpSent);
    } else {
      _show(_failureMessage(l, AppScope.of(context).sessionController.failure));
    }
  }

  Future<void> _verifyOtp() async {
    final d = AppScope.of(context);
    final l = AppLocalizations.of(context);
    if (_otp.text.trim().length < 4) {
      _show(l.otpInvalid);
      return;
    }
    final ok = await d.sessionController
        .signInWithOtp(phoneNumber: _phone.text, otp: _otp.text);
    if (!mounted) return;
    if (ok) {
      await d.taskController.load();
    } else {
      _show(_failureMessage(l, d.sessionController.failure));
    }
  }

  Future<void> _passwordSignIn() async {
    final d = AppScope.of(context);
    final l = AppLocalizations.of(context);
    final ok = await d.sessionController
        .signIn(employeeId: _employeeId.text, password: _password.text);
    if (!mounted) return;
    if (ok) {
      await d.taskController.load();
    } else {
      _show(_failureMessage(l, d.sessionController.failure));
    }
  }

  void _show(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final d = AppScope.of(context);
    final l = AppLocalizations.of(context);
    return Scaffold(
        body: SafeArea(
            child: ListenableBuilder(
      listenable: d.sessionController,
      builder: (context, child) {
        final busy = d.sessionController.busy;
        return Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _TricolourBanner(),
                        const SizedBox(height: 26),
                        Text(l.loginHeader,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.navy)),
                        const SizedBox(height: 6),
                        Text(l.appTagline, textAlign: TextAlign.center),
                        const SizedBox(height: 28),
                        SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                  value: false,
                                  label: Text(l.mobileOtpTab),
                                  icon: const Icon(Icons.phone_android)),
                              ButtonSegment(
                                  value: true,
                                  label: Text(l.employeeLoginTab),
                                  icon: const Icon(Icons.badge_outlined))
                            ],
                            selected: {
                              _passwordMode
                            },
                            onSelectionChanged: busy
                                ? null
                                : (v) =>
                                    setState(() => _passwordMode = v.first)),
                        const SizedBox(height: 22),
                        if (!_passwordMode) ...[
                          Text(l.mobileOtpHint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 16),
                          TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumber
                              ],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+ -]'))
                              ],
                              decoration: InputDecoration(
                                  labelText: l.mobileNumberLabel,
                                  hintText: '+91 98765 43210',
                                  prefixIcon:
                                      const Icon(Icons.phone_outlined))),
                          const SizedBox(height: 16),
                          if (_otpSent) ...[
                            TextField(
                                controller: _otp,
                                keyboardType: TextInputType.number,
                                autofillHints: const [
                                  AutofillHints.oneTimeCode
                                ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6)
                                ],
                                onSubmitted: (_) => _verifyOtp(),
                                decoration: InputDecoration(
                                    labelText: l.otpLabel,
                                    hintText: '••••••',
                                    prefixIcon:
                                        const Icon(Icons.lock_outline))),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                                onPressed: busy ? null : _verifyOtp,
                                icon: const Icon(Icons.verified_user_outlined),
                                label: Text(
                                    busy ? l.verifyingOtp : l.verifyOtpAction)),
                            TextButton(
                                onPressed: busy ? null : _requestOtp,
                                child: Text(l.resendOtpAction)),
                          ] else
                            FilledButton.icon(
                                onPressed: busy ? null : _requestOtp,
                                icon: const Icon(Icons.sms_outlined),
                                label: Text(
                                    busy ? l.sendingOtp : l.sendOtpAction)),
                          const SizedBox(height: 12),
                          Text(l.otpAutofillNote,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () async {
                                    await d.sessionController.signInForDemo();
                                    if (!context.mounted) return;
                                    await d.taskController.load();
                                  },
                            icon: const Icon(Icons.play_circle_outline),
                            label: Text(l.viewDemoAction),
                          ),
                          Text(l.demoLoginNote,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                        ] else ...[
                          TextField(
                              controller: _employeeId,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  labelText: l.employeeIdLabel,
                                  hintText: 'SW-102',
                                  prefixIcon:
                                      const Icon(Icons.badge_outlined))),
                          const SizedBox(height: 16),
                          TextField(
                              controller: _password,
                              obscureText: true,
                              onSubmitted: (_) => _passwordSignIn(),
                              decoration: InputDecoration(
                                  labelText: l.passwordLabel,
                                  prefixIcon: const Icon(Icons.lock_outline))),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                              onPressed: busy ? null : _passwordSignIn,
                              icon: const Icon(Icons.login),
                              label: Text(
                                  busy ? l.signingInAction : l.signInAction)),
                        ],
                        const SizedBox(height: 24),
                        const Center(child: LanguageSelector()),
                      ]),
                )));
      },
    )));
  }
}

class _TricolourBanner extends StatelessWidget {
  const _TricolourBanner();
  @override
  Widget build(BuildContext context) => Container(
        height: 176,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppTheme.navy,
        ),
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.saffron,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.indiaGreen,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: -22,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .12),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 22,
            child: Row(children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FF),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withValues(alpha: .14),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.volunteer_activism_rounded,
                    color: AppTheme.navy, size: 36),
              ),
              const SizedBox(width: 14),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('தமிழ்நாடு',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('FIELD WORKER SERVICES',
                        style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70)),
                  ]),
            ]),
          ),
        ]),
      );
}

String _failureMessage(AppLocalizations l10n, ApiException? failure) =>
    switch (failure?.failure) {
      null => l10n.genericError,
      ApiFailure.unauthorized || ApiFailure.badRequest => l10n.loginFailed,
      ApiFailure.network || ApiFailure.timeout => l10n.loginRequiresConnection,
      _ => l10n.genericError,
    };
