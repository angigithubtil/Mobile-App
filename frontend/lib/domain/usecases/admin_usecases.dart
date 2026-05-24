import '../models/employee.dart';
import '../models/shift.dart';
import '../models/attendance.dart';
import '../repositories/admin_repository.dart';

class AdminUseCases {
  final AdminRepository repository;

  AdminUseCases(this.repository);

  // Employee use cases
  Future<List<Employee>> getEmployees() async {
    return await repository.getEmployees();
  }

  Future<Employee> createEmployee(Employee employee) async {
    return await repository.createEmployee(employee);
  }

  Future<Employee> updateEmployee(Employee employee) async {
    return await repository.updateEmployee(employee);
  }

  Future<void> deleteEmployee(int id) async {
    await repository.deleteEmployee(id);
  }

  // Shift use cases
  Future<List<Shift>> getShifts() async {
    return await repository.getShifts();
  }

  Future<Shift> createShift(Shift shift) async {
    return await repository.createShift(shift);
  }

  Future<Shift> updateShift(Shift shift) async {
    return await repository.updateShift(shift);
  }

  Future<void> deleteShift(String id) async {
    await repository.deleteShift(id);
  }

  // Attendance use cases
  Future<List<Attendance>> getAttendance() async {
    return await repository.getAttendance();
  }

  Future<Attendance> updateAttendance(Attendance attendance) async {
    return await repository.updateAttendance(attendance);
  }

  Future<void> deleteAttendance(int id) async {
    await repository.deleteAttendance(id);
  }
} 
