import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/profile_editor_dialog.dart';
import '../../widgets/state_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final userId = context.read<AuthViewModel>().currentUser!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().load(userId);
    });
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
      body: profileVm.isLoading && profileVm.recentSearches.isEmpty && profileVm.reviews.isEmpty
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
                    Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
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
                    Text('Reviews Given', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (profileVm.reviews.isEmpty)
                      const Text('No reviews yet')
                    else
                      ...profileVm.reviews.map((r) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(child: Text(r.rating.toString())),
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
}
