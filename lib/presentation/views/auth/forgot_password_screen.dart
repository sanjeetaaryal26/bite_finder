import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../widgets/auth_gradient_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('If this email exists, a reset link was sent.')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return AuthGradientShell(
      title: 'Forget password',
      showBack: true,
      onBack: () => context.go('/login'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8E191D)),
                child: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
