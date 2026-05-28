class Shift {
  final String id;
  final String employeeId;
  final String date;
  final String shiftType;
  final List<dynamic> attendance;

  Shift({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.shiftType,
    this.attendance = const [],
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: json['date'] ?? '',
      shiftType: json['shiftType'] ?? '',
      attendance: json['attendance'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'shiftType': shiftType,
      'attendance': attendance,
    };
  }

  Shift copyWith({
    String? id,
    String? employeeId,
    String? date,
    String? shiftType,
    List<dynamic>? attendance,
  }) {
    return Shift(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      shiftType: shiftType ?? this.shiftType,
      attendance: attendance ?? this.attendance,
    );
  }
}
