import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:saas_admin_web/core/di/injection.dart';
import 'package:saas_admin_web/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets('SaaS admin app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SaasAdminApp());
    await tester.pump();
    expect(find.text('SaaS Admin Login'), findsOneWidget);
  });
}
