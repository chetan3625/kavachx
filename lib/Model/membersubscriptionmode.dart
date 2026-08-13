class MemberSubscriptionModel {
  final String id;
  final String planName;
  final double price;
  final int durationInMonths;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active, expired, pending
  final List<String> features;

  MemberSubscriptionModel({
    required this.id,
    required this.planName,
    required this.price,
    required this.durationInMonths,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.features,
  });

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isActive => status == 'active' && daysRemaining > 0;

  factory MemberSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MemberSubscriptionModel(
      id: json['id'] ?? json['_id'] ?? '',
      planName: json['planName'] ?? json['plan']?['name'] ?? 'Custom Plan',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationInMonths: json['durationInMonths'] ?? 1,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      status: json['status'] ?? 'active',
      features:
          (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
