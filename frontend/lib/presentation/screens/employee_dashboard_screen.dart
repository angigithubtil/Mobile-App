import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/auth_providers.dart';
import '../../application/providers/employee_providers.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';
import '../theme/app_theme.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  ConsumerState<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends ConsumerState<EmployeeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workspace'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.home_outlined), text: 'Home'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'Schedule'),
            Tab(icon: Icon(Icons.fact_check_outlined), text: 'Attendance'),
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HomeTab(name: authState.user?.name ?? 'Employee'),
          const _ScheduleTab(),
          const _AttendanceTab(),
          const _ProfileTab(),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  final String name;

  const _HomeTab({required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(myStatusProvider);
    final shiftsAsync = ref.watch(myShiftsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myStatusProvider);
        await ref.read(myShiftsProvider.notifier).fetchShifts();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welcome, $name',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'View your schedule, clock in or out, and update your profile.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          statusAsync.when(
            data: (status) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.brand.withValues(alpha: 0.15),
                  child: const Icon(Icons.badge_outlined, color: AppTheme.brand),
                ),
                title: const Text('Workforce status'),
                subtitle: Text(
                  'Status: ${status['status'] ?? 'unknown'} • ID: ${status['id'] ?? ''}',
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load status: $e'),
          ),
          const SizedBox(height: 12),
          shiftsAsync.when(
            data: (shifts) {
              final today = todayIsoDate();
              final todayShifts =
                  shifts.where((s) => s.date == today).toList();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (todayShifts.isEmpty)
                        const Text('No shifts scheduled for today.')
                      else
                        ...todayShifts.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${s.shiftType} • ${s.date}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(myShiftsProvider);

    return shiftsAsync.when(
      data: (shifts) {
        if (shifts.isEmpty) {
          return const Center(child: Text('No assigned shifts yet.'));
        }
        final today = DateTime.now();
        final startOfToday = DateTime(today.year, today.month, today.day);
        final upcoming = <Shift>[];
        final past = <Shift>[];
        for (final shift in shifts) {
          final date = _parseDate(shift.date);
          if (date == null) {
            past.add(shift);
            continue;
          }
          if (!date.isBefore(startOfToday)) {
            upcoming.add(shift);
          } else {
            past.add(shift);
          }
        }
        upcoming.sort((a, b) => a.date.compareTo(b.date));
        past.sort((a, b) => b.date.compareTo(a.date));
        final nextShift = upcoming.isNotEmpty ? upcoming.first : null;

        return RefreshIndicator(
          onRefresh: () => ref.read(myShiftsProvider.notifier).fetchShifts(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (nextShift != null) ...[
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.brand.withValues(alpha: 0.12),
                      child: const Icon(Icons.flag_outlined, color: AppTheme.brand),
                    ),
                    title: const Text('Next shift'),
                    subtitle: Text(
                      '${nextShift.shiftType} • ${nextShift.date}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: nextShift.date == todayIsoDate()
                        ? const Chip(label: Text('Today'))
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (upcoming.isNotEmpty) ...[
                const Text(
                  'Upcoming',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...upcoming.map((s) => _ShiftCard(shift: s)),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Past',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...past.take(14).map((s) => _ShiftCard(shift: s)),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ShiftCard extends ConsumerStatefulWidget {
  final Shift shift;

  const _ShiftCard({required this.shift});

  @override
  ConsumerState<_ShiftCard> createState() => _ShiftCardState();
}

class _ShiftCardState extends ConsumerState<_ShiftCard> {
  bool _busy = false;

  Future<void> _clockIn() async {
    setState(() => _busy = true);
    try {
      await ref.read(myShiftsProvider.notifier).clockIn(widget.shift.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clocked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clockOut() async {
    setState(() => _busy = true);
    try {
      await ref.read(myShiftsProvider.notifier).clockOut(widget.shift.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clocked out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final isToday = shift.date == todayIsoDate();
    final clockedIn = shiftHasClockInToday(shift);
    final clockedOut = shiftHasClockOutToday(shift);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shift.shiftType,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isToday)
                  Chip(
                    label: const Text('Today'),
                    backgroundColor: AppTheme.brand.withValues(alpha: 0.12),
                    labelStyle: const TextStyle(color: AppTheme.brand),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Date: ${shift.date}',
                style: const TextStyle(color: Colors.black54)),
            Text('Shift ID: ${shift.id}',
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            if (isToday) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy || clockedIn ? null : _clockIn,
                      icon: const Icon(Icons.login),
                      label: const Text('Clock In'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _busy || !clockedIn || clockedOut ? null : _clockOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Clock Out'),
                    ),
                  ),
                ],
              ),
              if (clockedIn && !clockedOut)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('You are clocked in for this shift today.',
                      style: TextStyle(color: AppTheme.brand, fontSize: 13)),
                ),
              if (clockedOut)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Shift completed for today.',
                      style: TextStyle(color: Colors.black54, fontSize: 13)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

DateTime? _parseDate(String value) {
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(myShiftsProvider);

    return shiftsAsync.when(
      data: (shifts) {
        final entries = flattenShiftAttendance(shifts);
        if (entries.isEmpty) {
          return const Center(
            child: Text('No attendance activity recorded yet.'),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(myShiftsProvider.notifier).fetchShifts(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    entry.actionType == 'Clock In'
                        ? Icons.login
                        : Icons.logout,
                    color: AppTheme.brand,
                  ),
                  title: Text(entry.actionType),
                  subtitle: Text(
                    '${entry.date} at ${entry.time}\n${entry.shiftType} (${entry.shiftId})',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _ProfileTab extends ConsumerStatefulWidget {
  const _ProfileTab();

  @override
  ConsumerState<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<_ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _shiftController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _employeeId;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _shiftController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _bindProfile(Employee profile) {
    if (_initialized) return;
    _employeeId = profile.id;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';
    _positionController.text = profile.position ?? '';
    _shiftController.text = profile.shift ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _employeeId == null) return;

    setState(() => _saving = true);
    try {
      final employee = Employee(
        id: _employeeId!,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        position: _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        shift: _shiftController.text.trim().isEmpty
            ? null
            : _shiftController.text.trim(),
        status: ref.read(myProfileProvider).value?.status ?? 'active',
        isAdmin: false,
      );

      await ref.read(myProfileProvider.notifier).updateProfile(employee);
      _passwordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      data: (profile) {
        _bindProfile(profile);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Employee ID'),
                  child: Text(profile.id),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Email is required' : null,
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
                  decoration: const InputDecoration(
                      labelText: 'Preferred shift label'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New password (optional)',
                    hintText: 'Leave blank to keep current password',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save profile'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $e'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  ref.read(myProfileProvider.notifier).fetchProfile(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
