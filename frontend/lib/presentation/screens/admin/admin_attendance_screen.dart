import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../application/providers/admin_providers.dart';
import '../../../domain/models/attendance.dart';

class AdminAttendanceScreen extends ConsumerWidget {
  const AdminAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/admin');
        return false;
      },
      child: Scaffold(
        appBar: const AdminHeader(title: 'Attendance Management'),
        body: Column(
          children: [
            const AdminNavigationBar(currentIndex: 3),
            Expanded(
              child: attendanceAsync.when(
                data: (records) => records.isEmpty
                    ? const Center(child: Text('No attendance records found.'))
                    : _buildAttendanceList(records),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList(List<Attendance> attendanceRecords) {
    final grouped = groupAttendanceByDate(attendanceRecords);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final records = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>((_) => const Color(0xFFEAF5F4)),
                    columns: const [
                      DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Shift', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(records.length, (i) {
                      final record = records[i];
                      final present = record.status.toLowerCase() == 'present' || record.status.toLowerCase() == 'active';
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>((_) => i.isEven ? const Color(0xFFF9FAFB) : Colors.white),
                        cells: [
                          DataCell(Text(record.employeeName)),
                          DataCell(Text(record.employeeId.toString())),
                          DataCell(Text(_getShiftLabel(record))),
                          DataCell(Row(
                            children: [
                              Icon(present ? Icons.check_circle : Icons.cancel, color: present ? Colors.green : Colors.red, size: 20),
                              const SizedBox(width: 4),
                              Text(record.status),
                            ],
                          )),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, List<Attendance>> groupAttendanceByDate(List<Attendance> records) {
    final Map<String, List<Attendance>> grouped = {};
    for (final record in records) {
      final dateStr = record.date.toIso8601String().split('T')[0];
      grouped.putIfAbsent(dateStr, () => []).add(record);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: grouped[k]!};
  }

  String _getShiftLabel(Attendance record) {
    return '${record.checkIn.hour.toString().padLeft(2, '0')}:${record.checkIn.minute.toString().padLeft(2, '0')}';
  }
}
