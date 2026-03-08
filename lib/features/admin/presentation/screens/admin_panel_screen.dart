import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:birdle/core/constants/app_constants.dart';
import 'package:birdle/core/utils/id_generator.dart';
import 'package:birdle/core/utils/restaurant_filter.dart';
import 'package:birdle/features/feedback/data/models/feedback_model.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/data/models/review_model.dart';
import 'package:birdle/features/auth/data/models/user_model.dart';
import 'package:birdle/features/admin/presentation/view_model/admin_viewmodel.dart';
import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/profile/presentation/widgets/profile_editor_dialog.dart';
import 'package:birdle/core/widgets/state_widgets.dart';

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

  Future<void> _openProfileEditor(AuthViewModel authVm) async {
    final user = authVm.currentUser;
    if (user == null) {
      return;
    }
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
    await context.read<AdminViewModel>().loadAll();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin profile updated')));
  }

  Future<void> _logout(AuthViewModel authVm) async {
    await authVm.logout();
    if (!mounted) {
      return;
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final authVm = context.watch<AuthViewModel>();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              tooltip: 'Edit Profile',
              onPressed: authVm.isLoading ? null : () => _openProfileEditor(authVm),
              icon: const Icon(Icons.account_circle_outlined),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: authVm.isLoading ? null : () => _logout(authVm),
              icon: const Icon(Icons.logout),
            ),
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
              Tab(text: 'Activity'),
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
                    : Column(
                        children: [
                          _AdminAccountCard(user: authVm.currentUser),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _RestaurantsTab(vm: vm),
                                _UsersTab(vm: vm, currentUserId: authVm.currentUser?.id),
                                _FeedbackTab(vm: vm),
                                _ReviewsTab(vm: vm),
                                _ActivityTab(vm: vm),
                              ],
                            ),
                          ),
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

class _AdminAccountCard extends StatelessWidget {
  final UserModel? user;

