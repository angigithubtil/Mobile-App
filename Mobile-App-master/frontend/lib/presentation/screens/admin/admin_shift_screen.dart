import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../application/providers/admin_providers.dart';
import 'assign_shift_form.dart';

const Color kPrimaryGreen = Color(0xFF2E5D47);

class AdminShiftScreen extends ConsumerWidget {
  const AdminShiftScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);
    final shiftsAsync = ref.watch(shiftsProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/admin');
        return false;
      },
      child: Scaffold(
        appBar: const AdminHeader(title: 'Shift Management'),
        body: Column(
          children: [
            const AdminNavigationBar(currentIndex: 2),
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
                          builder: (context) => const AssignShiftForm(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Assign Shift'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: employeesAsync.when(
                data: (employees) => shiftsAsync.when(
                  data: (shifts) {
                    final employeeMap = {for (var e in employees) e.id: e.name};
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(kPrimaryGreen.withOpacity(0.1)),
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Shift')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: shifts.map<DataRow>((shift) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(employeeMap[shift.employeeId] ?? 'Unknown')),
                                    DataCell(Text(shift.shiftType)),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AssignShiftForm(
                                                  shift: shift,
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
                                                title: const Text('Delete Shift'),
                                                content: const Text('Are you sure you want to delete this shift?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      try {
                                                        await ref.read(shiftsProvider.notifier).deleteShift(shift.id);
                                                        if (context.mounted) {
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Shift deleted successfully'),
                                                              backgroundColor: Colors.green,
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (context.mounted) {
                                                          Navigator.pop(context);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('Error: $e'),
                                                              backgroundColor: Colors.red,
                                                            ),
                                                          );
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
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
