import 'package:flutter_test/flutter_test.dart';
import 'package:uta_gastronomia/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UtaGastronomiaApp());
    expect(find.byType(UtaGastronomiaApp), findsOneWidget);
  });
}
