import 'package:flutter_test/flutter_test.dart';

import 'package:euroliga_predictor/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EuroLeagueApp());
    await tester.pump();

    expect(find.byType(EuroLeagueApp), findsOneWidget);
  });
}
