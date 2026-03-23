class SleepSession {
  final String id;
  final DateTime bedtime;
  final DateTime wakeTime;
  final int floorsBuilt;
  final int goalFloors;
  final String moodEmoji;
  final String? selfiePhotoPath;
  final String? dreamNote;

  SleepSession({
    required this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.floorsBuilt,
    required this.goalFloors,
    required this.moodEmoji,
    this.selfiePhotoPath,
    this.dreamNote,
  });

  double get sleepHours => wakeTime.difference(bedtime).inMinutes / 60.0;
  bool get isComplete => floorsBuilt >= goalFloors;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bedtime': bedtime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'floorsBuilt': floorsBuilt,
        'goalFloors': goalFloors,
        'moodEmoji': moodEmoji,
        'selfiePhotoPath': selfiePhotoPath,
        'dreamNote': dreamNote,
      };

  factory SleepSession.fromJson(Map<String, dynamic> json) => SleepSession(
        id: json['id'] as String,
        bedtime: DateTime.parse(json['bedtime'] as String),
        wakeTime: DateTime.parse(json['wakeTime'] as String),
        floorsBuilt: json['floorsBuilt'] as int,
        goalFloors: json['goalFloors'] as int,
        moodEmoji: (json['moodEmoji'] as String?) ?? '😊',
        selfiePhotoPath: json['selfiePhotoPath'] as String?,
        dreamNote: json['dreamNote'] as String?,
      );
}
