import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flashmaster/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('loads splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashmasterApp());
    // Wait for async storage load
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('FlashMaster'), findsWidgets);
  });
}
