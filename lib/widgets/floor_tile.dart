import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

class FloorTile extends StatelessWidget {
  final int floorIndex; // 0-based (0 = floor 1, 7 = floor 8)
  final bool isBuilt;
  final bool isTop;
  final bool isBottom;
  final double width;

  const FloorTile({
    super.key,
    required this.floorIndex,
    required this.isBuilt,
    this.isTop = false,
    this.isBottom = false,
    required this.width,
  });

  // Rainbow gradient colors per floor
  static const _rainbowGradients = [
    [Color(0xFFE57373), Color(0xFFEF5350)], // 0 - Red
    [Color(0xFFFFB74D), Color(0xFFFFA726)], // 1 - Orange
    [Color(0xFFFFD54F), Color(0xFFFFCA28)], // 2 - Yellow
    [Color(0xFF81C784), Color(0xFF66BB6A)], // 3 - Green
    [Color(0xFF4FC3F7), Color(0xFF29B6F6)], // 4 - Light Blue
    [Color(0xFF7986CB), Color(0xFF5C6BC0)], // 5 - Indigo
    [Color(0xFFBA68C8), Color(0xFFAB47BC)], // 6 - Purple
    [Color(0xFFFFD700), Color(0xFFFFC107)], // 7 - Gold crown
  ];

  @override
  Widget build(BuildContext context) {
    final idx = floorIndex.clamp(0, 7);
    final rainbowPrimary = _rainbowGradients[idx][0];
    final rainbowSecondary = _rainbowGradients[idx][1];
    final primary = isBuilt
        ? rainbowPrimary
        : Color.lerp(rainbowPrimary, AppColors.inactive, 0.7)!;
    final secondary = isBuilt
        ? rainbowSecondary
        : Color.lerp(rainbowSecondary, AppColors.inactiveBorder, 0.7)!;
    final name = AppColors.floorNames[idx];
    final emoji = AppColors.floorEmojis[idx];
    final deco = AppColors.floorDecorations[idx];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      width: width,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 16 : 4),
          topRight: Radius.circular(isTop ? 16 : 4),
          bottomLeft: Radius.circular(isBottom ? 10 : 4),
          bottomRight: Radius.circular(isBottom ? 10 : 4),
        ),
        border: Border.all(
          color: isBuilt
              ? rainbowSecondary.withValues(alpha: 0.6)
              : secondary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: isBuilt
            ? [
                BoxShadow(
                  color: rainbowPrimary.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: TextStyle(fontSize: isBuilt ? 22 : 14),
            child: Text(emoji),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isBuilt
                    ? CupertinoColors.black
                    : AppColors.textSecondary.withValues(alpha: 0.4),
                fontSize: 14,
                fontWeight: isBuilt ? FontWeight.w600 : FontWeight.w400,
                shadows: isBuilt
                    ? [
                        Shadow(
                          color:
                              CupertinoColors.white.withValues(alpha: 0.5),
                          blurRadius: 4,
                        )
                      ]
                    : null,
              ),
            ),
          ),
          // Window effect for built floors
          if (isBuilt)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWindow(primary),
                const SizedBox(width: 4),
                _buildWindow(primary),
              ],
            )
          else
            Text(
              '· ·',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.25),
              ),
            ),
          const SizedBox(width: 6),
          Text(
            isBuilt ? deco : '',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildWindow(Color floorColor) {
    return Container(
      width: 12,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.warmOrange, AppColors.lightGold],
        ),
        border: Border.all(
          color: floorColor.withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmOrange.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
