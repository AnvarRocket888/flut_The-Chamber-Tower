import 'package:flutter/cupertino.dart';
import 'theme/app_colors.dart';
import 'screens/tower_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/storage_service.dart';

class ClearApp extends StatelessWidget {
  const ClearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'The Chamber Tower',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.golden,
      ),
      home: const AppEntry(),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _showWelcome = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final storage = StorageService();
    await storage.init();
    setState(() {
      _showWelcome = storage.isFirstLaunch();
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }
    if (_showWelcome) {
      return WelcomeScreen(
        onComplete: () => setState(() => _showWelcome = false),
      );
    }
    return const MainScreen();
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.nightBlue.withValues(alpha: 0.95),
        activeColor: AppColors.golden,
        inactiveColor: AppColors.textSecondary,
        border: Border(
          top: BorderSide(
            color: AppColors.golden.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Tower',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'Alarm',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const TowerScreen();
              case 1:
                return const AlarmScreen();
              case 2:
                return const HistoryScreen();
              case 3:
                return const ProfileScreen();
              default:
                return const TowerScreen();
            }
          },
        );
      },
    );
  }
}
