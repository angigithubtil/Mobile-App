import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';
import '../../domain/models/attendance.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../../infrastructure/repositories/admin_repository_impl.dart';
import '../../infrastructure/services/admin_api_service.dart';
import '../../config/app_config.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService(baseUrl: AppConfig.apiBaseUrl);
});

final adminRepositoryProvider = Provider<AdminRepositoryImpl>((ref) {
  final apiService = ref.watch(adminApiServiceProvider);
  return AdminRepositoryImpl(apiService);
});

final adminUseCasesProvider = Provider<AdminUseCases>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminUseCases(repository);
});

// Employee Providers
final employeesProvider = StateNotifierProvider<EmployeesNotifier, AsyncValue<List<Employee>>>((ref) {
  final useCases = ref.watch(adminUseCasesProvider);
  return EmployeesNotifier(useCases);
});

class EmployeesNotifier extends StateNotifier<AsyncValue<List<Employee>>> {
  final AdminUseCases _useCases;

  EmployeesNotifier(this._useCases) : super(const AsyncValue.loading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      state = const AsyncValue.loading();
      final employees = await _useCases.getEmployees();
      state = AsyncValue.data(employees);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      final newEmployee = await _useCases.createEmployee(employee);
      state.whenData((employees) {
        state = AsyncValue.data([...employees, newEmployee]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      final updatedEmployee = await _useCases.updateEmployee(employee);
      state.whenData((employees) {
        state = AsyncValue.data(
          employees.map((e) => e.id == employee.id ? updatedEmployee : e).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await _useCases.deleteEmployee(id);
      state.whenData((employees) {
        state = AsyncValue.data(
          employees.where((e) => e.id != id).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Shift Providers
final shiftsProvider = StateNotifierProvider<ShiftsNotifier, AsyncValue<List<Shift>>>((ref) {
  final useCases = ref.watch(adminUseCasesProvider);
  return ShiftsNotifier(useCases);
});

class ShiftsNotifier extends StateNotifier<AsyncValue<List<Shift>>> {
  final AdminUseCases _useCases;

  ShiftsNotifier(this._useCases) : super(const AsyncValue.loading()) {
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    try {
      state = const AsyncValue.loading();
      final shifts = await _useCases.getShifts();
      state = AsyncValue.data(shifts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addShift(Shift shift) async {
    try {
      final newShift = await _useCases.createShift(shift);
      state.whenData((shifts) {
        state = AsyncValue.data([...shifts, newShift]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateShift(Shift shift) async {
    try {
      final updatedShift = await _useCases.updateShift(shift);
      state.whenData((shifts) {
        state = AsyncValue.data(
          shifts.map((s) => s.id == shift.id ? updatedShift : s).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await _useCases.deleteShift(id);
      state.whenData((shifts) {
        state = AsyncValue.data(
          shifts.where((s) => s.id != id).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Attendance Providers
final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AsyncValue<List<Attendance>>>((ref) {
  final useCases = ref.watch(adminUseCasesProvider);
  return AttendanceNotifier(useCases);
});

class AttendanceNotifier extends StateNotifier<AsyncValue<List<Attendance>>> {
  final AdminUseCases _useCases;

  AttendanceNotifier(this._useCases) : super(const AsyncValue.loading()) {
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      state = const AsyncValue.loading();
      final attendance = await _useCases.getAttendance();
      state = AsyncValue.data(attendance);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateAttendance(Attendance attendance) async {
    try {
      final updatedAttendance = await _useCases.updateAttendance(attendance);
      state.whenData((records) {
        state = AsyncValue.data(
          records.map((a) => a.id == attendance.id ? updatedAttendance : a).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAttendance(int id) async {
    try {
      await _useCases.deleteAttendance(id);
      state.whenData((records) {
        state = AsyncValue.data(
          records.where((a) => a.id != id).toList(),
        );
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 
