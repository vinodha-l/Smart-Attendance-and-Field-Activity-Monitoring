import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../state/session_controller.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Shows the login screen or the worker home, depending on the session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return ListenableBuilder(
      listenable: deps.sessionController,
      builder: (BuildContext context, Widget? child) =>
          switch (deps.sessionController.status) {
        AuthStatus.unknown => const _Splash(),
        AuthStatus.signedOut => const LoginScreen(),
        AuthStatus.signedIn => const HomeShell(),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
