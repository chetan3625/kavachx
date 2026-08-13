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
    final gymData = json['gymId'];
    final String gId = gymData is Map
        ? (gymData['_id'] ?? gymData['id'] ?? '')
        : (gymData?.toString() ?? '');

    final userData = json['user'] ?? json['userId'] ?? json['memberId'] ?? {};

    return JoinRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      gymId: gId,
      user: UserModel.fromJson(userData is Map<String, dynamic> ? userData : Map<String, dynamic>.from(userData)),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}