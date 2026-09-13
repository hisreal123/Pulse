import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return expenses..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
