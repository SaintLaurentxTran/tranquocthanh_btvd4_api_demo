import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:btvd4_api_demo/main.dart';

void main() {
  testWidgets('App renders LoginScreen correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('HUTECH REST API'), findsOneWidget);
    expect(find.text('Thiết lập MSSV của bạn'), findsOneWidget);
    expect(find.text('Kết nối MSSV'), findsOneWidget);
  });
}
