import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';
import '../../domain/models/attendance.dart';
import '../../config/app_config.dart';
import 'package:uuid/uuid.dart';

class AdminApiService {
  final String baseUrl;

  AdminApiService({required this.baseUrl});

  // Employee endpoints
  Future<List<Employee>> getEmployees() async {
    final response = await http.get(Uri.parse('$baseUrl${AppConfig.employeesEndpoint}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  Future<Employee> createEmployee(Employee employee) async {
    final url = '$baseUrl/register';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(employee.toJson());
    print('--- CREATE EMPLOYEE DEBUG ---');
    print('URL: ' + url);
    print('Headers: ' + headers.toString());
    print('Body: ' + body);
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print('Status: \\${response.statusCode}');
    print('Response: \\${response.body}');
    print('-----------------------------');
    if (response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final employeeJson = jsonResponse['employee'];
      return Employee.fromJson(employeeJson);
    } else {
      throw Exception('Failed to create employee');
    }
  }

  Future<Employee> updateEmployee(Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateEmployee/${employee.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );
    if (response.statusCode == 200) {
      return Employee.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update employee');
    }
  }

  Future<void> deleteEmployee(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteEmployee/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }

  // Shift endpoints
  Future<List<Shift>> getShifts() async {
    final response = await http.get(Uri.parse('${baseUrl}/assignedShift'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Shift.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shifts');
    }
  }

  Future<Shift> createShift(Shift shift) async {
    final response = await http.post(
      Uri.parse('$baseUrl${AppConfig.assignShiftEndpoint}/${shift.employeeId}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(shift.toJson()),
    );
    if (response.statusCode == 201) {
      final payload = json.decode(response.body) as Map<String, dynamic>;
      return Shift.fromJson(payload['shift'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create shift');
    }
  }

  Future<Shift> updateShift(Shift shift) async {
    final url = '$baseUrl${AppConfig.updateShiftEndpoint}/${shift.id}';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(shift.toJson());
    print('--- UPDATE SHIFT DEBUG ---');
    print('URL: ' + url);
    print('Headers: ' + headers.toString());
    print('Body: ' + body);
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
    print('--------------------------');
    if (response.statusCode == 200) {
      final payload = json.decode(response.body) as Map<String, dynamic>;
      return Shift.fromJson(payload['shift'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update shift: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteShift(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl${AppConfig.shiftsEndpoint}/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete shift');
    }
  }

  // Attendance endpoints
  Future<List<Attendance>> getAttendance() async {
    final response = await http.get(Uri.parse('$baseUrl${AppConfig.attendanceEndpoint}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Attendance.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load attendance records');
    }
  }

  Future<Attendance> updateAttendance(Attendance attendance) async {
    final response = await http.put(
      Uri.parse('$baseUrl${AppConfig.attendanceEndpoint}/${attendance.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(attendance.toJson()),
    );
    if (response.statusCode == 200) {
      return Attendance.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update attendance record');
    }
  }

  Future<void> deleteAttendance(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl${AppConfig.attendanceEndpoint}/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete attendance record');
    }
  }

  Future<void> assignShift({required String employeeId, required String shiftType, required String date}) async {
    final url = '$baseUrl/assignShift/$employeeId';
    final String shiftId = const Uuid().v4();
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'shiftId': shiftId, 'shiftType': shiftType, 'date': date}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to assign shift: ${response.body}');
    }
  }
} 
