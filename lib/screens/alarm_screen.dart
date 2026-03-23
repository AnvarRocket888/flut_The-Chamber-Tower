import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../services/storage_service.dart';
import '../widgets/outlined_text.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final _storage = StorageService();
  int _alarmHour = 7;
  int _alarmMinute = 0;
  int _sleepGoal = 8;
  bool _alarmEnabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.init();
    setState(() {
      _alarmHour = _storage.getAlarmHour();
      _alarmMinute = _storage.getAlarmMinute();
      _sleepGoal = _storage.getSleepGoal();
      _alarmEnabled = _storage.isAlarmEnabled();
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepPurple, AppColors.nightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: OutlinedText(
                  text: '⏰ Alarm Settings',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  strokeWidth: 3,
                  strokeColor: Color(0x44000000),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildPanel(
                      title: 'Wake Up Time',
                      emoji: '🌅',
                      gradient: [AppColors.darkCard, AppColors.cardBg],
                      child: SizedBox(
                        height: 180,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime:
                              DateTime(2024, 1, 1, _alarmHour, _alarmMinute),
                          onDateTimeChanged: (dt) {
                            setState(() {
                              _alarmHour = dt.hour;
                              _alarmMinute = dt.minute;
                            });
                            _storage.setAlarmTime(dt.hour, dt.minute);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Set Alarm button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() => _alarmEnabled = !_alarmEnabled);
                        _storage.setAlarmEnabled(_alarmEnabled);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _alarmEnabled
                                ? [AppColors.forestGreen, AppColors.darkGreen]
                                : [AppColors.golden, AppColors.warmOrange],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_alarmEnabled
                                      ? AppColors.forestGreen
                                      : AppColors.golden)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _alarmEnabled ? '✅' : '⏰',
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _alarmEnabled
                                  ? 'Alarm Set — ${_formatTime(_alarmHour, _alarmMinute)}'
                                  : 'Set Alarm',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),
                    _buildPanel(
                      title: 'Tower Height Goal',
                      emoji: '🏰',
                      gradient: [
                        AppColors.royalPurple.withValues(alpha: 0.3),
                        AppColors.darkCard,
                      ],
                      child: Column(
                        children: [
                          Text(
                            '$_sleepGoal floors',
                            style: const TextStyle(
                              color: AppColors.golden,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '($_sleepGoal hours of sleep)',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _roundButton(
                                label: '−',
                                color: AppColors.brickRed,
                                enabled: _sleepGoal > 4,
                                onTap: () {
                                  setState(() => _sleepGoal--);
                                  _storage.setSleepGoal(_sleepGoal);
                                },
                              ),
                              const SizedBox(width: 20),
                              // Emoji tower preview
                              SizedBox(
                                width: 120,
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 2,
                                  children: List.generate(
                                    _sleepGoal,
                                    (i) => Text(
                                      AppColors.floorEmojis[i % 8],
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _roundButton(
                                label: '+',
                                color: AppColors.forestGreen,
                                enabled: _sleepGoal < 12,
                                onTap: () {
                                  setState(() => _sleepGoal++);
                                  _storage.setSleepGoal(_sleepGoal);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildPanel(
                      title: 'Suggested Bedtime',
                      emoji: '🌙',
                      gradient: [
                        AppColors.forestGreen.withValues(alpha: 0.2),
                        AppColors.darkCard,
                      ],
                      child: Column(
                        children: [
                          Text(
                            _suggestedBedtime(),
                            style: const TextStyle(
                              color: AppColors.golden,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${_formatTime(_alarmHour, _alarmMinute)} alarm − $_sleepGoal hours',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Quick presets
                    _buildPanel(
                      title: 'Quick Presets',
                      emoji: '⚡',
                      gradient: [
                        AppColors.warmOrange.withValues(alpha: 0.15),
                        AppColors.darkCard,
                      ],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [6, 7, 8, 9].map((h) {
                          final active = _sleepGoal == h;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _sleepGoal = h);
                              _storage.setSleepGoal(h);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.golden
                                    : AppColors.nightBlue,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: active
                                      ? AppColors.golden
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${h}h',
                                style: TextStyle(
                                  color: active
                                      ? AppColors.nightBlue
                                      : CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required String emoji,
    required List<Color> gradient,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.golden.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _roundButton({
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _suggestedBedtime() {
    int bedHour = _alarmHour - _sleepGoal;
    final bedMinute = _alarmMinute;
    if (bedHour < 0) bedHour += 24;
    return _formatTime(bedHour, bedMinute);
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
