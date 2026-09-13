import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/api_client.dart';
import 'package:pulse/core/env.dart';
import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/http_expense_repository.dart';
import 'package:pulse/data/local_expense_repository.dart';


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  if (Env.useLocalStub) return LocalExpenseRepository();
  return HttpExpenseRepository(ref.watch(apiClientProvider));
});

abstract interface class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();

  Future<Expense> createExpense({
    required String title,
    required int amountKobo,
    ExpenseCategory? category,
  });

  Future<void> deleteExpense(String id);
}
