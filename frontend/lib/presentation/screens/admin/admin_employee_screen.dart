import 'package:flutter/material.dart';

class AdminEmployeeScreen extends StatelessWidget {
  const AdminEmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: const Center(
        child: Text('Manage Employees'),
      ),
    );
  }
}
