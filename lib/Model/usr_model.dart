class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'gym_owner' or 'gym_member'
  final String? gymId;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.gymId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      gymId: json['gymId'] ?? json['gym']?['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {

      if (id != null) '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      if (gymId != null) 'gymId': gymId,
    };
  }
}