import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth_gradient_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();
    final success = await vm.login(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;

    if (success) {
      context.go(vm.isAdmin ? '/admin' : '/home');
    } else if (vm.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return AuthGradientShell(
      title: 'Log in to your\naccount',
      showBack: true,
      onBack: () => context.go('/auth'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: vm.isLoading ? null : _submit,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8E191D)),
                child: vm.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Log in'),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text(
                'Forget password',
                style: TextStyle(color: Color(0xFFF4DDDF)),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Do you have any account?',
              style: TextStyle(color: Color(0xFFF4DDDF), fontSize: 14),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
