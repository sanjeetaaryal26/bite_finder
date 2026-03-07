import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/models/feedback_model.dart';
import '../../../data/models/restaurant_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/user_model.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/state_widgets.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: vm.isLoading ? null : () => vm.loadAll(),
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Restaurants'),
              Tab(text: 'Users'),
              Tab(text: 'Feedback'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: vm.isLoading && vm.restaurants.isEmpty && vm.users.isEmpty
                    ? const LoadingState()
                    : TabBarView(
                        children: [
                          _RestaurantsTab(vm: vm),
                          _UsersTab(vm: vm, currentUserId: authVm.currentUser?.id),
                          _FeedbackTab(vm: vm),
                          _ReviewsTab(vm: vm),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RestaurantsTab extends StatelessWidget {
  final AdminViewModel vm;

  const _RestaurantsTab({required this.vm});

  Future<void> _openEditor(BuildContext context, {RestaurantModel? existing}) async {
    final result = await showDialog<RestaurantModel>(
      context: context,
      builder: (_) => _RestaurantEditorDialog(existing: existing),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final ok = existing == null ? await vm.createRestaurant(result) : await vm.updateRestaurant(result);
    if (!context.mounted) {
      return;
    }

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            runSpacing: 8,
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text('Total: ${vm.restaurants.length}', style: Theme.of(context).textTheme.titleMedium),
              FilledButton.icon(
                onPressed: vm.isLoading ? null : () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: vm.restaurants.isEmpty
              ? const EmptyState(message: 'No restaurants available')
              : ListView.builder(
                  itemCount: vm.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = vm.restaurants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(restaurant.name),
                        subtitle: Text('${restaurant.location}\n${restaurant.cuisines.join(', ')}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: vm.isLoading ? null : () => _openEditor(context, existing: restaurant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: vm.isLoading
                                  ? null
                                  : () async {
                                      final ok = await vm.deleteRestaurant(restaurant.id);
                                      if (!context.mounted) return;
                                      if (ok) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restaurant removed')));
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  final AdminViewModel vm;
  final String? currentUserId;

  const _UsersTab({required this.vm, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return vm.users.isEmpty
        ? const EmptyState(message: 'No users found')
        : ListView.builder(
            itemCount: vm.users.length,
            itemBuilder: (context, index) {
              final user = vm.users[index];
              final isSelf = user.id == currentUserId;
              final nextRole = user.role == UserRole.admin ? UserRole.user : UserRole.admin;
              final trimmedName = user.name.trim();
              final initial = trimmedName.isEmpty ? '?' : trimmedName[0].toUpperCase();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.email}\nRole: ${user.role.name.toUpperCase()} • Created ${user.createdAt.split('T').first}',
                  ),
                  isThreeLine: true,
                  leading: CircleAvatar(child: Text(initial)),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      PopupMenuButton<UserRole>(
                        enabled: !isSelf && !vm.isLoading,
                        onSelected: (role) async {
                          final ok = await vm.setUserRole(userId: user.id, role: role);
                          if (!context.mounted) return;
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role updated')));
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: nextRole,
                            child: Text(nextRole == UserRole.admin ? 'Make Admin' : 'Make User'),
                          ),
                        ],
                        icon: const Icon(Icons.manage_accounts_outlined),
                      ),
                      IconButton(
                        onPressed: isSelf || vm.isLoading
                            ? null
                            : () async {
                                final ok = await vm.deleteUser(user.id);
                                if (!context.mounted) return;
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
                                }
                              },
                        icon: const Icon(Icons.person_remove_outlined),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class _FeedbackTab extends StatelessWidget {
  final AdminViewModel vm;

  const _FeedbackTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return vm.feedback.isEmpty
        ? const EmptyState(message: 'No feedback submissions')
        : ListView.builder(
            itemCount: vm.feedback.length,
            itemBuilder: (context, index) {
              final entry = vm.feedback[index];
              final user = vm.userById(entry.userId);
              final restaurant = entry.restaurantId == null ? null : vm.restaurantById(entry.restaurantId!);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(entry.type == FeedbackType.complaint ? 'Complaint' : 'Feedback'),
                  subtitle: Text(
                    '${entry.message}\nUser: ${user?.email ?? entry.userId}${restaurant == null ? '' : '\nRestaurant: ${restaurant.name}'}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final ok = await vm.deleteFeedback(entry.id);
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission deleted')));
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
  }
}

class _ReviewsTab extends StatelessWidget {
  final AdminViewModel vm;

  const _ReviewsTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    return vm.reviews.isEmpty
        ? const EmptyState(message: 'No reviews available')
        : ListView.builder(
            itemCount: vm.reviews.length,
            itemBuilder: (context, index) {
              final review = vm.reviews[index];
              final user = vm.userById(review.userId);
              final restaurant = vm.restaurantById(review.restaurantId);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text('${review.rating}/5 - ${restaurant?.name ?? review.restaurantId}'),
                  subtitle: Text('${review.comment}\nBy: ${user?.email ?? review.userId}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final ok = await vm.deleteReview(review.id);
                            if (!context.mounted) return;
                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted')));
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
  }
}

class _RestaurantEditorDialog extends StatefulWidget {
  final RestaurantModel? existing;

  const _RestaurantEditorDialog({this.existing});

  @override
  State<_RestaurantEditorDialog> createState() => _RestaurantEditorDialogState();
}

class _RestaurantEditorDialogState extends State<_RestaurantEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _cuisines;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _specialties;
  late final TextEditingController _services;
  late final TextEditingController _price;
  late final TextEditingController _photos;
  late final TextEditingController _bestSellers;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _name = TextEditingController(text: r?.name ?? '');
    _cuisines = TextEditingController(text: r?.cuisines.join(', ') ?? '');
    _location = TextEditingController(text: r?.location ?? '');
    _description = TextEditingController(text: r?.description ?? '');
    _specialties = TextEditingController(text: r?.specialties.join(', ') ?? '');
    _services = TextEditingController(text: r?.services.join(', ') ?? '');
    _price = TextEditingController(text: r?.priceRange ?? '\$\$');
    _photos = TextEditingController(text: r?.photos.join(', ') ?? '');
    _bestSellers = TextEditingController(text: r?.bestSellers.join(', ') ?? '');
    _latitude = TextEditingController(text: r?.latitude?.toString() ?? '');
    _longitude = TextEditingController(text: r?.longitude?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _cuisines.dispose();
    _location.dispose();
    _description.dispose();
    _specialties.dispose();
    _services.dispose();
    _price.dispose();
    _photos.dispose();
    _bestSellers.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  List<String> _splitList(String input) {
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final latText = _latitude.text.trim();
    final lonText = _longitude.text.trim();
    final lat = latText.isEmpty ? null : double.tryParse(latText);
    final lon = lonText.isEmpty ? null : double.tryParse(lonText);

    if ((latText.isNotEmpty && lat == null) || (lonText.isNotEmpty && lon == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude and longitude must be valid numbers')),
      );
      return;
    }

    final existing = widget.existing;
    final restaurant = RestaurantModel(
      id: existing?.id ?? IdGenerator.next('res'),
      name: _name.text.trim(),
      cuisines: _splitList(_cuisines.text),
      location: _location.text.trim(),
      description: _description.text.trim(),
      specialties: _splitList(_specialties.text),
      services: _splitList(_services.text),
      ratingAvg: existing?.ratingAvg ?? 0,
      ratingCount: existing?.ratingCount ?? 0,
      priceRange: _price.text.trim(),
      photos: _splitList(_photos.text),
      bestSellers: _splitList(_bestSellers.text),
      latitude: lat,
      longitude: lon,
    );

    Navigator.of(context).pop(restaurant);
  }

  @override
  Widget build(BuildContext context) {
    final maxDialogWidth = MediaQuery.of(context).size.width - 48;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Restaurant' : 'Edit Restaurant'),
      content: SizedBox(
        width: maxDialogWidth.clamp(280.0, 520.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cuisines,
                  decoration: const InputDecoration(labelText: 'Cuisines (comma separated)'),
                  validator: (value) => _splitList(value ?? '').isEmpty ? 'Add at least one cuisine' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _specialties,
                  decoration: const InputDecoration(labelText: 'Specialties (comma separated)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _services,
                  decoration: const InputDecoration(labelText: 'Services (comma separated)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bestSellers,
                  decoration: const InputDecoration(labelText: 'Best sellers (comma separated)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _photos,
                  decoration: const InputDecoration(labelText: 'Photo URLs (comma separated)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price range (e.g. \$\$)'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Price range is required' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitude,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Latitude (optional)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _longitude,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Longitude (optional)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
