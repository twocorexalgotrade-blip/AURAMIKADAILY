// AURAMIKA — Basic smoke test for Phase 1 shell
// Full feature tests will be added per-phase.

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auramika/main.dart';

void main() {
  testWidgets('AURAMIKA app smoke test — shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AuramikaApp(),
      ),
    );
    // Allow async operations (font loading, router init) to settle
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // The app should render without throwing
    expect(find.byType(AuramikaApp), findsOneWidget);
  });
}
