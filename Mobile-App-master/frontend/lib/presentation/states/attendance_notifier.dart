import 'package:flutter_riverpod/flutter_riverpod.dart';

class AttendanceNotifier extends StateNotifier<List<dynamic>> {
  AttendanceNotifier() : super([]);

  void setAttendance(List<dynamic> attendance) {
    state = attendance;
  }

  void addAttendance(dynamic record) {
    state = [...state, record];
  }

  void removeAttendance(String recordId) {
    state = state.where((a) => a.id != recordId).toList();
  }

  void updateAttendance(String recordId, dynamic updatedRecord) {
    state = state.map((a) => a.id == recordId ? updatedRecord : a).toList();
  }

  void clear() {
    state = [];
  }
}
