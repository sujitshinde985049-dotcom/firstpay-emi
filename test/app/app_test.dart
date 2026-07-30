import 'package:firstpay/app/app.dart';
import 'package:firstpay/app/localization/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the foundation preview', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FirstPayApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.previewTitle), findsOneWidget);
    expect(find.text('FIRST'), findsNothing);
    expect(find.text('Demo Patsanstha'), findsOneWidget);
  });
}
