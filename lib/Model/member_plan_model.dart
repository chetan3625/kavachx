class MembershipPlanModel {
  final String id;
  final String name;
  final double price;
  final int durationInMonths;
  final List<String> features;
  final bool isActive;

  MembershipPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInMonths,
    required this.features,
    this.isActive = true,
  });

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationInMonths: json['durationInMonths'] ?? json['duration'] ?? 1,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationInMonths': durationInMonths,
      'features': features,
      'isActive': isActive,
    };
  }
}