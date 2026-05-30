import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_header.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../../application/providers/admin_providers.dart';
import '../../theme/app_theme.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesProvider);
    final shiftsAsync = ref.watch(shiftsProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      appBar: const AdminHeader(title: 'Admin Dashboard'),
      body: Column(
        children: [
          const AdminNavigationBar(currentIndex: 0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(employeesProvider.notifier).fetchEmployees();
                await ref.read(shiftsProvider.notifier).fetchShifts();
                await ref.read(attendanceProvider.notifier).fetchAttendance();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Employees',
                          icon: Icons.people_alt_outlined,
                          color: AppTheme.brand,
                          value: employeesAsync.maybeWhen(
                            data: (v) => v.length.toString(),
                            orElse: () => '—',
                          ),
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/admin/employees'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Assigned shifts',
                          icon: Icons.schedule_outlined,
                          color: AppTheme.accent,
                          value: shiftsAsync.maybeWhen(
                            data: (v) => v.length.toString(),
                            orElse: () => '—',
                          ),
                          onTap: () =>
                              Navigator.pushReplacementNamed(context, '/admin/shifts'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'Attendance records',
                    icon: Icons.fact_check_outlined,
                    color: const Color(0xFF2563EB),
                    value: attendanceAsync.maybeWhen(
                      data: (v) => v.length.toString(),
                      orElse: () => '—',
                    ),
                    onTap: () => Navigator.pushReplacementNamed(
                        context, '/admin/attendance'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent attendance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  attendanceAsync.when(
                    data: (records) {
                      final top = records.take(8).toList();
                      if (top.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No attendance activity yet.'),
                          ),
                        );
                      }
                      return Column(
                        children: top
                            .map(
                              (r) => Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        AppTheme.brand.withValues(alpha: 0.12),
                                    child: const Icon(Icons.badge_outlined,
                                        color: AppTheme.brand),
                                  ),
                                  title: Text(r.employeeName ?? 'Unknown'),
                                  subtitle: Text('${r.date} • ${r.status}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(r.clockIn ?? '—',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700)),
                                      Text(r.clockOut ?? '',
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading dashboard: $e'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
