class AttendanceHistoryModel {
  final String id;
  final String dateStr;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // checked_in, checked_out
  final int? durationMinutes;

  AttendanceHistoryModel({
    required this.id,
    required this.dateStr,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.durationMinutes,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      id: json['id'] ?? '',
      dateStr: json['dateStr'] ?? '',
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      status: json['status'] ?? 'checked_in',
      durationMinutes: json['durationMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateStr': dateStr,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status,
      'durationMinutes': durationMinutes,
    };
  }
}
