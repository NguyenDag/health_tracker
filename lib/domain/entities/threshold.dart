class HealthThreshold {
  final String id;
  final String metricType;
  final int? fromAge;
  final int? toAge;
  final double? minValue;
  final double? maxValue;
  final String level; // NORMAL | DANGER | CRITICAL
  final String? unit;
  final DateTime? createdAt;

  const HealthThreshold({
    required this.id,
    required this.metricType,
    required this.level,
    this.fromAge,
    this.toAge,
    this.minValue,
    this.maxValue,
    this.unit,
    this.createdAt,
  });

  factory HealthThreshold.fromMap(Map<String, dynamic> map) {
    return HealthThreshold(
      id: map['id'] as String,
      metricType: map['metric_type'] as String,
      fromAge: map['from_age'] as int?,
      toAge: map['to_age'] as int?,
      minValue: (map['min_value'] as num?)?.toDouble(),
      maxValue: (map['max_value'] as num?)?.toDouble(),
      level: map['level'] as String? ?? 'NORMAL',
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
        if (minValue != null) 'min_value': minValue,
        if (maxValue != null) 'max_value': maxValue,
        'level': level,
        if (unit != null) 'unit': unit,
      };

  HealthThreshold copyWith({
    String? metricType,
    int? fromAge,
    int? toAge,
    double? minValue,
    double? maxValue,
    String? level,
    String? unit,
  }) =>
      HealthThreshold(
        id: id,
        metricType: metricType ?? this.metricType,
        fromAge: fromAge ?? this.fromAge,
        toAge: toAge ?? this.toAge,
        minValue: minValue ?? this.minValue,
        maxValue: maxValue ?? this.maxValue,
        level: level ?? this.level,
        unit: unit ?? this.unit,
        createdAt: createdAt,
      );
}
