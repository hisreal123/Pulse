import 'package:flutter/material.dart';
import 'package:pulse/core/model/category.dart';

IconData categoryIcon(ExpenseCategory? category) {
  return switch (category) {
    ExpenseCategory.food => Icons.restaurant_outlined,
    ExpenseCategory.transport => Icons.directions_car_outlined,
    ExpenseCategory.bills => Icons.receipt_long_outlined,
    ExpenseCategory.other => Icons.category_outlined,
    null => Icons.help_outline,
  };
}
