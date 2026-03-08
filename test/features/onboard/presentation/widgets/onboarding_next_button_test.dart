import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/onboard/presentation/widgets/next_button.dart';

void main() {
  Future<void> pumpButton(
    WidgetTester tester, {
    required bool isLastPage,
    required VoidCallback onPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingNextButton(
            isLastPage: isLastPage,
            onPressed: onPressed,
            isLargeScreen: false,
            contentPadding: 20,
            isLandscape: false,
          ),
        ),
      ),
    );
  }

  testWidgets('shows Next label with forward icon on non-last page', (
    tester,
  ) async {
    var tapCount = 0;

    await pumpButton(
      tester,
      isLastPage: false,
      onPressed: () {
        tapCount += 1;
      },
    );

    expect(find.text('Next'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('shows Get Started label without forward icon on last page', (
    tester,
  ) async {
    await pumpButton(tester, isLastPage: true, onPressed: () {});

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsNothing);
    expect(find.text('Next'), findsNothing);
  });
}
