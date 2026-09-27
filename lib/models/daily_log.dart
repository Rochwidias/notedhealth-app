/// Log harian — cermin `users/{uid}/daily_logs/{YYYY-MM-DD}`
/// sekaligus isi box Hive `daily_logs` untuk mode tamu.
class DailyLog {
  const DailyLog({
    required this.date,
    required this.completions,
    required this.score,
  });

  final String date; // YYYY-MM-DD (jadi doc ID di Firestore)
  final Map<String, bool> completions; // habitId -> done
  final double score; // 0–100

  Map<String, dynamic> toMap() => {
        'completions': completions,
        'score': score,
      };

  factory DailyLog.fromMap(String date, Map<dynamic, dynamic> map) {
    final raw = (map['completions'] ?? {}) as Map;
    return DailyLog(
      date: date,
      completions: raw.map((k, v) => MapEntry(k as String, (v as bool?) ?? false)),
      score: ((map['score'] ?? 0) as num).toDouble(),
    );
  }
}
