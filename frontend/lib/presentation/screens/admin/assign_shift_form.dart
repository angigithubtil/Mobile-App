import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/shift.dart';
import '../../../application/providers/admin_providers.dart';

class AssignShiftForm extends ConsumerStatefulWidget {
  final Shift? shift;

  const AssignShiftForm({Key? key, this.shift}) : super(key: key);

  @override
  ConsumerState<AssignShiftForm> createState() => _AssignShiftFormState();
}

class _AssignShiftFormState extends ConsumerState<AssignShiftForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employeeIdController;
  late TextEditingController _shiftTypeController;
  late TextEditingController _dateController;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _employeeIdController = TextEditingController(text: widget.shift?.employeeId ?? '');
    _shiftTypeController = TextEditingController(text: widget.shift?.shiftType ?? '');
    _dateController = TextEditingController(text: widget.shift?.date ?? '');
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _shiftTypeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final newShift = Shift(
      id: widget.shift?.id ?? _uuid.v4(),
      employeeId: _employeeIdController.text.trim(),
      date: _dateController.text.trim(),
      shiftType: _shiftTypeController.text.trim(),
    );

    try {
      if (widget.shift == null) {
        await ref.read(shiftsProvider.notifier).addShift(newShift);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Shift assigned successfully.'),
          backgroundColor: Colors.green,
        ));
      } else {
        await ref.read(shiftsProvider.notifier).updateShift(newShift);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Shift updated successfully.'),
          backgroundColor: Colors.green,
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.shift != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Shift' : 'Assign Shift'),
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
                validator: (v) => v == null || v.trim().isEmpty ? 'Employee ID required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _shiftTypeController,
                decoration: const InputDecoration(labelText: 'Shift Type'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Shift type required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Date required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: Text(isEditing ? 'Update' : 'Assign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
