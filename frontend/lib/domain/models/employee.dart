class Employee {
  final String id;
  final String name;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? phone;
  final String? address;
  final String? position;
  final String? shift;
  final String status;
  final bool isAdmin;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    this.password,
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
      password: json['password'],
      profilePicture: json['profilePicture'],
      phone: json['phone'],
      address: json['address'],
      position: json['position'],
      shift: json['shift'],
      status: json['status'] ?? 'inactive',
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'phone': phone,
      'address': address,
      'position': position,
      'shift': shift,
      'status': status,
      'isAdmin': isAdmin,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profilePicture,
    String? phone,
    String? address,
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
      address: address ?? this.address,
      position: position ?? this.position,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
