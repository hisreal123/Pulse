


import 'package:flutter/material.dart';



class ExpensesListPage extends StatelessWidget {

  const ExpensesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses List'),
      ),
      body: const Center(
        child: Text('This is the Expenses List Page'),
      ),
    );
  }  
}