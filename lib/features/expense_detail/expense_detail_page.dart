import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/core/utils/money_formatter.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';
import 'package:pulse/features/expenses/widget/category_icon.dart';

class ExpenseDetailPage extends ConsumerStatefulWidget {
  const ExpenseDetailPage({super.key, required this.expense});

  final Expense expense;

  @override
  ConsumerState<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends ConsumerState<ExpenseDetailPage> {
  bool _deleting = false;

  Future<void> _delete() async {
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
                  '"${widget.expense.title}" will be removed. This can\'t be undone.',
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
          .deleteExpense(widget.expense.id);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = widget.expense;
    final category = expense.category?.categoryName ?? 'Uncategorised';
    final date = DateFormat.yMMMMd().add_jm().format(
      expense.createdAt.toLocal(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Expense')),
      body: ListView(
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
                ListTile(
                  title: const Text('Category'),
                  trailing: Text(category),
                ),
                const Divider(height: 1),
                ListTile(title: const Text('Date'), trailing: Text(date)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: OutlinedButton.icon(
            onPressed: _deleting ? null : _delete,
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
      ),
    );
  }
}
