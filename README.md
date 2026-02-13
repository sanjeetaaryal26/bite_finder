# Bite Finder (Flutter + Dart)

Bite Finder is a Flutter mobile app that helps users discover restaurants using trusted ratings, reviews, specialties, and personalized recommendations.

## Architecture
- Pattern: **MVVM**
- State management: **Provider**
- Navigation: **go_router**
- Data layer: **Local mock + SharedPreferences persistence**
- Repository design is interface-first (`domain/repositories`) so it can be swapped to REST API later.

## Features
- Splash + auth route decision
- Login/Register with validation and local session persistence
- Home search by name/cuisine/specialty/bestseller
- Filter by cuisine + rating (`>= 4.0`), sort by Top Rated / Nearest / Most Reviewed
- Restaurant details with photo carousel, services, bestsellers, reviews, add review
- Favorite toggle and Favorites screen
- Recommendations based on favorites + search history + top-rated fallback
- Feedback/Complaint form and local submission history
- Profile with user info, recent searches, reviews given, logout
- Material 3 + light/dark theme support

## Folder Structure
```
lib/
  core/
    constants/
    theme/
    utils/
    routes/
  data/
    models/
    sources/
    repositories/
  domain/
    repositories/
  presentation/
    viewmodels/
    views/
    widgets/
  main.dart
```

## Run
1. `flutter pub get`
2. `flutter run`

## Local Setup
- Full environment setup steps are documented in `docs/SETUP.md`.
- Use Flutter stable channel for predictable behavior across platforms.

## Tests
- `flutter test`
- Includes:
  - auth validation tests
  - restaurant search/filter tests
