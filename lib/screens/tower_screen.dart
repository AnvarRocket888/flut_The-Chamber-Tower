import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/sleep_session.dart';
import '../services/storage_service.dart';
import '../services/photo_service.dart';
import '../widgets/tower_view.dart';
import '../widgets/outlined_text.dart';

class TowerScreen extends StatefulWidget {
  const TowerScreen({super.key});

  @override
  State<TowerScreen> createState() => _TowerScreenState();
}

class _TowerScreenState extends State<TowerScreen> with WidgetsBindingObserver {
  final _storage = StorageService();
  bool _isSleeping = false;
  int _floorsBuilt = 0;
  int _goalFloors = 8;
  DateTime? _bedtime;
  Timer? _timer;
  String _elapsedText = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadState();
  }

  Future<void> _loadState() async {
    await _storage.init();
    final bedtime = _storage.getActiveBedtime();
    final goal = _storage.getSleepGoal();

    if (bedtime != null) {
      setState(() {
        _isSleeping = true;
        _bedtime = bedtime;
        _goalFloors = goal;
        _loaded = true;
      });
      _startTimer();
    } else {
      final sessions = _storage.getSessions();
      setState(() {
        _goalFloors = goal;
        _floorsBuilt = sessions.isNotEmpty ? sessions.first.floorsBuilt : 0;
        _isSleeping = false;
        _loaded = true;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    if (_bedtime == null) return;
    final elapsed = DateTime.now().difference(_bedtime!);
    final hours = elapsed.inHours;
    final mins = elapsed.inMinutes % 60;
    setState(() {
      _floorsBuilt = hours.clamp(0, _goalFloors);
      _elapsedText = '${hours}h ${mins}m';
    });
  }

  Future<void> _startSleep() async {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    await _storage.startSleep(now);
    setState(() {
      _isSleeping = true;
      _bedtime = now;
      _floorsBuilt = 0;
    });
    _startTimer();
  }

  Future<void> _wakeUp() async {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    final now = DateTime.now();
    final floors = _floorsBuilt;
    final session = SleepSession(
      id: now.millisecondsSinceEpoch.toString(),
      bedtime: _bedtime!,
      wakeTime: now,
      floorsBuilt: floors,
      goalFloors: _goalFloors,
      moodEmoji: '😊',
    );
    await _storage.clearActiveSleep();
    setState(() => _isSleeping = false);
    if (!mounted) return;
    _showWakeUpSheet(session);
  }

  // ── Wake-up completion sheet ──

  void _showWakeUpSheet(SleepSession session) {
    String selectedMood = '😊';
    String? selfiePhotoPath;
    String dreamNote = '';

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text(
                      session.isComplete
                          ? '🎉 Tower Complete!'
                          : '☀️ Good Morning!',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You built ${session.floorsBuilt}/${session.goalFloors} floors',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Slept ${session.sleepHours.toStringAsFixed(1)} hours',
                      style: const TextStyle(
                        color: AppColors.golden,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mood selector
                    const Text(
                      'How do you feel?',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['😴', '🥱', '😊', '😃', '😎'].map((emoji) {
                        final selected = selectedMood == emoji;
                        return GestureDetector(
                          onTap: () => setModal(() => selectedMood = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.golden.withValues(alpha: 0.25)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(color: AppColors.golden, width: 2)
                                  : null,
                            ),
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 28)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Dream note
                    CupertinoTextField(
                      placeholder: '💭 Write about your dreams...',
                      placeholderStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      style: const TextStyle(color: CupertinoColors.white),
                      maxLines: 2,
                      onChanged: (v) => dreamNote = v,
                      decoration: BoxDecoration(
                        color: AppColors.nightBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Photo actions
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.royalPurple,
                            borderRadius: BorderRadius.circular(14),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: () async {
                              final path = await PhotoService.takePhoto();
                              if (path != null) {
                                setModal(() => selfiePhotoPath = path);
                              }
                            },
                            child: const Text('📸 Selfie',
                                style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 15)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(14),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            onPressed: () async {
                              final path =
                                  await PhotoService.pickFromGallery();
                              if (path != null) {
                                setModal(() => selfiePhotoPath = path);
                              }
                            },
                            child: const Text('🖼️ Gallery',
                                style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 15)),
                          ),
                        ),
                      ],
                    ),

                    if (selfiePhotoPath != null) ...[
                      const SizedBox(height: 8),
                      const Text('✅ Photo saved!',
                          style: TextStyle(color: AppColors.golden)),
                    ],

                    const SizedBox(height: 18),

                    // Save
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: AppColors.golden,
                        borderRadius: BorderRadius.circular(14),
                        onPressed: () async {
                          final finalSession = SleepSession(
                            id: session.id,
                            bedtime: session.bedtime,
                            wakeTime: session.wakeTime,
                            floorsBuilt: session.floorsBuilt,
                            goalFloors: session.goalFloors,
                            moodEmoji: selectedMood,
                            selfiePhotoPath: selfiePhotoPath,
                            dreamNote:
                                dreamNote.isNotEmpty ? dreamNote : null,
                          );
                          await _storage.saveSession(finalSession);
                          await _storage.updateStreak(finalSession.isComplete);
                          if (finalSession.isComplete) {
                            await _storage.incrementTotalTowers();
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadState();
                        },
                        child: const Text(
                          'Save & Close 🏰',
                          style: TextStyle(
                            color: AppColors.nightBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isSleeping
                ? [
                    const Color(0xFF0D1B2A),
                    const Color(0xFF1B2838),
                    AppColors.nightBlue,
                  ]
                : [
                    AppColors.lightSky,
                    AppColors.deepSky,
                    AppColors.nightBlue,
                  ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: TowerView(
                  floorsBuilt: _floorsBuilt,
                  totalFloors: _goalFloors,
                ),
              ),
              _buildBottomCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final streak = _storage.getCurrentStreak();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          // Streak badge
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warmOrange.withValues(alpha: 0.3),
                    AppColors.golden.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.golden.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '🔥 $streak',
                style: const TextStyle(
                  color: AppColors.golden,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Spacer(),
          Text(
            _isSleeping ? '🌙' : '☁️',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          const OutlinedText(
            text: 'The Chamber Tower',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            strokeWidth: 3,
            strokeColor: Color(0x44000000),
          ),
          const SizedBox(width: 8),
          Text(
            _isSleeping ? '⭐' : '☁️',
            style: const TextStyle(fontSize: 20),
          ),
          const Spacer(),
          if (streak > 0) const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          decoration: BoxDecoration(
            color: AppColors.nightBlue.withValues(alpha: 0.75),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                  color: AppColors.golden.withValues(alpha: 0.25)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: _isSleeping ? _sleepingStatus() : _awakeStatus(),
          ),
        ),
      ),
    );
  }

  Widget _sleepingStatus() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💤', style: TextStyle(fontSize: 30)),
        const SizedBox(height: 6),
        const Text(
          'Sleeping...',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Time asleep: $_elapsedText',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.warmOrange,
            borderRadius: BorderRadius.circular(14),
            onPressed: _wakeUp,
            child: const Text(
              '☀️ Wake Up',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _awakeStatus() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : hour < 21
                ? 'Good Evening'
                : 'Good Night';
    final greetEmoji = hour < 12
        ? '🌅'
        : hour < 17
            ? '☀️'
            : hour < 21
                ? '🌇'
                : '🌙';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _floorsBuilt > 0 ? '🌟' : greetEmoji,
          style: const TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 6),
        Text(
          _floorsBuilt > 0
              ? 'Last night\'s tower'
              : '$greeting!',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (_floorsBuilt == 0) ...[
          const SizedBox(height: 2),
          const Text(
            'Ready to build your tower?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: AppColors.royalPurple,
            borderRadius: BorderRadius.circular(14),
            onPressed: _startSleep,
            child: const Text(
              '🌙 Go to Sleep',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
