import 'package:kavachx/Model/usr_model.dart';


class JoinRequestModel {
  final String id;
  final String gymId;
  final UserModel user;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  JoinRequestModel({
    required this.id,
    required this.gymId,
    required this.user,
    required this.status,
    required this.createdAt,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestModel(
      id: json['_id'] ?? json['id'],
      gymId: json['gymId'] ?? '',
      user: UserModel.fromJson(json['user'] ?? json['userId'] ?? {}),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}