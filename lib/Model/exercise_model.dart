class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final double weightInKg;
  final int repsPerSet;
  final int totalSets;
  int completedSets;
  final int durationMinutes;
  final String notes;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.weightInKg,
    required this.repsPerSet,
    required this.totalSets,
    this.completedSets = 0,
    this.durationMinutes = 15,
    this.notes = '',
  });

  bool get isCompleted => completedSets >= totalSets;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      muscleGroup: json['muscleGroup'] ?? json['targetPart'] ?? '',
      weightInKg: (json['weightInKg'] as num?)?.toDouble() ?? 0.0,
      repsPerSet: json['repsPerSet'] ?? 10,
      totalSets: json['totalSets'] ?? 4,
      completedSets: json['completedSets'] ?? 0,
      durationMinutes: json['durationMinutes'] ?? 15,
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'weightInKg': weightInKg,
      'repsPerSet': repsPerSet,
      'totalSets': totalSets,
      'completedSets': completedSets,
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }
}
