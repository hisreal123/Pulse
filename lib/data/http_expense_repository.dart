import 'package:pulse/core/api_client.dart';
import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/expense_repository.dart';

class HttpExpenseRepository implements ExpenseRepository {
  HttpExpenseRepository(this.api);

  final ApiClient api;

  @override
  Future<List<Expense>> getAllExpenses() async {
    final json = await api.get('/expenses') as Map<String, dynamic>;
    final list = json['expenses'] as List;
    return list
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Expense> getExpense(String id) async {
    final json = await api.get('/expenses/$id');
    return Expense.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<Expense> createExpense({
    required String title,
    required int amountKobo,
    ExpenseCategory? category,
  }) async {
    final json = await api.post('/expenses', {
      'title': title,
      'amountKobo': amountKobo,
      'category': category?.categoryName,
    });
    return Expense.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(String id) {
    return api.delete('/expenses/$id');
  }
}
