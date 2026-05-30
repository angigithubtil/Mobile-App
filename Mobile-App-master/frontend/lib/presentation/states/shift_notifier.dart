import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftNotifier extends StateNotifier<List<dynamic>> {
  ShiftNotifier() : super([]);

  void setShifts(List<dynamic> shifts) {
    state = shifts;
  }

  void addShift(dynamic shift) {
    state = [...state, shift];
  }

  void removeShift(String shiftId) {
    state = state.where((s) => s.id != shiftId).toList();
  }

  void updateShift(String shiftId, dynamic updatedShift) {
    state = state.map((s) => s.id == shiftId ? updatedShift : s).toList();
  }

  void clear() {
    state = [];
  }
}
