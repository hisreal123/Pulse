import 'package:flutter/material.dart';
import 'package:pulse/features/expenses/expenses_list_page.dart';

class App extends StatelessWidget {
  const App ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const ExpensesListPage(),
    );
  }
}