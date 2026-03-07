import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ThemeViewModel extends ChangeNotifier {
  static const Map<String, Color> _cuisineColors = {
    'all': AppTheme.defaultSeedColor,
    'nepali': Color(0xFFB3272D),
    'pizza': Color(0xFFBE4A1D),
    'cafe': Color(0xFF6E4A3B),
    'momo': Color(0xFF8C3420),
    'burgers': Color(0xFFA1421A),
    'indian': Color(0xFF9A2B1F),
    'thai': Color(0xFF0F7A66),
    'japanese': Color(0xFF40424A),
  };

  Color _seedColor = AppTheme.defaultSeedColor;
  String _activeCuisine = 'All';

  Color get seedColor => _seedColor;
  String get activeCuisine => _activeCuisine;

  void applyCuisine(String cuisine) {
    final normalized = cuisine.trim().toLowerCase();
    final nextColor = _cuisineColors[normalized] ?? AppTheme.defaultSeedColor;
    final nextCuisine = cuisine.trim().isEmpty ? 'All' : cuisine;
    if (nextColor == _seedColor && nextCuisine == _activeCuisine) {
      return;
    }
    _seedColor = nextColor;
    _activeCuisine = nextCuisine;
    notifyListeners();
  }

  void reset() => applyCuisine('All');
}
