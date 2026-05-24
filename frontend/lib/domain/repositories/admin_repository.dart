import '../models/employee.dart';
import '../models/shift.dart';
import '../models/attendance.dart';

abstract class AdminRepository {
  // Employee operations
  Future<List<Employee>> getEmployees();
  Future<Employee> createEmployee(Employee employee);
  Future<Employee> updateEmployee(Employee employee);
  Future<void> deleteEmployee(int id);

  // Shift operations
  Future<List<Shift>> getShifts();
  Future<Shift> createShift(Shift shift);
  Future<Shift> updateShift(Shift shift);
  Future<void> deleteShift(String id);

  // Attendance operations
  Future<List<Attendance>> getAttendance();
  Future<Attendance> updateAttendance(Attendance attendance);
  Future<void> deleteAttendance(int id);
} 
