class Attendance {
  final String id;
  final String employeeId;
  final String date;
  final String? clockIn;
  final String? clockOut;
  final String status;
  final String? employeeName;
  final String? checkIn;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.status = 'pending',
    this.employeeName,
    this.checkIn,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: json['date'] ?? '',
      clockIn: json['clockIn'],
      clockOut: json['clockOut'],
      status: json['status'] ?? 'pending',
      employeeName: json['employeeName'],
      checkIn: json['checkIn'] ?? json['clockIn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date,
      'clockIn': clockIn,
      'clockOut': clockOut,
      'status': status,
      'employeeName': employeeName,
      'checkIn': checkIn,
    };
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? date,
    String? clockIn,
    String? clockOut,
    String? status,
    String? employeeName,
    String? checkIn,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      status: status ?? this.status,
      employeeName: employeeName ?? this.employeeName,
      checkIn: checkIn ?? this.checkIn,
    );
  }
}
