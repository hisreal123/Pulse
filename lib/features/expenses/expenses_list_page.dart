import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/features/add_expense/add_expense_page.dart';
import 'package:pulse/features/expense_detail/expense_detail_page.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';
import 'package:pulse/features/expenses/widget/expense_tile.dart';
import 'package:pulse/features/expenses/widget/expenses_skeleton.dart';
import 'package:pulse/features/expenses/widget/greeting_header.dart';
import 'package:pulse/features/expenses/widget/total_header.dart';

class ExpensesListPage extends ConsumerWidget {
  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expensesListControllerProvider);
    final showingList = !state.isLoading && !state.hasError;

    return Scaffold(
      floatingActionButton: showingList
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AddExpensePage())),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.isLoading)
                const SliverToBoxAdapter(child: ExpensesSkeleton())
              else if (state.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorView(
                    onRetry: () =>
                        ref.invalidate(expensesListControllerProvider),
                  ),
                )
              else
                ..._content(context, state.requireValue),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(expensesListControllerProvider);
    try {
      await ref.read(expensesListControllerProvider.future);
    } on ApiFailure {
      return;
    }
  }

  List<Widget> _content(BuildContext context, List<Expense> expenses) {
    return [
      const SliverToBoxAdapter(child: GreetingHeader()),
      SliverToBoxAdapter(child: TotalHeader(expenses: expenses)),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
          child: Text(
            'Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
          itemBuilder: (context, index) => ExpenseTile(
            expense: expenses[index],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExpenseDetailPage(expense: expenses[index]),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
