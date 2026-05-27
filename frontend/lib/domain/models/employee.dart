class Employee {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? profilePicture;
  final String? phone;
  final String? position;
  final String? shift;
  final String status;
  final bool isAdmin;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePicture,
    this.phone,
    this.position,
    this.shift,
    this.status = 'inactive',
    this.isAdmin = false,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profilePicture: json['profilePicture'],
      phone: json['phone'],
      position: json['position'],
      shift: json['shift'],
      status: json['status'] ?? 'inactive',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profilePicture': profilePicture,
      'phone': phone,
      'position': position,
      'shift': shift,
      'status': status,
      'isAdmin': isAdmin,
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profilePicture,
    String? phone,
    String? position,
    String? shift,
    String? status,
    bool? isAdmin,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
