/// Model kebiasaan — cermin skema `users/{uid}/habits/{id}` di Firestore
/// sekaligus isi box Hive `habits` untuk mode tamu (disimpan sebagai Map).
class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.weight,
    required this.active,
    this.icon,
    this.createdAt,
  });

  final String id;
  final String title;
  final String category; // kesehatan | belajar | lainnya
  final int weight; // 1–100
  final bool active;
  final String? icon; // emoji ikon habit
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'weight': weight,
        'active': active,
        if (icon != null) 'icon': icon,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory Habit.fromMap(String id, Map<dynamic, dynamic> map) => Habit(
        id: id,
        title: (map['title'] ?? '') as String,
        category: (map['category'] ?? 'lainnya') as String,
        weight: (map['weight'] ?? 1) as int,
        active: (map['active'] ?? true) as bool,
        icon: map['icon'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
      );

  Habit copyWith({
    String? id,
    String? title,
    String? category,
    int? weight,
    bool? active,
    String? icon,
    DateTime? createdAt,
  }) =>
      Habit(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        weight: weight ?? this.weight,
        active: active ?? this.active,
        icon: icon ?? this.icon,
        createdAt: createdAt ?? this.createdAt,
      );
}
