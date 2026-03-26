import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../models/sleep_session.dart';
import '../services/storage_service.dart';
import '../services/photo_service.dart';
import '../widgets/outlined_text.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<SleepSession> _sessions = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    StorageService.sessionUpdated.addListener(_onSessionUpdated);
  }

  @override
  void dispose() {
    StorageService.sessionUpdated.removeListener(_onSessionUpdated);
    super.dispose();
  }

  void _onSessionUpdated() {
    _load();
  }

  Future<void> _load() async {
    await _storage.init();
    setState(() {
      _sessions = _storage.getSessions();
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
            colors: [AppColors.deepSky, AppColors.nightBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: OutlinedText(
                  text: '📊 Sleep History',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  strokeWidth: 3,
                  strokeColor: Color(0x44000000),
                ),
              ),
              const SizedBox(height: 12),
              _buildStatsRow(),
              const SizedBox(height: 12),
              if (_sessions.isNotEmpty) _buildWeeklyChart(),
              if (_sessions.isNotEmpty) const SizedBox(height: 8),
              Expanded(
                child: _sessions.isEmpty ? _buildEmpty() : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final avgHours = _sessions.isEmpty
        ? 0.0
        : _sessions.map((s) => s.sleepHours).reduce((a, b) => a + b) /
            _sessions.length;
    final completedCount = _sessions.where((s) => s.isComplete).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
                '🔥', '${_storage.getCurrentStreak()}', 'Streak'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                _statCard('📊', avgHours.toStringAsFixed(1), 'Avg Hours'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                _statCard('🏰', '${_storage.getTotalTowers()}', 'Towers'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _statCard('👑', '$completedCount', 'Perfect'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    // Get last 7 days of data
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final last7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final match = _sessions.where((s) {
        return s.bedtime.year == day.year &&
            s.bedtime.month == day.month &&
            s.bedtime.day == day.day;
      });
      return (
        label: weekDays[day.weekday - 1],
        hours: match.isNotEmpty ? match.first.sleepHours : 0.0,
        complete: match.isNotEmpty ? match.first.isComplete : false,
      );
    });

    final maxHours = 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.darkCard, AppColors.cardBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.golden.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            const Text(
              '📅 Last 7 Days',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last7.map((day) {
                  final fraction = (day.hours / maxHours).clamp(0.0, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (day.hours > 0)
                            Text(
                              '${day.hours.toStringAsFixed(0)}h',
                              style: TextStyle(
                                color: day.complete
                                    ? AppColors.golden
                                    : AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          const SizedBox(height: 3),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: fraction * 65,
                            constraints: const BoxConstraints(minHeight: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: day.complete
                                    ? [AppColors.golden, AppColors.warmOrange]
                                    : day.hours > 0
                                        ? [AppColors.skyBlue, AppColors.deepSky]
                                        : [AppColors.inactive, AppColors.inactive],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day.label,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkCard, AppColors.cardBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.golden.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.golden,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏗️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text(
            'No sleep sessions yet',
            style: TextStyle(color: CupertinoColors.white, fontSize: 17),
          ),
          SizedBox(height: 4),
          Text(
            'Start building your tower tonight!',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: _sessions.length,
      itemBuilder: (context, index) =>
          _buildSessionCard(_sessions[index]),
    );
  }

  Widget _buildSessionCard(SleepSession session) {
    final date = session.bedtime;
    final dateStr = '${_monthName(date.month)} ${date.day}';
    final maxFloors = session.goalFloors.clamp(1, 8);

    return GestureDetector(
      onTap: () => _showSessionDetail(session),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: session.isComplete
                ? [
                    AppColors.forestGreen.withValues(alpha: 0.2),
                    AppColors.darkCard,
                  ]
                : [AppColors.darkCard, AppColors.cardBg],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: session.isComplete
                ? AppColors.golden.withValues(alpha: 0.3)
                : AppColors.inactive,
          ),
        ),
        child: Row(
          children: [
            // Mini tower bars
            Column(
              children: [
                Text(session.moodEmoji,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                ...List.generate(maxFloors, (i) {
                  final built = i < session.floorsBuilt;
                  return Container(
                    width: 22,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 0.5),
                    decoration: BoxDecoration(
                      color: built
                          ? AppColors.floorPrimary[i % 8]
                          : AppColors.inactive,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).reversed,
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${session.floorsBuilt}/${session.goalFloors} floors  •  ${session.sleepHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (session.dreamNote != null &&
                      session.dreamNote!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      '💭 ${session.dreamNote}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (session.selfiePhotoPath != null) ...[
                    const SizedBox(height: 3),
                    const Text(
                      '📸 Selfie attached',
                      style: TextStyle(
                        color: AppColors.magicPink,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                if (session.isComplete)
                  const Text('👑', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                const Icon(CupertinoIcons.chevron_right,
                    color: AppColors.textSecondary, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionDetail(SleepSession session) {
    final date = session.bedtime;
    final dateStr =
        '${_monthName(date.month)} ${date.day}, ${date.year}';
    final bedtimeStr = _formatTime(date.hour, date.minute);
    final wakeStr =
        _formatTime(session.wakeTime.hour, session.wakeTime.minute);

    String quality;
    Color qualityColor;
    String qualityEmoji;

    if (session.sleepHours >= 8) {
      quality = 'Excellent';
      qualityColor = AppColors.forestGreen;
      qualityEmoji = '🌟';
    } else if (session.sleepHours >= 7) {
      quality = 'Good';
      qualityColor = AppColors.skyBlue;
      qualityEmoji = '😊';
    } else if (session.sleepHours >= 6) {
      quality = 'Fair';
      qualityColor = AppColors.warmOrange;
      qualityEmoji = '🥱';
    } else {
      quality = 'Poor';
      qualityColor = AppColors.brickRed;
      qualityEmoji = '😴';
    }

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  session.isComplete
                      ? '👑 Complete Tower'
                      : '🏗️ Unfinished Tower',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Quality badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: qualityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: qualityColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(qualityEmoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        '$quality Sleep',
                        style: TextStyle(
                          color: qualityColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Details grid
                Row(
                  children: [
                    Expanded(
                      child: _detailTile('🛏️', 'Bedtime', bedtimeStr),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detailTile('☀️', 'Wake Up', wakeStr),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _detailTile('⏱️', 'Duration',
                          '${session.sleepHours.toStringAsFixed(1)}h'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detailTile('🏰', 'Floors',
                          '${session.floorsBuilt}/${session.goalFloors}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _detailTile(
                          session.moodEmoji, 'Mood', 'Recorded'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detailTile(
                        '📸',
                        'Selfie',
                        session.selfiePhotoPath != null ? 'Yes' : 'No',
                      ),
                    ),
                  ],
                ),

                // Selfie preview
                if (session.selfiePhotoPath != null)
                  Builder(builder: (_) {
                    final resolvedPath = PhotoService.resolvePhotoPathSync(session.selfiePhotoPath);
                    if (resolvedPath == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: GestureDetector(
                        onTap: () => _showFullScreenSelfie(ctx, resolvedPath),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.golden.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Image.file(
                                  File(resolvedPath),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(
                                    height: 100,
                                    color: AppColors.nightBlue,
                                    child: const Center(
                                      child: Text(
                                        '📸 Photo not found',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        const Color(0xCC000000),
                                        const Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                  child: const Text(
                                    'Tap to view full size',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                if (session.dreamNote != null &&
                    session.dreamNote!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.nightBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.royalPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💭 Dream Note',
                          style: TextStyle(
                            color: AppColors.golden,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          session.dreamNote!,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.nightBlue,
                    borderRadius: BorderRadius.circular(14),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenSelfie(BuildContext parentCtx, String path) {
    Navigator.of(parentCtx, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (fsCtx) => CupertinoPageScaffold(
          backgroundColor: CupertinoColors.black,
          navigationBar: CupertinoNavigationBar(
            middle: const Text('📸 Morning Selfie'),
            backgroundColor: const Color(0xDD000000),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(fsCtx),
              child: const Text('Close',
                  style: TextStyle(color: CupertinoColors.white)),
            ),
          ),
          child: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📸', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'Photo not found',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailTile(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.nightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.golden,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12
        ? hour - 12
        : (hour == 0 ? 12 : hour);
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
