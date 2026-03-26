import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../models/sleep_session.dart';
import '../services/storage_service.dart';
import '../services/photo_service.dart';
import '../widgets/outlined_text.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();
  String _userName = 'Dream Knight';
  String? _avatarPath;
  String? _resolvedAvatarPath;
  List<SleepSession> _sessions = [];
  Map<String, String> _resolvedSelfiePaths = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _storage.init();
    _userName = _storage.getUserName();
    _avatarPath = _storage.getAvatarPath();
    _resolvedAvatarPath = await PhotoService.resolvePhotoPath(_avatarPath);
    _sessions = _storage.getSessions();
    // Pre-resolve all selfie paths
    _resolvedSelfiePaths = {};
    for (final s in _sessions) {
      if (s.selfiePhotoPath != null) {
        final resolved = await PhotoService.resolvePhotoPath(s.selfiePhotoPath);
        if (resolved != null) {
          _resolvedSelfiePaths[s.selfiePhotoPath!] = resolved;
        }
      }
    }
    setState(() => _loaded = true);
  }

  String get _rankTitle {
    final towers = _storage.getTotalTowers();
    if (towers >= 100) return 'Celestial Architect';
    if (towers >= 50) return 'Grand Builder';
    if (towers >= 25) return 'Tower Lord';
    if (towers >= 10) return 'Master Builder';
    if (towers >= 5) return 'Stone Mason';
    if (towers >= 1) return 'Apprentice';
    return 'Newcomer';
  }

  String get _rankEmoji {
    final towers = _storage.getTotalTowers();
    if (towers >= 100) return '🌌';
    if (towers >= 50) return '👑';
    if (towers >= 25) return '🏰';
    if (towers >= 10) return '⭐';
    if (towers >= 5) return '🔨';
    if (towers >= 1) return '🏗️';
    return '🌱';
  }

  Color get _rankColor {
    final towers = _storage.getTotalTowers();
    if (towers >= 100) return AppColors.magicPink;
    if (towers >= 50) return AppColors.golden;
    if (towers >= 25) return AppColors.warmOrange;
    if (towers >= 10) return AppColors.royalPurple;
    if (towers >= 5) return AppColors.skyBlue;
    if (towers >= 1) return AppColors.forestGreen;
    return AppColors.textSecondary;
  }

  Future<void> _changeAvatar() async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Change Avatar'),
        message: const Text('Choose a photo for your tower profile'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final path = await PhotoService.takePhoto();
              if (path != null) {
                await _storage.setAvatarPath(path);
                setState(() => _avatarPath = path);
              }
            },
            child: const Text('📸 Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final path = await PhotoService.pickFromGallery();
              if (path != null) {
                await _storage.setAvatarPath(path);
                setState(() => _avatarPath = path);
              }
            },
            child: const Text('🖼️ Choose from Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);
    await showCupertinoDialog<void>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Knight\'s Name'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter your name',
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await _storage.setUserName(name);
                setState(() => _userName = name);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final selfies = _sessions
        .where((s) =>
            s.selfiePhotoPath != null &&
            _resolvedSelfiePaths.containsKey(s.selfiePhotoPath))
        .toList();

    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.royalPurple, AppColors.nightBlue],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const OutlinedText(
                      text: '👤 Profile',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      strokeWidth: 3,
                      strokeColor: Color(0x44000000),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                        _load(); // reload after settings change
                      },
                      child: const Icon(
                        CupertinoIcons.gear,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.golden, AppColors.warmOrange],
                      ),
                      border: Border.all(color: AppColors.golden, width: 3),
                    ),
                    child: ClipOval(
                      child: _resolvedAvatarPath != null
                          ? Image.file(
                              File(_resolvedAvatarPath!),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            )
                          : const Center(
                              child: Text('🏰',
                                  style: TextStyle(fontSize: 40)),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Name
              Center(
                child: GestureDetector(
                  onTap: _editName,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.pencil,
                        color: AppColors.golden,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Rank title
              const SizedBox(height: 4),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _rankColor.withValues(alpha: 0.3),
                        _rankColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _rankColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '$_rankEmoji $_rankTitle',
                    style: TextStyle(
                      color: _rankColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      '🏰',
                      '${_storage.getTotalTowers()}',
                      'Towers\nCompleted',
                      [AppColors.forestGreen.withValues(alpha: 0.25), AppColors.darkCard],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statCard(
                      '🔥',
                      '${_storage.getCurrentStreak()}',
                      'Current\nStreak',
                      [AppColors.warmOrange.withValues(alpha: 0.25), AppColors.darkCard],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      '⭐',
                      '${_storage.getBestStreak()}',
                      'Best\nStreak',
                      [AppColors.golden.withValues(alpha: 0.2), AppColors.darkCard],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statCard(
                      '😴',
                      '${_sessions.length}',
                      'Total\nSessions',
                      [AppColors.royalPurple.withValues(alpha: 0.25), AppColors.darkCard],
                    ),
                  ),
                ],
              ),

              // Gallery
              if (selfies.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  '📸 Morning Gallery',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: selfies.length,
                  itemBuilder: (context, index) {
                    final storedPath = selfies[index].selfiePhotoPath!;
                    final resolvedPath = _resolvedSelfiePaths[storedPath]!;
                    return GestureDetector(
                      onTap: () => _showFullPhoto(context, resolvedPath),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(resolvedPath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],

              if (selfies.isEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.darkCard, AppColors.cardBg],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.golden.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text('📸', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text(
                        'Morning Gallery',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your wake-up selfies will appear here.\n'
                        'Take one after your next sleep!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String emoji, String value, String label, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.golden.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.golden,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullPhoto(BuildContext context, String path) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (routeCtx) => CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Morning Selfie'),
            backgroundColor:
                AppColors.nightBlue.withValues(alpha: 0.95),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(routeCtx),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.golden),
              ),
            ),
          ),
          child: Container(
            color: AppColors.nightBlue,
            child: Center(
              child: InteractiveViewer(
                child: Image.file(File(path)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
