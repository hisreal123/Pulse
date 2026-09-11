enum ExpenseCategory {
  food('Food'),
  transport('Transport'),
  bills('Bills'),
  other('Other');

  const ExpenseCategory(this.categoryName);
  final String categoryName;

  static ExpenseCategory? fromString(String? raw) {
    if (raw == null) return null;
    return values.firstWhere(
      (category) => category.categoryName == raw,
      orElse: () => other,
    );
  }
}
