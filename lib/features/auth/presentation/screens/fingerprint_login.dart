import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class FingerprintLogin extends StatefulWidget {
  const FingerprintLogin({super.key});

  @override
  State<FingerprintLogin> createState() => _FingerprintLoginState();
}

class _FingerprintLoginState extends State<FingerprintLogin> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(
            () => _supportState = isSupported
                ? _SupportState.supported
                : _SupportState.unsupported,
          ),
        );
  }

  Future<void> _authenticate() async {
    var authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        persistAcrossBackgrounding: true,
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on LocalAuthException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        if (e.code != LocalAuthExceptionCode.userCanceled &&
            e.code != LocalAuthExceptionCode.systemCanceled) {
          _authorized =
              'Error - ${e.code.name}${e.description != null ? ': ${e.description}' : ''}';
        }
      });
      return;
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Unexpected error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');

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
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            "assets/images/logo.png",
            height: 100,
          ),
          InkWell(
            onTap: _authenticate,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.black45)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(1200),
                child: Image.asset(
                  "assets/images/fingerprint-icon.jpg",
                  fit: BoxFit.cover,
                  height: 120,
                ),
              ),
            ),
          ),
          Text(
            "Use your fingerprint to unlock the app",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )
        ],
      )),
    );
  }
}
