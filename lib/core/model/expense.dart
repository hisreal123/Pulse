import 'package:pulse/core/model/category.dart';

class Expense {
  final String id;
  final String title;
  final int amountKobo;
  final ExpenseCategory? category;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amountKobo,
    required this.category,
    required this.createdAt,
  });

  /// Builds an [Expense] from an API payload.
  ///
  /// This is the boundary: untyped JSON in, a type the rest of the app can
  /// rely on out.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amountKobo: json['amountKobo'] as int,
      category: ExpenseCategory.fromString(json['category'] as String?),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// The POST body for creating an expense.
  Map<String, dynamic> toJsonForCreate() {
    return {
      'title': title,
      'amountKobo': amountKobo,
      'category': category?.categoryName,
    };
  }

  Expense copyWith({
    String? id,
    String? title,
    int? amountKobo,
    ExpenseCategory? category,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amountKobo: amountKobo ?? this.amountKobo,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amountKobo == amountKobo &&
        other.category == category &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, title, amountKobo, category, createdAt);

  @override
  String toString() =>
      'Expense($id, $title, $amountKobo, $category, $createdAt)';
}
