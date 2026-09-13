import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';
import 'package:pulse/features/expenses/widget/expense_tile.dart';
import 'package:pulse/features/expenses/widget/greeting_header.dart';
import 'package:pulse/features/expenses/widget/total_header.dart';

class ExpensesListPage extends ConsumerWidget {
  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesListControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GreetingHeader(),
            Expanded(child: _body(context, ref, state)),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Expense>> state,
  ) {
    if (state.hasValue) {
      final expenses = state.requireValue;
      return RefreshIndicator(
        onRefresh: () => ref.refresh(expensesListControllerProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: TotalHeader(expenses: expenses)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (expenses.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No expenses yet')),
              )
            else
              SliverList.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) =>
                    ExpenseTile(expense: expenses[index]),
              ),
          ],
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
