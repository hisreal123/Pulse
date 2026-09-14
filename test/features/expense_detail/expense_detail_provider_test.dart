import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/data/expense_repository.dart';
import 'package:pulse/features/expense_detail/expense_detail_provider.dart';

import '../../helpers/test_expense_repository.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(TestExpenseRepository()),
      ],
    );
  });

  test('fetches one expense by its id', () async {
    final provider = expenseDetailProvider('3');
    container.listen(provider, (_, _) {});

    final expense = await container.read(provider.future);

    expect(expense.title, 'Movie');
  });

  test('fails with NotFoundFailure for an unknown id', () async {
    final provider = expenseDetailProvider('missing');
    container.listen(provider, (_, _) {});

    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundFailure>()),
    );
  });
}
