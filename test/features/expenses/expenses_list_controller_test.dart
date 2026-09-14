import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/data/expense_repository.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';

import '../../helpers/test_expense_repository.dart';

void main() {
  late TestExpenseRepository repository;
  late ProviderContainer container;

  List<String> titles() => container
      .read(expensesListControllerProvider)
      .requireValue
      .map((e) => e.title)
      .toList();

  ExpensesListController controller() =>
      container.read(expensesListControllerProvider.notifier);

  setUp(() {
    repository = TestExpenseRepository();
    container = ProviderContainer.test(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('loads expenses newest first', () async {
    await container.read(expensesListControllerProvider.future);

    expect(titles(), ['Coffee', 'Movie', 'Bus Ticket', 'Lunch']);
  });

  test('exposes a failed load as an error state', () async {
    repository.failLoad = true;

    await expectLater(
      container.read(expensesListControllerProvider.future),
      throwsA(isA<ServerFailure>()),
    );
    expect(
      container.read(expensesListControllerProvider).error,
      isA<ServerFailure>(),
    );
  });

  test('adds the created expense to the top without reloading', () async {
    await container.read(expensesListControllerProvider.future);

    await controller().addExpense(title: 'Suya', amountKobo: 250000);

    expect(titles(), ['Suya', 'Coffee', 'Movie', 'Bus Ticket', 'Lunch']);
    expect(repository.getAllCalls, 1);
  });

  test('keeps the list unchanged when saving fails', () async {
    await container.read(expensesListControllerProvider.future);

    await expectLater(
      controller().addExpense(title: '', amountKobo: 100),
      throwsA(isA<ValidationFailure>()),
    );

    expect(titles(), ['Coffee', 'Movie', 'Bus Ticket', 'Lunch']);
  });

  test('removes a deleted expense without reloading', () async {
    await container.read(expensesListControllerProvider.future);

    await controller().deleteExpense('3');

    expect(titles(), ['Coffee', 'Bus Ticket', 'Lunch']);
    expect(repository.getAllCalls, 1);
  });
}
