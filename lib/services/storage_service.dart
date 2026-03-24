import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_session.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  SharedPreferences? _prefs;

  /// Notifies listeners when sessions change (e.g. new session saved)
  static final sessionUpdated = ValueNotifier<int>(0);

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p => _prefs!;

  // ── Active sleep session ──

  DateTime? getActiveBedtime() {
    final s = _p.getString('active_bedtime');
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> startSleep(DateTime bedtime) async {
    await _p.setString('active_bedtime', bedtime.toIso8601String());
  }

  Future<void> clearActiveSleep() async {
    await _p.remove('active_bedtime');
  }

  // ── Alarm settings ──

  int getAlarmHour() => _p.getInt('alarm_hour') ?? 7;
  int getAlarmMinute() => _p.getInt('alarm_minute') ?? 0;

  Future<void> setAlarmTime(int hour, int minute) async {
    await _p.setInt('alarm_hour', hour);
    await _p.setInt('alarm_minute', minute);
  }

  bool isAlarmEnabled() => _p.getBool('alarm_enabled') ?? false;

  Future<void> setAlarmEnabled(bool enabled) async {
    await _p.setBool('alarm_enabled', enabled);
  }

  int getSleepGoal() => _p.getInt('sleep_goal') ?? 8;

  Future<void> setSleepGoal(int hours) async {
    await _p.setInt('sleep_goal', hours);
  }

  // ── Sleep session history ──

  List<SleepSession> getSessions() {
    final s = _p.getString('sleep_sessions');
    if (s == null) return [];
    final list = jsonDecode(s) as List<dynamic>;
    return list
        .map((e) => SleepSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSession(SleepSession session) async {
    final sessions = getSessions();
    sessions.insert(0, session);
    // Keep last 365 sessions max
    if (sessions.length > 365) {
      sessions.removeRange(365, sessions.length);
    }
    final json = jsonEncode(sessions.map((e) => e.toJson()).toList());
    await _p.setString('sleep_sessions', json);
    sessionUpdated.value++;
  }

  // ── User profile ──

  String getUserName() => _p.getString('user_name') ?? 'Dream Knight';
  Future<void> setUserName(String name) => _p.setString('user_name', name);

  String? getAvatarPath() => _p.getString('avatar_path');
  Future<void> setAvatarPath(String path) => _p.setString('avatar_path', path);

  int getTotalTowers() => _p.getInt('total_towers') ?? 0;

  Future<void> incrementTotalTowers() async {
    await _p.setInt('total_towers', getTotalTowers() + 1);
  }

  int getCurrentStreak() => _p.getInt('current_streak') ?? 0;
  int getBestStreak() => _p.getInt('best_streak') ?? 0;

  Future<void> updateStreak(bool completed) async {
    if (completed) {
      final newStreak = getCurrentStreak() + 1;
      await _p.setInt('current_streak', newStreak);
      if (newStreak > getBestStreak()) {
        await _p.setInt('best_streak', newStreak);
      }
    } else {
      await _p.setInt('current_streak', 0);
    }
  }

  // ── First launch ──

  bool isFirstLaunch() => _p.getBool('first_launch_done') != true;

  Future<void> setFirstLaunchDone() async {
    await _p.setBool('first_launch_done', true);
  }

  // ── Reset ──

  Future<void> resetAll() async {
    await _p.clear();
  }
}
