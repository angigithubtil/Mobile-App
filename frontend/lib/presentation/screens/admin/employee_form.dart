import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/employee.dart';
import '../../../application/providers/admin_providers.dart';

class EmployeeForm extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeForm({Key? key, this.employee}) : super(key: key);

  @override
  ConsumerState<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _shiftController;
  String _status = 'inactive';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employee?.id ?? '');
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.employee?.phone ?? '');
    _positionController = TextEditingController(text: widget.employee?.position ?? '');
    _shiftController = TextEditingController(text: widget.employee?.shift ?? '');
    _status = widget.employee?.status ?? 'inactive';
    _isAdmin = widget.employee?.isAdmin ?? false;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final employee = Employee(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      position: _positionController.text.trim().isEmpty ? null : _positionController.text.trim(),
      shift: _shiftController.text.trim().isEmpty ? null : _shiftController.text.trim(),
      status: _status,
      isAdmin: _isAdmin,
    );

    try {
      if (widget.employee == null) {
        await ref.read(employeesProvider.notifier).addEmployee(employee);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee created successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ref.read(employeesProvider.notifier).updateEmployee(employee);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'New Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'Employee ID'),
                  enabled: !isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Employee ID is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required.';
                    }
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Password (leave blank to keep)' : 'Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!isEditing && (value == null || value.trim().isEmpty)) {
                      return 'Password is required.';
                    }
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _positionController,
                  decoration: const InputDecoration(labelText: 'Position'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _shiftController,
                  decoration: const InputDecoration(labelText: 'Shift'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'on leave', child: Text('On Leave')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Admin user'),
                  value: _isAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isAdmin = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onSubmit,
                  child: Text(isEditing ? 'Update Employee' : 'Create Employee'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
