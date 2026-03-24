import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';
import '../services/storage_service.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeScreen({super.key, required this.onComplete});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleUp = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await StorageService().setFirstLaunchDone();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              AppColors.deepPurple,
              AppColors.nightBlue,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleUp,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Tower emoji
                    const Text('🏰', style: TextStyle(fontSize: 80)),
                    const SizedBox(height: 20),

                    // App name
                    const Text(
                      'The Chamber Tower',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.golden,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Build your sleep tower,\nfloor by floor, night by night',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 17,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Feature highlights
                    _featureRow('🌙', 'Track your sleep every night'),
                    const SizedBox(height: 14),
                    _featureRow('🧱', 'Each hour = one tower floor'),
                    const SizedBox(height: 14),
                    _featureRow('⏰', 'Set alarms to wake up on time'),
                    const SizedBox(height: 14),
                    _featureRow('🏆', 'Earn streaks and achievements'),

                    const Spacer(flex: 3),

                    // Start button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        color: AppColors.golden,
                        borderRadius: BorderRadius.circular(18),
                        onPressed: _finish,
                        child: const Text(
                          'Start Building 🏗️',
                          style: TextStyle(
                            color: AppColors.nightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
