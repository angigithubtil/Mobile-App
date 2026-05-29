import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../application/providers/admin_providers.dart';

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
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              title: Text(record.employeeName ?? 'Unknown'),
                              subtitle: Text('${record.date} • ${record.status}'),
                              trailing: Text(record.checkIn ?? 'No check-in'),
                            ),
                          );
                        },
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
