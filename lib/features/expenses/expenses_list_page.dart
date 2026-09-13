import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';

class ExpensesListPage extends ConsumerWidget {
  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pulse')),
      body: _body(ref, state),
    );
  }

  Widget _body(WidgetRef ref, AsyncValue<List<Expense>> state) {
    if (state.hasValue) {
      final expenses = state.requireValue;
      return RefreshIndicator(
        onRefresh: () => ref.refresh(expensesListControllerProvider.future),
        child: expenses.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No expenses yet')),
                ],
              )
            : ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(expenses[index].title)),
              ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => ref.invalidate(expensesListControllerProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
