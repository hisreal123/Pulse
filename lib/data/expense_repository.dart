import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/model/expense.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();

  Future<Expense> createExpense({
    required String title,
    required int amountKobo,
    ExpenseCategory? category,
  });

  Future<void> deleteExpense(String id);
}
