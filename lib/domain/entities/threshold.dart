class HealthThreshold {
  final String id;
  final String metricType;
  final int? fromAge;
  final int? toAge;
  final double normalMin;
  final double normalMax;
  final double dangerMin;
  final double dangerMax;
  final String? unit;
  final DateTime? createdAt;

  const HealthThreshold({
    required this.id,
    required this.metricType,
    required this.normalMin,
    required this.normalMax,
    required this.dangerMin,
    required this.dangerMax,
    this.fromAge,
    this.toAge,
    this.unit,
    this.createdAt,
  });

  /// Evaluate a value against this threshold.
  /// Returns 'NORMAL', 'DANGER', or 'CRITICAL'.
  String evaluate(double value) {
    if (value >= normalMin && value <= normalMax) return 'NORMAL';
    if (value >= dangerMin && value <= dangerMax) return 'DANGER';
    return 'CRITICAL';
  }

  factory HealthThreshold.fromMap(Map<String, dynamic> map) {
    return HealthThreshold(
      id: map['id'] as String,
      metricType: map['metric_type'] as String,
      fromAge: map['from_age'] as int?,
      toAge: map['to_age'] as int?,
      normalMin: (map['normal_min'] as num).toDouble(),
      normalMax: (map['normal_max'] as num).toDouble(),
      dangerMin: (map['danger_min'] as num).toDouble(),
      dangerMax: (map['danger_max'] as num).toDouble(),
      unit: map['unit'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'metric_type': metricType,
        if (fromAge != null) 'from_age': fromAge,
        if (toAge != null) 'to_age': toAge,
        'normal_min': normalMin,
        'normal_max': normalMax,
        'danger_min': dangerMin,
        'danger_max': dangerMax,
        if (unit != null) 'unit': unit,
      };

  HealthThreshold copyWith({
    String? metricType,
    int? fromAge,
    int? toAge,
    double? normalMin,
    double? normalMax,
    double? dangerMin,
    double? dangerMax,
    String? unit,
  }) =>
      HealthThreshold(
        id: id,
        metricType: metricType ?? this.metricType,
        fromAge: fromAge ?? this.fromAge,
        toAge: toAge ?? this.toAge,
        normalMin: normalMin ?? this.normalMin,
        normalMax: normalMax ?? this.normalMax,
        dangerMin: dangerMin ?? this.dangerMin,
        dangerMax: dangerMax ?? this.dangerMax,
        unit: unit ?? this.unit,
        createdAt: createdAt,
      );
}
