import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:governess_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GovernessApp()));
    // Allow async providers (auth auto-login) to settle.
    await tester.pump();
    expect(find.byType(GovernessApp), findsOneWidget);
  });
}
