import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/admin_providers.dart';
import '../../application/providers/auth_providers.dart';

class EmployeeDashboardScreen extends ConsumerWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final employeesAsync = ref.watch(employeesProvider);
    final shiftsAsync = ref.watch(shiftsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${authState.user?.name ?? 'Employee'}!',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Employees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: employeesAsync.when(
                data: (employees) => employees.isEmpty
                    ? const Center(child: Text('No employees found.'))
                    : ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            title: Text(employees[index].name),
                            subtitle: Text(employees[index].email),
                          ),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Shifts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: shiftsAsync.when(
                data: (shifts) => shifts.isEmpty
                    ? const Center(child: Text('No shifts found.'))
                    : ListView.builder(
                        itemCount: shifts.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            title: Text('Shift ${shifts[index].id}'),
                            subtitle: Text(shifts[index].shiftType),
                          ),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Attendance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: attendanceAsync.when(
                data: (attendance) => attendance.isEmpty
                    ? const Center(child: Text('No attendance records found.'))
                    : ListView.builder(
                        itemCount: attendance.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            title: Text(attendance[index].employeeId),
                            subtitle: Text(attendance[index].date),
                          ),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
