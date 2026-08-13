class GymModel {
  final String id;
  final String name;
  final String? qrToken;
  final String? qrUrl;

  GymModel({
    required this.id,
    required this.name,
    this.qrToken,
    this.qrUrl,
  });

  factory GymModel.fromJson(Map<String, dynamic> gymJson, [Map<String, dynamic>? qrJson]) {
    return GymModel(
      id: gymJson['id'] ?? gymJson['_id'] ?? '',
      name: gymJson['name'] ?? '',
      qrToken: qrJson?['token'],
      qrUrl: qrJson?['joinUrl'] ?? qrJson?['qr_url'],
    );
  }
}