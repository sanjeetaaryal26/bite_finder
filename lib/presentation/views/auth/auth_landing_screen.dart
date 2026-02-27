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
            const SizedBox(height: 26),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bite',
                style: TextStyle(
                  color: Color(0xFFF6C94D),
                  fontSize: 76,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 84),
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
