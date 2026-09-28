import 'package:flutter_test/flutter_test.dart';
import 'package:smart_field_monitoring/app.dart';
import 'package:smart_field_monitoring/app_dependencies.dart';

void main() {
  testWidgets('shows the field worker login screen', (tester) async {
    final dependencies = AppDependencies.forTesting();
    await dependencies.initialize();
    await tester
        .pumpWidget(SmartFieldMonitoringApp(dependencies: dependencies));

    expect(find.text('Smart Attendance'), findsOneWidget);
    expect(find.text('Mobile OTP'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}
