import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:birdle/features/profile/presentation/widgets/profile_editor_dialog.dart';
import 'package:birdle/core/widgets/state_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loaded = false;
  bool _fingerprintEnabled = false;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _lastMagnitude = 0.0;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const double _gravity = 9.80665;
  // Threshold in m/s^2 for gravity-compensated acceleration to consider a shake.
  static const double _shakeThreshold = 3.0;
  // Minimum time between shake detections.
  static const int _shakeCooldownMs = 1000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().load(userId);
    });
    // initialize fingerprint switch state
    final authVm = context.read<AuthViewModel>();
    setState(() {
      _fingerprintEnabled = authVm.fingerprintEnabledUserId == userId;
    });
  }

  @override
  void initState() {
    super.initState();
    // Start listening to accelerometer events to detect shakes.
    _accelSub = accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    // Remove gravity to get linear acceleration magnitude
    final linearAccel = (magnitude - _gravity).abs();
    _lastMagnitude = magnitude;
    final now = DateTime.now();
    if (kDebugMode) {
      debugPrint(
          'Accel magnitude: ${magnitude.toStringAsFixed(2)}, linear: ${linearAccel.toStringAsFixed(2)}');
    }
    if (linearAccel > _shakeThreshold &&
        now.difference(_lastShakeAt).inMilliseconds > _shakeCooldownMs) {
      if (kDebugMode)
        debugPrint(
            'Shake detected (linearAccel=${linearAccel.toStringAsFixed(2)})');
      _lastShakeAt = now;
      _handleShake();
    }
  }

  Future<void> _handleShake() async {
    // Call the same logout flow as the logout button.
    final authVm = context.read<AuthViewModel>();
    await authVm.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final user = authVm.currentUser!;
    final hasPhoto = user.photoPath != null && user.photoPath!.trim().isNotEmpty;
    ImageProvider<Object>? photoProvider;
    if (hasPhoto) {
      if (user.photoPath!.startsWith('http://') || user.photoPath!.startsWith('https://')) {
        photoProvider = NetworkImage(user.photoPath!);
      } else {
        photoProvider = FileImage(File(user.photoPath!));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileVm.isLoading &&
              profileVm.recentSearches.isEmpty &&
              profileVm.reviews.isEmpty
          ? const LoadingState()
          : profileVm.error != null
              ? ErrorState(message: profileVm.error!)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundImage: photoProvider,
                              child: hasPhoto ? null : const Icon(Icons.person, size: 42),
                            ),
                            const SizedBox(height: 10),
                            Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                            Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            Text(
                              'Role: ${user.role.name.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'Joined: ${user.createdAt.split('T').first}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: authVm.isLoading
                                    ? null
                                    : () async {
                                        final updated = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => ProfileEditorDialog(
                                            user: user,
                                            onSave: ({
                                              required String name,
                                              required String email,
                                              String? photoPath,
                                              bool removePhoto = false,
                                            }) =>
                                                authVm.updateProfile(
                                              name: name,
                                              email: email,
                                              photoPath: photoPath,
                                              removePhoto: removePhoto,
                                            ),
                                          ),
                                        );
                                        if (!mounted || updated != true) {
                                          return;
                                        }
                                        final userId = authVm.currentUser!.id;
                                        await profileVm.load(userId);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Profile updated')),
                                        );
                                      },
                                icon: const Icon(Icons.edit_outlined),
                                label: const Text('Edit Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Recent Searches',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (profileVm.recentSearches.isEmpty)
                      const Text('No searches yet')
                    else
                      ...profileVm.recentSearches.map((s) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.search),
                            title: Text(s.query),
                            subtitle: Text(s.createdAt.split('T').first),
                          )),
                    const Divider(height: 28),
                    Text('Reviews Given',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (profileVm.reviews.isEmpty)
                      const Text('No reviews yet')
                    else
                      ...profileVm.reviews.map((r) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                                CircleAvatar(child: Text(r.rating.toString())),
                            title: Text(r.comment),
                            subtitle: Text(r.createdAt.split('T').first),
                          )),
                    const SizedBox(height: 20),
                    if (authVm.isAdmin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FilledButton.tonalIcon(
                          onPressed: () => context.push('/admin'),
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: const Text('Open Admin Panel'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _fingerprintEnabled,
                      title: const Text('Enable fingerprint login'),
                      subtitle:
                          const Text('Use fingerprint to login next time'),
                      onChanged: (val) async {
                        final authVmLocal = context.read<AuthViewModel>();
                        final user = authVmLocal.currentUser!;
                        if (val) {
                          // enabling: ask for password to store and require local biometric auth
                          final passwordController = TextEditingController();
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirm Password'),
                              content: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Continue')),
                              ],
                            ),
                          );
                          if (ok != true) return;
                          final password = passwordController.text;
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Password required')));
                            return;
                          }
                          // Verify password before registering fingerprint
                          final loginSuccess = await authVmLocal.login(
                              email: user.email, password: password);
                          if (!loginSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Password is incorrect')));
                            return;
                          }
                          final localAuth = LocalAuthentication();
                          try {
                            final didAuth = await localAuth.authenticate(
                                localizedReason:
                                    'Confirm fingerprint to enable login',
                                persistAcrossBackgrounding: true);
                            if (!didAuth) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Biometric authentication failed')));
                              return;
                            }
                            // store credentials securely
                            final storage = const FlutterSecureStorage();
                            final key = 'fingerprint_credentials_' + user.id;
                            final value = json.encode(
                                {'email': user.email, 'password': password});
                            await storage.write(key: key, value: value);
                            await authVmLocal
                                .setFingerprintEnabledForUser(user.id);
                            setState(() {
                              _fingerprintEnabled = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Fingerprint login enabled')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error enabling fingerprint login')));
                          }
                        } else {
                          // disabling: remove stored credentials
                          final authVmLocal2 = context.read<AuthViewModel>();
                          final user2 = authVmLocal2.currentUser!;
                          final storage = const FlutterSecureStorage();
                          final key = 'fingerprint_credentials_' + user2.id;
                          await storage.delete(key: key);
                          await authVmLocal2.setFingerprintEnabledForUser(null);
                          setState(() {
                            _fingerprintEnabled = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Fingerprint login disabled')));
                        }
                      },
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await authVm.logout();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }
}
