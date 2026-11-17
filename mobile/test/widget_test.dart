import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uta_gastronomia/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App basic smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const UtaGastronomiaApp());
    expect(find.byType(UtaGastronomiaApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 11));
  });
}
