import 'package:flutter_test/flutter_test.dart';

import 'package:hotel/main.dart';

void main() {
  testWidgets('Login page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const HotelApp());

    // Verify login page elements are present
    expect(find.text('Restaurant POS'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
  });
}
