import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/auth_gradient_shell.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGradientShell(
      title: '',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final logoWidth = (constraints.maxWidth * 0.82).clamp(230.0, 360.0);
                return Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: logoWidth,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            const SizedBox(height: 38),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go('/login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7D1115),
                    ),
                    child: const Text('Log in'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.go('/register'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7D1115),
                    ),
                    child: const Text('Sign up'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
