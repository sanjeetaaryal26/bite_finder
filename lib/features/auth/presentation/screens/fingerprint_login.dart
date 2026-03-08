import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';

class FingerprintLogin extends StatefulWidget {
  const FingerprintLogin({super.key});

  @override
  State<FingerprintLogin> createState() => _FingerprintLoginState();
}

class _FingerprintLoginState extends State<FingerprintLogin> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    var authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        persistAcrossBackgrounding: true,
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on LocalAuthException catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      if (e.code != LocalAuthExceptionCode.userCanceled && e.code != LocalAuthExceptionCode.systemCanceled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.code.name}${e.description != null ? ' (${e.description})' : ''}'),
          ),
        );
      }
      return;
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected authentication error: ${e.message ?? 'unknown'}')),
      );
      return;
    }
    if (!mounted) {
      return;
    }
    if (authenticated) {
      // After successful biometric auth, navigate according to current login state.
      if (!mounted) return;
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      // Mark that biometric unlock passed so router won't immediately return
      // back to the fingerprint screen.
      authVm.setFingerprintUnlocked(true);

      if (authVm.isLoggedIn) {
        // If already logged in, go to admin/home accordingly.
        if (authVm.isAdmin) {
          context.go('/admin');
        } else {
          context.go('/home');
        }
      } else {
        // If not logged in, send user to the login screen (they've unlocked the app).
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = width < 360 ? 22.0 : 28.0;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                        ),
                        const SizedBox(height: 28),
                        InkWell(
                          onTap: _isAuthenticating ? null : _authenticate,
                          borderRadius: BorderRadius.circular(1200),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 2, color: Colors.black45),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(1200),
                              child: Image.asset(
                                'assets/images/fingerprint-icon.jpg',
                                fit: BoxFit.cover,
                                height: 120,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Use your fingerprint to unlock the app',
                          style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if (_isAuthenticating) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(strokeWidth: 2),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
