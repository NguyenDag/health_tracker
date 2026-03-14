// ══════════════════════════════════════════════════════════════════
// UserProfile – mirrors the public.users table in Supabase
// ══════════════════════════════════════════════════════════════════

class UserProfile {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final double? height;
  final double? weight;
  final String? phone;
  final String role;
  final DateTime? dob;
  final String status;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.height,
    this.weight,
    this.phone,
    this.role = 'user',
    this.dob,
    this.status = 'active',
    this.createdAt,
  });

  String get fullName {
    final parts = [firstName, lastName].where((p) => p != null && p.isNotEmpty);
    return parts.join(' ');
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      gender: map['gender'] as String?,
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'user',
      dob: map['dob'] != null ? DateTime.tryParse(map['dob'] as String) : null,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (phone != null) 'phone': phone,
      'role': role,
      if (dob != null) 'dob': dob!.toIso8601String(),
      'status': status,
    };
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    double? height,
    double? weight,
    String? phone,
    String? role,
    DateTime? dob,
    String? status,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      dob: dob ?? this.dob,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
