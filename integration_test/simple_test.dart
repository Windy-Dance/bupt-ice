import 'package:flutter_test/flutter_test.dart';
import 'package:bupt_ice/main.dart';
import 'package:bupt_ice/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const BuptIceApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Rust SDK Status'), findsOneWidget);
  });
}

