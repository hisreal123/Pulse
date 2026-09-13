import 'package:flutter/material.dart';
import 'package:pulse/core/app_theme.dart';
import 'package:pulse/features/expenses/expenses_list_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const ExpensesListPage(),
    );
  }
}
