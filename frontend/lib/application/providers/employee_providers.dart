import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';
import '../../infrastructure/services/employee_api_service.dart';
import '../../domain/models/attendance.dart';
import 'admin_providers.dart';
import 'auth_providers.dart';

final employeeApiServiceProvider = Provider<EmployeeApiService>((ref) {
  final token = ref.watch(authTokenProvider);
  return EmployeeApiService(baseUrl: AppConfig.apiBaseUrl, token: token);
});

final myProfileProvider =
    StateNotifierProvider<MyProfileNotifier, AsyncValue<Employee>>((ref) {
  final api = ref.watch(employeeApiServiceProvider);
  final userId = ref.watch(authProvider).user?.id;
  return MyProfileNotifier(api, userId);
});

class MyProfileNotifier extends StateNotifier<AsyncValue<Employee>> {
  final EmployeeApiService _api;
  final String? _employeeId;

  MyProfileNotifier(this._api, this._employeeId)
      : super(const AsyncValue.loading()) {
    if (_employeeId != null) {
      fetchProfile();
    } else {
      state = AsyncValue.error('Not signed in', StackTrace.current);
    }
  }

  Future<void> fetchProfile() async {
    if (_employeeId == null) return;
    state = const AsyncValue.loading();
    try {
      final profile = await _api.getProfile(_employeeId!);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Employee> updateProfile(Employee employee) async {
    final updated = await _api.updateProfileMe({
      'phone': employee.phone,
      'address': employee.address,
      'name': employee.name,
      'profilePicture': employee.profilePicture,
    });
    state = AsyncValue.data(updated);
    return updated;
  }
}

final myAttendanceProvider =
    StateNotifierProvider<MyAttendanceNotifier, AsyncValue<List<Attendance>>>((ref) {
  final api = ref.watch(employeeApiServiceProvider);
  return MyAttendanceNotifier(api);
});

class MyAttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final EmployeeApiService _api;

  MyAttendanceNotifier(this._api) : super(const AsyncValue.loading()) {
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    state = const AsyncValue.loading();
    try {
      final records = await _api.getMyAttendance();
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final myShiftsProvider =
    StateNotifierProvider<MyShiftsNotifier, AsyncValue<List<Shift>>>((ref) {
  final api = ref.watch(employeeApiServiceProvider);
  final userId = ref.watch(authProvider).user?.id;
  return MyShiftsNotifier(api, userId);
});

class MyShiftsNotifier extends StateNotifier<AsyncValue<List<Shift>>> {
  final EmployeeApiService _api;
  final String? _employeeId;

  MyShiftsNotifier(this._api, this._employeeId)
      : super(const AsyncValue.loading()) {
    if (_employeeId != null) {
      fetchShifts();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> fetchShifts() async {
    if (_employeeId == null) return;
    state = const AsyncValue.loading();
    try {
      final shifts = await _api.getMyShifts(_employeeId!);
      shifts.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(shifts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clockIn([String? shiftId]) async {
    if (_employeeId == null) return;
    await _api.clockInMe();
    await fetchShifts();
  }

  Future<void> clockOut([String? shiftId]) async {
    if (_employeeId == null) return;
    await _api.clockOutMe();
    await fetchShifts();
  }
}

final myStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(employeeApiServiceProvider);
  final userId = ref.watch(authProvider).user?.id;
  if (userId == null) {
    throw Exception('Not signed in');
  }
  return api.getMyStatus(userId);
});

/// Flattened attendance rows from the employee's assigned shifts.
List<ShiftAttendanceEntry> flattenShiftAttendance(List<Shift> shifts) {
  final entries = <ShiftAttendanceEntry>[];
  for (final shift in shifts) {
    for (final raw in shift.attendance) {
      if (raw is Map) {
        entries.add(ShiftAttendanceEntry(
          shiftId: shift.id,
          shiftType: shift.shiftType,
          date: raw['date']?.toString() ?? shift.date,
          actionType: raw['actionType']?.toString() ?? '',
          time: raw['time']?.toString() ?? '',
          status: raw['status']?.toString() ?? '',
        ));
      }
    }
  }
  entries.sort((a, b) {
    final d = b.date.compareTo(a.date);
    if (d != 0) return d;
    return b.time.compareTo(a.time);
  });
  return entries;
}

class ShiftAttendanceEntry {
  final String shiftId;
  final String shiftType;
  final String date;
  final String actionType;
  final String time;
  final String status;

  const ShiftAttendanceEntry({
    required this.shiftId,
    required this.shiftType,
    required this.date,
    required this.actionType,
    required this.time,
    required this.status,
  });
}

String todayIsoDate() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

bool shiftHasClockInToday(Shift shift) {
  final today = todayIsoDate();
  return shift.attendance.any((a) {
    if (a is! Map) return false;
    return a['date'] == today && a['actionType'] == 'Clock In';
  });
}

bool shiftHasClockOutToday(Shift shift) {
  final today = todayIsoDate();
  return shift.attendance.any((a) {
    if (a is! Map) return false;
    return a['date'] == today && a['actionType'] == 'Clock Out';
  });
}
