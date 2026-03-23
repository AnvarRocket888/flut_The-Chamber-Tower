import 'package:flutter/cupertino.dart';
import '../theme/app_colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = <_TutorialPage>[
    _TutorialPage(
      emoji: '🏰',
      title: 'Welcome to The Chamber Tower',
      description:
          'Build your personal sleep tower, floor by floor!\n\n'
          'Each night of good sleep adds a new floor to your tower. '
          'Stay consistent and watch it grow.',
    ),
    _TutorialPage(
      emoji: '🌙',
      title: 'Start Your Sleep',
      description:
          'On the Tower tab, tap "Go to Sleep" when you\'re ready for bed.\n\n'
          'The app tracks how long you sleep. '
          'Each hour earns a floor of your tower.',
    ),
    _TutorialPage(
      emoji: '⏰',
      title: 'Set Your Alarm',
      description:
          'Use the Alarm tab to set your wake-up time and sleep goal.\n\n'
          'A consistent schedule helps your body clock '
          'and lets you build taller towers.',
    ),
    _TutorialPage(
      emoji: '📸',
      title: 'Morning Selfie & Dream Notes',
      description:
          'When you wake up, take a morning selfie and write down your dreams.\n\n'
          'Track how you look and feel over time — '
          'all saved in your History.',
    ),
    _TutorialPage(
      emoji: '📊',
      title: 'Track Your Progress',
      description:
          'The History tab shows all your past sessions with details.\n\n'
          'See your sleep patterns, review dream notes, '
          'and browse your selfie gallery.',
    ),
    _TutorialPage(
      emoji: '🏆',
      title: 'Earn Achievements',
      description:
          'Unlock achievements by building towers and maintaining streaks!\n\n'
          'Check your Profile and Settings to see stats, '
          'rank, and unlocked badges.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('How to Use'),
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
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 72),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.golden,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.golden
                          : AppColors.inactive,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: _currentPage > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: _currentPage > 0
                              ? AppColors.skyBlue
                              : AppColors.inactive,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Done',
                        style: const TextStyle(
                          color: AppColors.golden,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialPage {
  final String emoji;
  final String title;
  final String description;

  const _TutorialPage({
    required this.emoji,
    required this.title,
    required this.description,
  });
}
