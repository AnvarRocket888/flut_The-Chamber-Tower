import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../services/storage_service.dart';
import 'tutorial_screen.dart';
import 'privacy_policy_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();
  String _currentTip = '';

  static const _sleepTips = [
    '🌙 Keep a consistent sleep schedule — even on weekends.',
    '📵 Avoid screens 30 minutes before bed to let melatonin flow.',
    '🛁 A warm bath before sleep lowers core body temperature for deeper rest.',
    '☕ No caffeine after 2 PM — it has a 6-hour half-life.',
    '🌡️ Keep your bedroom cool: 18–20°C is ideal.',
    '🧘 Try 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s.',
    '🌅 Get sunlight within 30 minutes of waking to reset your clock.',
    '🏋️ Exercise regularly, but not within 3 hours of bedtime.',
    '📓 Journaling worries before bed clears the mind for sleep.',
    '🍽️ Avoid heavy meals 2–3 hours before sleeping.',
    '🏰 Building your tower consistently trains your body clock.',
    '💤 Adults need 7–9 hours of sleep for optimal health.',
  ];

  @override
  void initState() {
    super.initState();
    _currentTip = _sleepTips[Random().nextInt(_sleepTips.length)];
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _storage.getSessions();
    final totalSessions = sessions.length;
    final selfieCount = sessions.where((s) => s.selfiePhotoPath != null).length;
    final dreamCount = sessions.where(
        (s) => s.dreamNote != null && s.dreamNote!.isNotEmpty).length;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('⚙️ Settings'),
        backgroundColor: AppColors.nightBlue.withValues(alpha: 0.95),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.nightBlue, AppColors.darkCard],
          ),
        ),
        child: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Sleep tip card
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.royalPurple.withValues(alpha: 0.3),
                      AppColors.darkCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.royalPurple.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '💡 Sleep Tip',
                      style: TextStyle(
                        color: AppColors.golden,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentTip,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      minimumSize: Size.zero,
                      color: AppColors.royalPurple.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        setState(() {
                          _currentTip = _sleepTips[
                              Random().nextInt(_sleepTips.length)];
                        });
                      },
                      child: const Text(
                        '🔄 Another Tip',
                        style: TextStyle(
                            color: CupertinoColors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              _sectionHeader('🏰 Tower Info'),
              _settingTile(
                'Sleep Goal',
                '${_storage.getSleepGoal()} hours',
                AppColors.golden,
              ),
              _settingTile(
                'Alarm Time',
                _formatAlarm(),
                AppColors.golden,
              ),
              _settingTile(
                'Total Towers Built',
                '${_storage.getTotalTowers()}',
                AppColors.forestGreen,
              ),
              _settingTile(
                'Best Streak',
                '${_storage.getBestStreak()} days',
                AppColors.warmOrange,
              ),
              _settingTile(
                'Total Sessions',
                '$totalSessions',
                AppColors.skyBlue,
              ),
              _settingTile(
                'Morning Selfies',
                '$selfieCount 📸',
                AppColors.magicPink,
              ),
              _settingTile(
                'Dream Notes',
                '$dreamCount 💭',
                AppColors.royalPurple,
              ),

              _sectionHeader('ℹ️ About'),
              _settingTile(
                'App Name',
                'The Chamber Tower',
                AppColors.textSecondary,
              ),
              _settingTile(
                'Version',
                '1.0.0',
                AppColors.textSecondary,
              ),

              const SizedBox(height: 8),

              // Tutorial button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const TutorialScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📖 How to Use',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Privacy Policy button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🔒 Privacy Policy',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 15,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Achievements section
              _sectionHeader('🏆 Achievements'),
              _achievementTile(
                '🏗️', 'First Tower',
                'Build your first complete tower',
                _storage.getTotalTowers() >= 1,
              ),
              _achievementTile(
                '🔥', 'On Fire',
                'Reach a 3-day streak',
                _storage.getBestStreak() >= 3,
              ),
              _achievementTile(
                '⭐', 'Tower Master',
                'Complete 10 towers',
                _storage.getTotalTowers() >= 10,
              ),
              _achievementTile(
                '👑', 'Dream Monarch',
                'Reach a 7-day streak',
                _storage.getBestStreak() >= 7,
              ),
              _achievementTile(
                '🌟', 'Legendary Builder',
                'Complete 50 towers',
                _storage.getTotalTowers() >= 50,
              ),
              _achievementTile(
                '📸', 'Selfie Star',
                'Take 5 morning selfies',
                selfieCount >= 5,
              ),
              _achievementTile(
                '💭', 'Dream Keeper',
                'Write 10 dream notes',
                dreamCount >= 10,
              ),
              _achievementTile(
                '🔥', 'Unstoppable',
                'Reach a 14-day streak',
                _storage.getBestStreak() >= 14,
              ),
              _achievementTile(
                '🏰', 'Century Builder',
                'Complete 100 towers',
                _storage.getTotalTowers() >= 100,
              ),
              _achievementTile(
                '🌌', 'Night Guardian',
                'Log 30 sleep sessions',
                totalSessions >= 30,
              ),

              const SizedBox(height: 32),

              // Reset
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoButton(
                  color: AppColors.brickRed,
                  borderRadius: BorderRadius.circular(14),
                  onPressed: _confirmReset,
                  child: const Text(
                    '🗑️ Reset All Data',
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingTile(String title, String value, Color valueColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.inactive.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _achievementTile(
      String emoji, String title, String desc, bool unlocked) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: unlocked
              ? [
                  AppColors.golden.withValues(alpha: 0.15),
                  AppColors.darkCard,
                ]
              : [AppColors.darkCard, AppColors.darkCard],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? AppColors.golden.withValues(alpha: 0.3)
              : AppColors.inactive.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 24,
              color: unlocked ? null : const Color(0xFF555555),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked
                        ? CupertinoColors.white
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: unlocked
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            unlocked ? '✅' : '🔒',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all sleep history, achievements, and photos. '
          'This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await _storage.resetAll();
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  String _formatAlarm() {
    final h = _storage.getAlarmHour();
    final m = _storage.getAlarmMinute();
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h > 12
        ? h - 12
        : (h == 0 ? 12 : h);
    return '${displayH.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }
}
