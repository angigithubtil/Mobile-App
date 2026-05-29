import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../application/providers/admin_providers.dart';
import 'employee_form.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AdminEmployeeScreen extends ConsumerWidget {
  const AdminEmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/admin');
        return false;
      },
      child: Scaffold(
        appBar: const AdminHeader(title: 'Employee Management'),
        body: Column(
          children: [
            const AdminNavigationBar(currentIndex: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeeForm(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Employee'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: employeesAsync.when(
                data: (employees) {
                  if (employees.isEmpty) {
                    return const Center(child: Text('No employees found.'));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          kPrimaryGreen.withOpacity(0.1)),
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Position')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Admin')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: employees.map((employee) {
                        return DataRow(cells: [
                          DataCell(Text(employee.id)),
                          DataCell(Text(employee.name)),
                          DataCell(Text(employee.email)),
                          DataCell(Text(employee.position ?? '-')),
                          DataCell(Text(employee.status)),
                          DataCell(Text(employee.isAdmin ? 'Yes' : 'No')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmployeeForm(
                                        employee: employee,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Employee'),
                                      content: const Text(
                                          'Are you sure you want to delete this employee?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            try {
                                              await ref
                                                  .read(employeesProvider.notifier)
                                                  .deleteEmployee(employee.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Employee deleted successfully'),
                                                  backgroundColor: Colors.green,
                                                ));
                                              }
                                            } catch (error) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text('Error: $error'),
                                                  backgroundColor: Colors.red,
                                                ));
                                              }
                                            }
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error loading employees: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
