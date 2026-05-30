import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';
import '../../domain/models/attendance.dart';
import '../../domain/repositories/admin_repository.dart';
import '../services/admin_api_service.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApiService _apiService;

  AdminRepositoryImpl(this._apiService);

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      return await _apiService.getEmployees();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  @override
  Future<Employee> createEmployee(Employee employee) async {
    try {
      return await _apiService.createEmployee(employee);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  @override
  Future<Employee> updateEmployee(Employee employee) async {
    try {
      return await _apiService.updateEmployee(employee);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await _apiService.deleteEmployee(id);
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  @override
  Future<List<Shift>> getShifts() async {
    try {
      return await _apiService.getShifts();
    } catch (e) {
      throw Exception('Failed to fetch shifts: $e');
    }
  }

  @override
  Future<Shift> createShift(Shift shift) async {
    try {
      // Delegate to API which returns the created shift payload
      final created = await _apiService.createShift(shift);
      return Shift(
        id: created.id,
        employeeId: created.employeeId,
        shiftType: created.shiftType,
        date: created.date,
        attendance: created.attendance,
      );
    } catch (e) {
      throw Exception('Failed to create shift: $e');
    }
  }

  @override
  Future<Shift> updateShift(Shift shift) async {
    try {
      final updated = await _apiService.updateShift(shift);
      return Shift(
        id: updated.id,
        employeeId: updated.employeeId,
        shiftType: updated.shiftType,
        date: updated.date,
      );
    } catch (e) {
      throw Exception('Failed to update shift: $e');
    }
  }

  @override
  Future<void> deleteShift(String id) async {
    try {
      await _apiService.deleteShift(id);
    } catch (e) {
      throw Exception('Failed to delete shift: $e');
    }
  }

  @override
  Future<List<Attendance>> getAttendance() async {
    try {
      return await _apiService.getAttendance();
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  @override
  Future<Attendance> updateAttendance(Attendance attendance) async {
    try {
      return await _apiService.updateAttendance(attendance);
    } catch (e) {
      throw Exception('Failed to update attendance record: $e');
    }
  }

  @override
  Future<void> deleteAttendance(String id) async {
    try {
      await _apiService.deleteAttendance(id);
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}
