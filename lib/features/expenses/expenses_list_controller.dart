import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/expense_repository.dart';

final expensesListControllerProvider =
    AsyncNotifierProvider<ExpensesListController, List<Expense>>(
      ExpensesListController.new,
      retry: (_, _) => null,
    );

class ExpensesListController extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    final repository = ref.watch(expenseRepositoryProvider);
    final expenses = await repository.getAllExpenses();
    return _newestFirst(expenses);
  }

  Future<void> addExpense({
    required String title,
    required int amountKobo,
    ExpenseCategory? category,
  }) async {
    final repository = ref.read(expenseRepositoryProvider);
    final created = await repository.createExpense(
      title: title,
      amountKobo: amountKobo,
      category: category,
    );

    final current = state.value ?? const <Expense>[];
    state = AsyncData(_newestFirst([created, ...current]));
  }

  List<Expense> _newestFirst(List<Expense> expenses) {
    return expenses..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
