import 'package:flutter/material.dart';

class AssignShiftForm extends StatefulWidget {
  final dynamic shift;

  const AssignShiftForm({Key? key, this.shift}) : super(key: key);

  @override
  State<AssignShiftForm> createState() => _AssignShiftFormState();
}

class _AssignShiftFormState extends State<AssignShiftForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employeeIdController;
  late TextEditingController _shiftTypeController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _employeeIdController = TextEditingController();
    _shiftTypeController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _shiftTypeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Shift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _employeeIdController,
                decoration: const InputDecoration(labelText: 'Employee ID'),
              ),
              TextFormField(
                controller: _shiftTypeController,
                decoration: const InputDecoration(labelText: 'Shift Type'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Assign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
