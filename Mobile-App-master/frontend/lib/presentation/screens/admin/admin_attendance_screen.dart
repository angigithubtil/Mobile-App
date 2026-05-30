import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../application/providers/admin_providers.dart';
import '../../theme/app_theme.dart';

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
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final statusColor = record.status == 'completed'
                              ? Colors.green
                              : (record.status == 'active'
                                  ? AppTheme.brand
                                  : Colors.black54);
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    statusColor.withValues(alpha: 0.12),
                                child: Icon(Icons.badge_outlined,
                                    color: statusColor),
                              ),
                              title: Text(record.employeeName ?? 'Unknown'),
                              subtitle: Text('${record.date} • ${record.status}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(record.clockIn ?? '—',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  Text(record.clockOut ?? '',
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12)),
                                ],
                              ),
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
