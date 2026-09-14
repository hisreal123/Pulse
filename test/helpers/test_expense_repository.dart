import 'package:pulse/core/failure.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/local_expense_repository.dart';

class TestExpenseRepository extends LocalExpenseRepository {
  int getAllCalls = 0;
  bool failLoad = false;

  @override
  Future<List<Expense>> getAllExpenses() async {
    getAllCalls++;
    if (failLoad) throw const ServerFailure();
    return super.getAllExpenses();
  }
}
