/// Satu catatan timbangan — cermin `users/{uid}/weights/{autoId}`
/// sekaligus isi box Hive `weights` untuk mode tamu.
class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.valueKg,
    required this.date,
    this.createdAt,
  });

  final String id;
  final double valueKg; // validasi: 20–300
  final String date; // YYYY-MM-DD
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'valueKg': valueKg,
        'date': date,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  factory WeightEntry.fromMap(String id, Map<dynamic, dynamic> map) =>
      WeightEntry(
        id: id,
        valueKg: ((map['valueKg'] ?? 0) as num).toDouble(),
        date: (map['date'] ?? '') as String,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'] as String)
            : null,
      );
}
