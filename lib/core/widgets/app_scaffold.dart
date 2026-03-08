import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:birdle/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:birdle/features/favorites/presentation/view_model/favorites_viewmodel.dart';
import 'package:birdle/features/feedback/presentation/view_model/feedback_viewmodel.dart';
import 'package:birdle/features/home/presentation/view_model/home_viewmodel.dart';
import 'package:birdle/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:birdle/features/recommendations/presentation/view_model/recommendations_viewmodel.dart';

class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppScaffold({super.key, required this.navigationShell});

  void _refreshBranch(BuildContext context, int index) {
    final userId = context.read<AuthViewModel>().currentUser?.id;
    if (userId == null) {
      return;
    }

    switch (index) {
      case 0:
        unawaited(context.read<HomeViewModel>().load(userId));
        break;
      case 1:
        unawaited(context.read<FavoritesViewModel>().refresh(userId));
        break;
      case 2:
        unawaited(context.read<RecommendationsViewModel>().refresh(userId));
        break;
      case 3:
        unawaited(context.read<FeedbackViewModel>().load(userId));
        break;
      case 4:
        unawaited(context.read<ProfileViewModel>().load(userId));
        break;
    }
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    _refreshBranch(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Recs'),
          NavigationDestination(icon: Icon(Icons.feedback_outlined), label: 'Feedback'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
