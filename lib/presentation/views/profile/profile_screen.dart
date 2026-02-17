import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
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
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(user.name),
                        subtitle: Text(user.email),
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
