import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/data/expense_repository.dart';

final expenseDetailProvider = FutureProvider.autoDispose
    .family<Expense, String>(
      (ref, id) => ref.watch(expenseRepositoryProvider).getExpense(id),
      retry: (_, _) => null,
    );
