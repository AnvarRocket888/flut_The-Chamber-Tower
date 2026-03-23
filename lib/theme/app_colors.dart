import 'dart:ui';

class AppColors {
  AppColors._();

  // ── Sky palette ──
  static const Color skyBlue = Color(0xFF4AABFF);
  static const Color deepSky = Color(0xFF1E6FD9);
  static const Color lightSky = Color(0xFFB8E0FF);

  // ── Golden accents ──
  static const Color golden = Color(0xFFFFD700);
  static const Color warmOrange = Color(0xFFFF9500);
  static const Color lightGold = Color(0xFFFFE082);

  // ── Building materials ──
  static const Color brickRed = Color(0xFFCC5A3C);
  static const Color darkBrick = Color(0xFF8B3A2A);
  static const Color forestGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color royalPurple = Color(0xFF7E57C2);
  static const Color deepPurple = Color(0xFF4A148C);
  static const Color magicPink = Color(0xFFEC407A);
  static const Color lightPink = Color(0xFFF48FB1);
  static const Color stoneBrown = Color(0xFF9E8E7E);
  static const Color woodBrown = Color(0xFF8D6E63);

  // ── UI backgrounds ──
  static const Color nightBlue = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color cardBg = Color(0xFF1A2340);

  // ── Text ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color cloudWhite = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFFB0BEC5);

  // ── Inactive / placeholder ──
  static const Color inactive = Color(0xFF3A3A52);
  static const Color inactiveBorder = Color(0xFF4A4A62);

  // ── Per-floor colors (index 0 = floor 1, index 7 = floor 8) ──
  static const List<Color> floorPrimary = [
    Color(0xFF9E8E7E), // 1 – Stone Foundation
    Color(0xFF8D6E63), // 2 – Wooden Hall
    Color(0xFFCC5A3C), // 3 – Brick Chamber
    Color(0xFF4AABFF), // 4 – Crystal Room
    Color(0xFF4CAF50), // 5 – Garden Level
    Color(0xFFEC407A), // 6 – Rose Chamber
    Color(0xFF7E57C2), // 7 – Mystic Floor
    Color(0xFFFFD700), // 8 – Crown Tower
  ];

  static const List<Color> floorSecondary = [
    Color(0xFFBDB1A4),
    Color(0xFFA1887F),
    Color(0xFFE87E5E),
    Color(0xFF87CEEB),
    Color(0xFF81C784),
    Color(0xFFF48FB1),
    Color(0xFFB39DDB),
    Color(0xFFFFE082),
  ];

  static const List<String> floorNames = [
    'Foundation',
    'Wooden Hall',
    'Brick Chamber',
    'Crystal Room',
    'Garden Level',
    'Rose Chamber',
    'Mystic Floor',
    'Crown Tower',
  ];

  static const List<String> floorEmojis = [
    '🏗️',
    '🪵',
    '🧱',
    '💎',
    '🌿',
    '🌸',
    '🔮',
    '👑',
  ];

  static const List<String> floorDecorations = [
    '⚒️',
    '🚪',
    '🪟',
    '✨',
    '🪴',
    '🌹',
    '⭐',
    '💫',
  ];
}
