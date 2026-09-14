import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app.dart';
import 'package:pulse/data/expense_repository.dart';

import '../../helpers/test_expense_repository.dart';

void main() {
  testWidgets('error state shows Retry, and tapping it loads again', (
    tester,
  ) async {
    final repository = TestExpenseRepository()..failLoad = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    repository.failLoad = false;
    await tester.tap(find.text('Retry'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(repository.getAllCalls, 2);
    expect(find.text('Something went wrong'), findsNothing);
    expect(find.text('Coffee'), findsOneWidget);
  });
}
