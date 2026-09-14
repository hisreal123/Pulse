import 'package:pulse/core/api_log.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final _expenses = <Expense>[
    Expense(
      id: '1',
      title: 'Lunch',
      amountKobo: 150000,
      category: ExpenseCategory.food,
      createdAt: DateTime.utc(2026, 9, 10, 13, 0),
    ),
    Expense(
      id: '2',
      title: 'Bus Ticket',
      amountKobo: 50000,
      category: ExpenseCategory.transport,
      createdAt: DateTime.utc(2026, 9, 11, 8, 15),
    ),
    Expense(
      id: '3',
      title: 'Movie',
      amountKobo: 120000,
      category: ExpenseCategory.bills,
      createdAt: DateTime.utc(2026, 9, 12, 19, 30),
    ),
    Expense(
      id: '4',
      title: 'Coffee',
      amountKobo: 30000,
      category: null,
      createdAt: DateTime.utc(2026, 9, 13, 9, 45),
    ),
  ];

  var _nextId = 5;

  @override
  Future<List<Expense>> getAllExpenses() async {
    apiLog('stub GET /expenses');
    await Future.delayed(const Duration(milliseconds: 800));
    apiLog('stub GET /expenses -> 200 (${_expenses.length} expenses)');
    return List.of(_expenses);
  }

  @override
  Future<Expense> getExpense(String id) async {
    apiLog('stub GET /expenses/$id');
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index == -1) {
      apiLog('stub GET /expenses/$id -> 404');
      throw const NotFoundFailure();
    }

    apiLog('stub GET /expenses/$id -> 200');
    return _expenses[index];
  }

  @override
  Future<Expense> createExpense({
    required String title,
    required int amountKobo,
    ExpenseCategory? category,
  }) async {
    apiLog('stub POST /expenses');
    await Future.delayed(const Duration(milliseconds: 500));

    if (title.trim().isEmpty) throw const ValidationFailure("Title is Required");
    if (amountKobo < 0) throw const ValidationFailure("Amount must not be negative");

    final expense = Expense(
      id: '${_nextId++}',
      title: title,
      amountKobo: amountKobo,
      category: category,
      createdAt: DateTime.now().toUtc(),
    );

    _expenses.add(expense);
    apiLog('stub POST /expenses -> 201 (id ${expense.id})');
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    apiLog('stub DELETE /expenses/$id');
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index == -1) {
      apiLog('stub DELETE /expenses/$id -> 404');
      throw const NotFoundFailure();
    }

    _expenses.removeAt(index);
    apiLog('stub DELETE /expenses/$id -> 204');
  }
}
