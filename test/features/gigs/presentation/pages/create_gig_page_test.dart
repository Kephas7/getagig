import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getagig/features/gigs/presentation/pages/create_gig_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CreateGigPage())),
    );
    await tester.pump();
  }

  testWidgets('renders key create gig form sections and submit action', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Post a New Gig'), findsOneWidget);
    expect(find.text('GIG OVERVIEW'), findsOneWidget);
    expect(find.text('LOCATION'), findsOneWidget);
    expect(find.text('REQUIREMENTS & PAY'), findsOneWidget);
    expect(find.text('SCHEDULE'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Publish Gig'), findsOneWidget);
  });

  testWidgets('shows validation messages when submitting empty form', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Publish Gig'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Publish Gig'));
    await tester.pump();

    expect(find.text('Title too short'), findsOneWidget);
    expect(find.text('Description too short'), findsOneWidget);
  });
}
