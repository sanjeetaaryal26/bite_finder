import 'package:birdle/core/widgets/state_widgets.dart';
import 'package:birdle/features/auth/presentation/widgets/auth_gradient_shell.dart';
import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';
import 'package:birdle/features/restaurant/presentation/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Size size = const Size(400, 800)}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(home: child),
  );
}

RestaurantModel _restaurant({
  String? image,
}) {
  return RestaurantModel(
    id: 'r1',
    name: 'Momo House',
    cuisines: const ['Nepali'],
    location: 'Kathmandu',
    description: 'Local favorites',
    specialties: const ['Momo', 'Chowmein'],
    services: const ['Dine-in'],
    ratingAvg: 4.4,
    ratingCount: 120,
    priceRange: '\$\$',
    photos: image == null ? const [] : [image],
    bestSellers: const ['Steam Momo'],
    latitude: 27.7,
    longitude: 85.3,
  );
}

void main() {
  group('LoadingState', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingState()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is centered on screen', (tester) async {
      await tester.pumpWidget(_wrap(const LoadingState()));
      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('shows default unavailable message', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorState(message: 'ignored')));
      expect(find.text('Content unavailable right now.'), findsOneWidget);
    });

    testWidgets('shows info icon', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorState(message: 'x')));
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows retry button when callback is provided', (tester) async {
      await tester.pumpWidget(_wrap(ErrorState(message: 'x', onRetry: () {})));
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    });

    testWidgets('does not show retry button when callback is null', (tester) async {
      await tester.pumpWidget(_wrap(const ErrorState(message: 'x')));
      expect(find.widgetWithText(FilledButton, 'Retry'), findsNothing);
    });
  });

  group('EmptyState', () {
    testWidgets('renders provided message', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(message: 'No items yet')));
      expect(find.text('No items yet'), findsOneWidget);
    });

    testWidgets('shows inbox icon', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(message: 'Nothing found')));
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });
  });

  group('AuthGradientShell', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AuthGradientShell(
            title: 'Welcome',
            subtitle: 'Sign in to continue',
            child: Text('Form'),
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AuthGradientShell(
            title: 'Auth',
            child: Text('Login Form Body'),
          ),
        ),
      );

      expect(find.text('Login Form Body'), findsOneWidget);
    });

    testWidgets('hides subtitle when null', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AuthGradientShell(
            title: 'Auth',
            child: Text('Body'),
          ),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsNothing);
    });

    testWidgets('shows back button when showBack is true', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AuthGradientShell(
            title: 'Auth',
            showBack: true,
            child: Text('Body'),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls custom onBack callback', (tester) async {
      var called = 0;
      await tester.pumpWidget(
        _wrap(
          AuthGradientShell(
            title: 'Auth',
            showBack: true,
            onBack: () => called += 1,
            child: const Text('Body'),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      expect(called, 1);
    });

    testWidgets('uses smaller title font on narrow screens', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AuthGradientShell(
            title: 'Small',
            child: Text('Body'),
          ),
          size: const Size(320, 800),
        ),
      );

      final titleText = tester.widget<Text>(find.text('Small'));
      expect(titleText.style?.fontSize, 30.0);
    });
  });

  group('RestaurantCard', () {
    testWidgets('renders key restaurant fields', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(restaurant: _restaurant()),
        ),
      );

      expect(find.text('Momo House'), findsOneWidget);
      expect(find.text('Kathmandu'), findsOneWidget);
      expect(find.text('4.4 (120)'), findsOneWidget);
      expect(find.text('Specialty: Momo, Chowmein'), findsOneWidget);
    });

    testWidgets('shows placeholder icon when no image is available', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(restaurant: _restaurant()),
        ),
      );

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });

    testWidgets('uses imageOverride when provided', (tester) async {
      const imageUrl = 'https://example.com/pic.jpg';
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(
            restaurant: _restaurant(image: 'https://example.com/fallback.jpg'),
            imageOverride: imageUrl,
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);
      final provider = imageWidget.image as NetworkImage;
      expect(provider.url, imageUrl);
    });

    testWidgets('trims imageOverride before use', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(
            restaurant: _restaurant(),
            imageOverride: '  https://example.com/trim.jpg  ',
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);
      final provider = imageWidget.image as NetworkImage;
      expect(provider.url, 'https://example.com/trim.jpg');
    });

    testWidgets('falls back to restaurant photo when override is empty', (tester) async {
      const fallback = 'https://example.com/fallback.jpg';
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(
            restaurant: _restaurant(image: fallback),
            imageOverride: '   ',
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image).first);
      final provider = imageWidget.image as NetworkImage;
      expect(provider.url, fallback);
    });

    testWidgets('invokes onTap when card is tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(
          RestaurantCard(
            restaurant: _restaurant(),
            onTap: () => tapped += 1,
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, 1);
    });
  });
}
