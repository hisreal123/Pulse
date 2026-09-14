import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse/core/model/expense.dart';
import 'package:pulse/core/utils/money_formatter.dart';
import 'package:pulse/features/expenses/widget/category_icon.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = expense.category?.categoryName ?? 'Uncategorised';
    final createdAt = expense.createdAt.toLocal();
    final sameYear = createdAt.year == DateTime.now().year;
    final date = (sameYear ? DateFormat.MMMd() : DateFormat.yMMMd()).format(
      createdAt,
    );
    final bold = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        child: Icon(categoryIcon(expense.category), size: 22),
      ),
      title: Text(
        expense.title,
        style: bold,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$category · $date',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(formatNaira(expense.amountKobo), style: bold),
      onTap: onTap,
    );
  }
}
