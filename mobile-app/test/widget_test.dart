import 'package:flutter_test/flutter_test.dart';
import 'package:smart_field_monitoring/main.dart';

void main() {
  testWidgets('shows the field worker login screen', (tester) async {
    await tester.pumpWidget(const SmartAttendanceApp());

    expect(find.text('Smart Attendance'), findsOneWidget);
    expect(find.text('Employee ID'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
