import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/core/failure.dart';
import 'package:pulse/core/model/category.dart';
import 'package:pulse/core/utils/amount_input_formatter.dart';
import 'package:pulse/core/utils/money_formatter.dart';
import 'package:pulse/features/expenses/expenses_list_controller.dart';
import 'package:pulse/features/expenses/widget/category_icon.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  const AddExpensePage({super.key});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory? _category;
  bool _saving = false;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(expensesListControllerProvider.notifier)
          .addExpense(
            title: _titleController.text.trim(),
            amountKobo: koboFromInput(_amountController.text)!,
            category: _category,
          );
      if (mounted) Navigator.of(context).pop();
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageFor(failure))));
    }
  }

  String _messageFor(ApiFailure failure) {
    return switch (failure) {
      ValidationFailure(:final message) => message,
      NetworkFailure() => 'No internet connection. Try again.',
      _ => "Couldn't save the expense. Try again.",
    };
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a title';
    return null;
  }

  String? _validateAmount(String? value) {
    final kobo = koboFromInput(value);
    if (kobo == null) return 'Enter an amount like 1500 or 12.50';
    if (kobo == 0) return 'Amount must be more than 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidate,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: _validateTitle,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'NGN ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [AmountInputFormatter()],
                validator: _validateAmount,
              ),
              const SizedBox(height: 24),
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in ExpenseCategory.values)
                    ChoiceChip(
                      avatar: Icon(categoryIcon(category), size: 18),
                      label: Text(category.categoryName),
                      selected: _category == category,
                      onSelected: (selected) => setState(
                        () => _category = selected ? category : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
