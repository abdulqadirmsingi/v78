import 'package:flutter_test/flutter_test.dart';
import 'package:street_football_rush/main.dart';

void main() {
  testWidgets('App starts and shows splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreetFootballRushApp());

    // Verify splash screen elements
    expect(find.text('STREET'), findsOneWidget);
    expect(find.text('FOOTBALL RUSH'), findsOneWidget);
  });
}
