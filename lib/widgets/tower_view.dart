import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import 'floor_tile.dart';
import 'outlined_text.dart';

class TowerView extends StatefulWidget {
  final int floorsBuilt;
  final int totalFloors;

  const TowerView({
    super.key,
    required this.floorsBuilt,
    this.totalFloors = 8,
  });

  @override
  State<TowerView> createState() => _TowerViewState();
}

class _TowerViewState extends State<TowerView>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final towerWidth = screenWidth * 0.78;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Animated floating clouds
          _buildAnimatedClouds(),

          const SizedBox(height: 8),

          // Crown decoration when tower is complete
          if (widget.floorsBuilt >= widget.totalFloors)
            FadeTransition(
              opacity: _sparkleController.drive(
                Tween(begin: 0.7, end: 1.0),
              ),
              child: const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('✨ 👑 ✨', style: TextStyle(fontSize: 30)),
              ),
            ),

          // Flag on top when incomplete
          if (widget.floorsBuilt > 0 &&
              widget.floorsBuilt < widget.totalFloors)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '🚩',
                style: TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.white.withValues(alpha: 0.8),
                ),
              ),
            ),

          // Sparkle particles around tower when complete
          if (widget.floorsBuilt >= widget.totalFloors)
            _buildSparkles(towerWidth),

          // Floors (render from top floor down to floor 1)
          for (int i = widget.totalFloors - 1; i >= 0; i--)
            FloorTile(
              floorIndex: i % 8,
              isBuilt: i < widget.floorsBuilt,
              isTop: i == widget.totalFloors - 1,
              isBottom: i == 0,
              width: towerWidth,
            ),

          // Ground base
          Container(
            width: towerWidth + 28,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.woodBrown, AppColors.stoneBrown],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.woodBrown.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 10)),
            ),
          ),

          const SizedBox(height: 14),

          // Progress bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: (screenWidth - towerWidth) / 2),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.inactive,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  widthFactor: widget.totalFloors > 0
                      ? (widget.floorsBuilt / widget.totalFloors).clamp(0.0, 1.0)
                      : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.floorsBuilt >= widget.totalFloors
                            ? [AppColors.golden, AppColors.warmOrange]
                            : [AppColors.skyBlue, AppColors.deepSky],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Floor counter
          OutlinedText(
            text: '${widget.floorsBuilt} / ${widget.totalFloors} floors built',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            strokeWidth: 3,
            strokeColor: const Color(0x55000000),
          ),

          const SizedBox(height: 6),

          // Completion percentage
          OutlinedText(
            text: _completionMessage(),
            style: const TextStyle(
              color: AppColors.lightGold,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            strokeWidth: 2,
            strokeColor: const Color(0x44000000),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnimatedClouds() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        final offset = _cloudController.value * 12 - 6;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Transform.translate(
              offset: Offset(offset, 0),
              child: Text(
                '☁️',
                style: TextStyle(
                  fontSize: 28,
                  color: CupertinoColors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(-offset * 0.7, 0),
              child: Text(
                '☁️',
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(offset * 0.5, 0),
              child: Text(
                '☁️',
                style: TextStyle(
                  fontSize: 24,
                  color: CupertinoColors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSparkles(double towerWidth) {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final val = _sparkleController.value;
        return SizedBox(
          width: towerWidth + 40,
          height: 20,
          child: Stack(
            children: List.generate(5, (i) {
              final x = (towerWidth + 40) * (i / 4.0);
              final y = sin(val * pi * 2 + i) * 6 + 6;
              return Positioned(
                left: x,
                top: y,
                child: Opacity(
                  opacity: 0.4 + val * 0.5,
                  child: Text(
                    i.isEven ? '✨' : '💫',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  String _completionMessage() {
    if (widget.floorsBuilt >= widget.totalFloors) return '🎉 Tower Complete!';
    if (widget.floorsBuilt == 0) return '🌙 Start sleeping to build!';
    final pct = ((widget.floorsBuilt / widget.totalFloors) * 100).round();
    return '$pct% complete — keep going!';
  }
}
