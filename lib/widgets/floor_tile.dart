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

  @override
  Widget build(BuildContext context) {
    final idx = floorIndex.clamp(0, 7);
    final primary =
        isBuilt ? AppColors.floorPrimary[idx] : AppColors.inactive;
    final secondary =
        isBuilt ? AppColors.floorSecondary[idx] : AppColors.inactiveBorder;
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
              ? secondary.withValues(alpha: 0.6)
              : AppColors.inactiveBorder,
          width: 1.5,
        ),
        boxShadow: isBuilt
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
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
                    ? CupertinoColors.white
                    : AppColors.textSecondary.withValues(alpha: 0.4),
                fontSize: 14,
                fontWeight: isBuilt ? FontWeight.w600 : FontWeight.w400,
                shadows: isBuilt
                    ? [
                        Shadow(
                          color:
                              CupertinoColors.black.withValues(alpha: 0.5),
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
