import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/core/utils/money_formatter.dart';
import 'package:pulse/core/widgets/shimmer.dart';
import 'package:pulse/features/expense_detail/expense_detail_provider.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';
import 'package:pulse/features/expenses/widget/category_icon.dart';

class ExpenseDetailPage extends ConsumerStatefulWidget {
  const ExpenseDetailPage({super.key, required this.expenseId});

  final String expenseId;

  @override
  ConsumerState<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends ConsumerState<ExpenseDetailPage> {
  bool _deleting = false;

  Future<void> _delete(Expense expense) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Delete expense?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${expense.title}" will be removed. This can\'t be undone.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Delete'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await ref
          .read(expensesListControllerProvider.notifier)
          .deleteExpense(expense.id);
      if (mounted) Navigator.of(context).pop();
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _deleting = false);
      final message = failure is NetworkFailure
          ? 'No internet connection. Try again.'
          : "Couldn't delete the expense. Try again.";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _loadErrorMessage(Object error) {
    return switch (error) {
      NotFoundFailure() => "This expense couldn't be found.",
      NetworkFailure() => 'No internet connection.',
      _ => 'Something went wrong',
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseDetailProvider(widget.expenseId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Expense')),
      body: _body(state),
      bottomNavigationBar: state.hasValue && !state.isLoading
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => _delete(state.requireValue),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: _deleting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.delete_outline),
                  label: const Text('Delete expense'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _body(AsyncValue<Expense> state) {
    if (state.isLoading) return const _DetailSkeleton();

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadErrorMessage(state.error!)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.invalidate(expenseDetailProvider(widget.expenseId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _ExpenseDetails(expense: state.requireValue);
  }
}

class _ExpenseDetails extends StatelessWidget {
  const _ExpenseDetails({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = expense.category?.categoryName ?? 'Uncategorised';
    final date = DateFormat.yMMMMd().add_jm().format(
      expense.createdAt.toLocal(),
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Icon(categoryIcon(expense.category), size: 34),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          expense.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formatNaira(expense.amountKobo),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 28),
        Card(
          elevation: 0,
          color: Colors.white,
          child: Column(
            children: [
              ListTile(title: const Text('Category'), trailing: Text(category)),
              const Divider(height: 1),
              ListTile(title: const Text('Date'), trailing: Text(date)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SkeletonBox(width: 72, height: 72, radius: 36),
            SizedBox(height: 16),
            SkeletonBox(width: 140, height: 22),
            SizedBox(height: 12),
            SkeletonBox(width: 200, height: 30),
            SizedBox(height: 28),
            SkeletonBox(height: 112, radius: 12),
          ],
        ),
      ),
    );
  }
}
