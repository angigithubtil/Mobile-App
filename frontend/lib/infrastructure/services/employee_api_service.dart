import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../domain/models/employee.dart';
import '../../domain/models/shift.dart';

class EmployeeApiService {
  final String baseUrl;
  final String? token;

  EmployeeApiService({required this.baseUrl, this.token});

  Map<String, String> _headers({bool json = true}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Employee> getProfile(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConfig.employeesEndpoint}/$employeeId'),
      headers: _headers(json: false),
    );
    if (response.statusCode == 200) {
      return Employee.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load profile: ${response.statusCode}');
  }

  Future<Employee> updateProfile(Employee employee) async {
    final response = await http.put(
      Uri.parse('$baseUrl${AppConfig.employeesEndpoint}/${employee.id}'),
      headers: _headers(),
      body: json.encode(employee.toJson()),
    );
    if (response.statusCode == 200) {
      return Employee.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to update profile: ${response.statusCode}');
  }

  Future<List<Shift>> getMyShifts(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConfig.assignedShiftEndpoint}/$employeeId'),
      headers: _headers(json: false),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body is List) {
        return body
            .map((e) => Shift.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final map = body as Map<String, dynamic>;
      final shifts = map['shifts'];
      if (shifts is List) {
        return shifts
            .map((e) => Shift.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    if (response.statusCode == 404) return [];
    throw Exception('Failed to load shifts: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getMyStatus(String employeeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${AppConfig.statusEndpoint}/$employeeId'),
      headers: _headers(json: false),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load status: ${response.statusCode}');
  }

  Future<Shift> clockIn(String employeeId, String shiftId) async {
    final response = await http.post(
      Uri.parse('$baseUrl${AppConfig.clockInEndpoint}/$employeeId'),
      headers: _headers(),
      body: json.encode({'shiftId': shiftId}),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final shift = body['shift'];
      if (shift is Map<String, dynamic>) {
        return Shift.fromJson(shift);
      }
      throw Exception('Invalid clock-in response');
    }
    final body = json.decode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Clock-in failed (${response.statusCode})');
  }

  Future<Shift> clockOut(String employeeId, String shiftId) async {
    final response = await http.post(
      Uri.parse('$baseUrl${AppConfig.clockOutEndpoint}/$employeeId'),
      headers: _headers(),
      body: json.encode({'shiftId': shiftId}),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final shift = body['shift'];
      if (shift is Map<String, dynamic>) {
        return Shift.fromJson(shift);
      }
      throw Exception('Invalid clock-out response');
    }
    final body = json.decode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Clock-out failed (${response.statusCode})');
  }
}
