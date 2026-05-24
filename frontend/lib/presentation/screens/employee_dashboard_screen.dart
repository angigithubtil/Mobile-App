import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../states/shift_notifier.dart';
import '../states/auth_notifier.dart';
import '../states/attendance_notifier.dart';
import '../states/employee_notifier.dart';
import '../states/profile_notifier.dart';
import '../../domain/entities/shift.dart';
import 'package:dio/dio.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends ConsumerState<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch shifts for the current employee after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(shiftProvider.notifier).fetchShifts(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shiftState = ref.watch(shiftProvider);
    final user = ref.watch(authProvider).user;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/employee');
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: const Color(0xFFE3ECF0),
            elevation: 4,
           title: Row(
  children: [
    Image.asset('assets/logo.jpg', height: 32),
    const SizedBox(width: 8),
    const Text('Employee Dashboard', style: TextStyle(color: Colors.black)),
  ],
),
            centerTitle: true,
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 24),
            // Nav Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFB4D9E5),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem('Shifts', Icons.calendar_today, 0, _selectedIndex, () => setState(() => _selectedIndex = 0)),
                    const SizedBox(width: 16),
                    _NavItem('Attendance', Icons.access_time, 1, _selectedIndex, () => setState(() => _selectedIndex = 1)),
                    const SizedBox(width: 16),
                    _NavItem('Team', Icons.group, 2, _selectedIndex, () => setState(() => _selectedIndex = 2)),
                    const SizedBox(width: 16),
                    _NavItem('Profile', Icons.person, 3, _selectedIndex, () => setState(() => _selectedIndex = 3)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  // Shifts Tab
                  _ShiftsTab(shiftState: shiftState, onRetry: () {
                    if (user != null) {
                      ref.read(shiftProvider.notifier).fetchShifts(user.id);
                    }
                  }),
                  // Attendance Tab
                  AttendanceTab(),
                  // Team Tab
                  TeamTab(),
                  // Profile Tab
                  ProfileTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;
  const _NavItem(this.label, this.icon, this.index, this.selectedIndex, this.onTap, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool selected = index == selectedIndex;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: selected ? const Color(0xFF2E5D47) : Colors.black54, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? const Color(0xFF2E5D47) : Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftsTab extends ConsumerStatefulWidget {
  final dynamic shiftState;
  final VoidCallback onRetry;
  const _ShiftsTab({required this.shiftState, required this.onRetry, Key? key}) : super(key: key);

  @override
  ConsumerState<_ShiftsTab> createState() => _ShiftsTabState();
}

class _ShiftsTabState extends ConsumerState<_ShiftsTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  static final DateTime _firstDay = DateTime.utc(2024, 1, 1);
  static final DateTime _lastDay = DateTime.utc(2024, 12, 31);

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  bool _showAllShifts = false;

  // Group shifts by date
  Map<String, List<Shift>> _groupShiftsByDate(List<Shift> shifts) {
    final Map<String, List<Shift>> shiftsByDate = {};
    for (var shift in shifts) {
      shiftsByDate.putIfAbsent(shift.date, () => []).add(shift);
    }
    return shiftsByDate;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (now.isBefore(_firstDay)) {
      _focusedDay = _firstDay;
    } else if (now.isAfter(_lastDay)) {
      _focusedDay = _lastDay;
    } else {
      _focusedDay = now;
    }
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final shiftsByDate = _groupShiftsByDate(widget.shiftState.shifts);
    final selectedDateStr = _selectedDay != null
        ? "${_selectedDay!.year.toString().padLeft(4, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}"
        : '';
    final shiftsForSelectedDate = shiftsByDate[selectedDateStr] ?? [];
    final allShifts = widget.shiftState.shifts;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calendar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('view shifts', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: TableCalendar(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _showAllShifts = false;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Assigned shifts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (widget.shiftState.isLoading)
            const Center(child: CircularProgressIndicator()),
          if (widget.shiftState.error != null)
            Column(
              children: [
                Text(widget.shiftState.error!, style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: widget.onRetry, child: const Text('Retry')),
              ],
            ),
          if (!widget.shiftState.isLoading && widget.shiftState.error == null)
            _showAllShifts
                ? (allShifts.isEmpty
                    ? const Text('No assigned shifts found.')
                    : Column(
                        children: allShifts.map<Widget>((shift) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${shift.date}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('Shift: ${shift.shiftType}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: shift.shiftType.toLowerCase() == 'morning'
                                      ? const Color(0xFF2E5D47)
                                      : shift.shiftType.toLowerCase() == 'evening'
                                          ? Colors.grey
                                          : Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  shift.shiftType,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ))
                : (shiftsForSelectedDate.isEmpty
                    ? const Text('No assigned shifts found for this date.')
                    : Column(
                        children: shiftsForSelectedDate.map<Widget>((shift) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${shift.date}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text('Shift: ${shift.shiftType}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: shift.shiftType.toLowerCase() == 'morning'
                                      ? const Color(0xFF2E5D47)
                                      : shift.shiftType.toLowerCase() == 'evening'
                                          ? Colors.grey
                                          : Colors.black54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  shift.shiftType,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      )),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C2B24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final user = ref.read(authProvider).user;
                  if (user != null) {
                    ref.read(shiftProvider.notifier).fetchShifts(user.id);
                    setState(() {
                      _showAllShifts = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Showing all shifts...')),
                    );
                  }
                },
                child: const Text('My Shift', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  String? selectedShiftId;
  late final ValueNotifier<String> currentTime;

  @override
  void initState() {
    super.initState();
    currentTime = ValueNotifier<String>(_getCurrentTime());
    _startClock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(shiftProvider.notifier).fetchShifts(user.id);
        ref.read(attendanceProvider.notifier).fetchAttendance(user.id);
      }
    });
  }

  void _startClock() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      currentTime.value = _getCurrentTime();
      return mounted;
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final shiftState = ref.watch(shiftProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final shifts = shiftState.shifts;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Attendance Tracking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Clock in/out and view attendance records', style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 24),
          Center(
            child: ValueListenableBuilder<String>(
              valueListenable: currentTime,
              builder: (context, value, _) => Column(
                children: [
                  Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('Current Time', style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: selectedShiftId,
            items: shifts.map((shift) => DropdownMenuItem(
              value: shift.id,
              child: Text('${shift.date} - ${shift.shiftType}'),
            )).toList(),
            onChanged: (value) {
              setState(() {
                selectedShiftId = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Select Your Shift',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (user == null || selectedShiftId == null || attendanceState.isLoading)
                      ? null
                      : () async {
                          try {
                            await ref.read(attendanceProvider.notifier).clockIn(user.id, selectedShiftId!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully clocked in'),
                                  backgroundColor: Color(0xFF2E5D47),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              String message = e.toString();
                              if (e is DioException) {
                                final msg = e.response?.data.toString().toLowerCase() ?? '';
                                if (msg.contains('already clocked in')) {
                                  message = 'You have already clocked in for this shift.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5D47),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: attendanceState.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Clock In', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: (user == null || selectedShiftId == null || attendanceState.isLoading)
                      ? null
                      : () async {
                          try {
                            await ref.read(attendanceProvider.notifier).clockOut(user.id, selectedShiftId!);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Successfully clocked out'),
                                  backgroundColor: Color(0xFF2E5D47),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              String message = e.toString();
                              if (e is DioException) {
                                final msg = e.response?.data.toString().toLowerCase() ?? '';
                                if (msg.contains('already clocked out')) {
                                  message = 'You have already clocked out for this shift.';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: attendanceState.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Clock Out', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (attendanceState.isLoading)
            const Center(child: CircularProgressIndicator()),
          if (!attendanceState.isLoading && attendanceState.records.isEmpty)
            const Text('No attendance records found.'),
          if (!attendanceState.isLoading && attendanceState.records.isNotEmpty)
            ...attendanceState.records.map((att) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${att.actionType} (${att.status})', style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text(att.date, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E5D47),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            att.time,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    currentTime.dispose();
    super.dispose();
  }
}

class TeamTab extends ConsumerStatefulWidget {
  const TeamTab({Key? key}) : super(key: key);

  @override
  ConsumerState<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends ConsumerState<TeamTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeeProvider.notifier).fetchEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeState = ref.watch(employeeProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text('Team Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('view your team', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          if (employeeState.isLoading)
            const Center(child: CircularProgressIndicator()),
          if (employeeState.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(employeeState.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!employeeState.isLoading && employeeState.employees.isEmpty)
            const Text('No team members found.'),
          if (!employeeState.isLoading && employeeState.employees.isNotEmpty)
            ...employeeState.employees.map((employee) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFFEDEDED),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(employee.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(employee.position, style: const TextStyle(color: Colors.grey)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: employee.status?.toLowerCase() == 'active' 
                            ? const Color(0xFF2E5D47)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        employee.status?.toLowerCase() == 'active' ? 'Active' : 'On Leave',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '©2025 ShiftMaster. All rights reserved',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();
  final _snackbarKey = GlobalKey<ScaffoldMessengerState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(profileProvider.notifier).fetchProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final user = ref.watch(authProvider).user;
    final isLoading = profileState.isLoading;

    // Set controllers when profile loads
    if (profileState.employee != null) {
      _fullNameController.text = profileState.employee!.name;
      _phoneController.text = profileState.employee!.phone;
      _positionController.text = profileState.employee!.position;
    }

    return ScaffoldMessenger(
      key: _snackbarKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      profileState.employee?.name.substring(0, 2).toUpperCase() ?? '',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileState.employee?.name ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    (profileState.employee?.isAdmin ?? false) ? 'Admin' : 'Employee',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Full Name'),
            TextField(
              controller: _fullNameController,
              enabled: !isLoading,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('ID'),
            TextField(
              controller: TextEditingController(text: profileState.employee?.id ?? ''),
              enabled: false,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Phone'),
            TextField(
              controller: _phoneController,
              enabled: !isLoading,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Position'),
            TextField(
              controller: _positionController,
              enabled: !isLoading,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            // Change Password fields (no button)
            const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _currentPassController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPassController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPassController,
              enabled: !isLoading,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading || user == null
                  ? null
                  : () async {
                      // If password fields are filled, update password only
                      if (_currentPassController.text.isNotEmpty &&
                          _newPassController.text.isNotEmpty &&
                          _confirmPassController.text.isNotEmpty) {
                        if (_newPassController.text != _confirmPassController.text) {
                          _snackbarKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('New passwords do not match')),
                          );
                          return;
                        }
                        await ref.read(profileProvider.notifier).updatePassword(
                          user.id,
                          _currentPassController.text,
                          _newPassController.text,
                        );
                        return;
                      }
                      // Otherwise, update profile fields
                      await ref.read(profileProvider.notifier).updateProfile(
                        user.id,
                        name: _fullNameController.text,
                        phone: _phoneController.text,
                        position: _positionController.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E5D47),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 32),
            if (profileState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(profileState.error!, style: const TextStyle(color: Colors.red)),
              ),
            if (profileState.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(profileState.message!, style: const TextStyle(color: Colors.green)),
              ),
            const SizedBox(height: 24),
            Center(
  child: SizedBox(
    width: 180,
    height: 48,
    child: ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 70, 244, 54),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        ref.read(authProvider.notifier).logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    ),
  ),
),
          ],
          
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
} 
