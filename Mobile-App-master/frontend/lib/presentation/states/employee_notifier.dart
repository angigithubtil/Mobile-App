import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmployeeNotifier extends StateNotifier<List<dynamic>> {
  EmployeeNotifier() : super([]);

  void setEmployees(List<dynamic> employees) {
    state = employees;
  }

  void addEmployee(dynamic employee) {
    state = [...state, employee];
  }

  void removeEmployee(String employeeId) {
    state = state.where((e) => e.id != employeeId).toList();
  }

  void updateEmployee(String employeeId, dynamic updatedEmployee) {
    state = state.map((e) => e.id == employeeId ? updatedEmployee : e).toList();
  }

  void clear() {
    state = [];
  }
}