  const _AdminAccountCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final current = user;
    if (current == null) {
      return const SizedBox.shrink();
    }
    final hasPhoto = current.photoPath != null && current.photoPath!.trim().isNotEmpty;
    ImageProvider<Object>? imageProvider;
    if (hasPhoto) {
      if (current.photoPath!.startsWith('http://') || current.photoPath!.startsWith('https://')) {
        imageProvider = NetworkImage(current.photoPath!);
      } else {
        imageProvider = FileImage(File(current.photoPath!));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: imageProvider,
            child: imageProvider == null ? const Icon(Icons.admin_panel_settings_outlined) : null,
          ),
          title: Text(current.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            '${current.email}\nRole: ${current.role.name.toUpperCase()}',
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class _RestaurantsTab extends StatefulWidget {
  final AdminViewModel vm;

  const _RestaurantsTab({required this.vm});

  @override
  State<_RestaurantsTab> createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<_RestaurantsTab> {
  static const _adminSortOptions = ['Top Rated', 'Most Reviewed'];

  final _queryController = TextEditingController();
  String _selectedCuisine = 'All';
  String _sortBy = _adminSortOptions.first;
  bool _highRatingOnly = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _openEditor(BuildContext context, {RestaurantModel? existing}) async {
    final result = await showDialog<RestaurantModel>(
      context: context,
      builder: (_) => _RestaurantEditorDialog(existing: existing),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final vm = widget.vm;
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
    final vm = widget.vm;
    final filtered = RestaurantFilter.apply(
      restaurants: vm.restaurants,
      query: _queryController.text.trim(),
      selectedCuisine: _selectedCuisine,
      highRatingOnly: _highRatingOnly,
      sortBy: _sortBy,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    child: TextField(
                      controller: _queryController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search name, cuisine, specialty, location',
                        suffixIcon: _queryController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _queryController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedCuisine,
                    items: ['All', ...AppConstants.cuisines]
                        .map((c) => DropdownMenuItem<String>(value: c, child: Text('Cuisine: $c')))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedCuisine = value ?? 'All'),
                  ),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: _adminSortOptions
                        .map((value) => DropdownMenuItem<String>(value: value, child: Text('Sort: $value')))
                        .toList(),
                    onChanged: (value) => setState(() => _sortBy = value ?? _adminSortOptions.first),
                  ),
                  FilterChip(
                    selected: _highRatingOnly,
                    label: const Text('>= 4.0'),
                    onSelected: (_) => setState(() => _highRatingOnly = !_highRatingOnly),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                runSpacing: 8,
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${filtered.length} of ${vm.restaurants.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: vm.isLoading ? null : () => _openEditor(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(message: 'No restaurants match the current filters')
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final restaurant = filtered[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(restaurant.name),
                        subtitle: Text(
                          '${restaurant.location}\n${restaurant.cuisines.join(', ')} • ${restaurant.ratingAvg} (${restaurant.ratingCount})',
                        ),
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
              final hasPhoto = user.photoPath != null && user.photoPath!.trim().isNotEmpty;
              ImageProvider<Object>? imageProvider;
              if (hasPhoto) {
                if (user.photoPath!.startsWith('http://') || user.photoPath!.startsWith('https://')) {
                  imageProvider = NetworkImage(user.photoPath!);
                } else {
                  imageProvider = FileImage(File(user.photoPath!));
                }
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.email}\n'
                    'Role: ${user.role.name.toUpperCase()} • Created ${user.createdAt.split('T').first}\n'
                    'Reviews given: ${vm.reviewsGivenCountForUser(user.id)} • Recent searches: ${vm.recentSearchCountForUser(user.id)}',
                  ),
                  isThreeLine: true,
                  leading: CircleAvatar(
                    backgroundImage: imageProvider,
                    child: imageProvider == null ? Text(initial) : null,
                  ),
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

class _ReviewsTab extends StatefulWidget {
  final AdminViewModel vm;

  const _ReviewsTab({required this.vm});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  final _queryController = TextEditingController();
  int _minRating = 1;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final query = _queryController.text.trim().toLowerCase();
    final filtered = vm.reviews.where((review) {
      if (review.rating < _minRating) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final user = vm.userById(review.userId);
      final restaurant = vm.restaurantById(review.restaurantId);
      return review.comment.toLowerCase().contains(query) ||
          (user?.name.toLowerCase().contains(query) ?? false) ||
          (user?.email.toLowerCase().contains(query) ?? false) ||
          (restaurant?.name.toLowerCase().contains(query) ?? false);
    }).toList();

    final avgRating = filtered.isEmpty ? 0.0 : filtered.fold<int>(0, (sum, r) => sum + r.rating) / filtered.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search comment, user or restaurant',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              DropdownButton<int>(
                value: _minRating,
                items: const [1, 2, 3, 4, 5]
                    .map((r) => DropdownMenuItem<int>(value: r, child: Text('Min Rating: $r')))
                    .toList(),
                onChanged: (value) => setState(() => _minRating = value ?? 1),
              ),
              Chip(label: Text('Count: ${filtered.length}')),
              Chip(label: Text('Avg: ${avgRating.toStringAsFixed(1)}')),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(message: 'No reviews available for current filters')
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final review = filtered[index];
                    final user = vm.userById(review.userId);
                    final restaurant = vm.restaurantById(review.restaurantId);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text('${review.rating}/5 - ${restaurant?.name ?? review.restaurantId}'),
                        subtitle: Text(
                          '${review.comment}\nBy: ${user?.name ?? user?.email ?? review.userId} • ${review.createdAt.split('T').first}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                                  final ok = await vm.deleteReview(review.id);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Review deleted')),
                                    );
                                  }
                                },
                          icon: const Icon(Icons.delete_outline),
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

class _ActivityTab extends StatelessWidget {
  final AdminViewModel vm;

  const _ActivityTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    final recentSearches = vm.recentSearches.take(40).toList();
    final usersByReview = [...vm.users]
      ..sort(
        (a, b) => vm.reviewsGivenCountForUser(b.id).compareTo(vm.reviewsGivenCountForUser(a.id)),
      );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (recentSearches.isEmpty)
          const Card(child: ListTile(title: Text('No recent searches found')))
        else
          ...recentSearches.map((entry) {
            final user = vm.userById(entry.userId);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(entry.query),
                subtitle: Text(
                  '${user?.name ?? user?.email ?? entry.userId} • ${entry.createdAt.split('T').first}',
                ),
              ),
            );
          }),
        const SizedBox(height: 14),
        Text('Reviews Given By User', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (usersByReview.isEmpty)
          const Card(child: ListTile(title: Text('No users found')))
        else
          ...usersByReview.map(
            (user) => Card(
              child: ListTile(
                leading: const Icon(Icons.rate_review_outlined),
                title: Text(user.name),
                subtitle: Text(
                  '${user.email}\nReviews: ${vm.reviewsGivenCountForUser(user.id)} • Searches: ${vm.recentSearchCountForUser(user.id)}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
      ],
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
