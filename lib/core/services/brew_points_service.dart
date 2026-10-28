import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrewPointsService {
  BrewPointsService._();
  static final instance = BrewPointsService._();

  static const _brewsKey = 'total_brews_completed_count';
  static const _pourOverKey = 'total_pourover_success_count';
  static const _quizKey = 'total_quiz_success_count';

  final ValueNotifier<int> extraPointsNotifier = ValueNotifier<int>(0);

  int _brewsCount = 0;
  int _pourOverCount = 0;
  int _quizCount = 0;
  bool _isLoaded = false;

  int get brewsCount => _brewsCount;
  int get pourOverCount => _pourOverCount;
  int get quizCount => _quizCount;
  int get totalExtraPoints => extraPointsNotifier.value;

  Future<void> ensureLoaded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _brewsCount = prefs.getInt(_brewsKey) ?? 0;
      _pourOverCount = prefs.getInt(_pourOverKey) ?? 0;
      _quizCount = prefs.getInt(_quizKey) ?? 0;
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
      _isLoaded = true;
    } catch (_) {}
  }

  Future<void> addPourOverPoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isLoaded) {
        _brewsCount = prefs.getInt(_brewsKey) ?? 0;
        _pourOverCount = prefs.getInt(_pourOverKey) ?? 0;
        _quizCount = prefs.getInt(_quizKey) ?? 0;
        _isLoaded = true;
      }
      _pourOverCount++;
      await prefs.setInt(_pourOverKey, _pourOverCount);
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    } catch (_) {
      _pourOverCount++;
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    }
  }

  Future<void> addTimerBrewPoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isLoaded) {
        _brewsCount = prefs.getInt(_brewsKey) ?? 0;
        _pourOverCount = prefs.getInt(_pourOverKey) ?? 0;
        _quizCount = prefs.getInt(_quizKey) ?? 0;
        _isLoaded = true;
      }
      _brewsCount++;
      await prefs.setInt(_brewsKey, _brewsCount);
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    } catch (_) {
      _brewsCount++;
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    }
  }

  Future<void> addQuizPoint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isLoaded) {
        _brewsCount = prefs.getInt(_brewsKey) ?? 0;
        _pourOverCount = prefs.getInt(_pourOverKey) ?? 0;
        _quizCount = prefs.getInt(_quizKey) ?? 0;
        _isLoaded = true;
      }
      _quizCount++;
      await prefs.setInt(_quizKey, _quizCount);
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    } catch (_) {
      _quizCount++;
      extraPointsNotifier.value = _brewsCount + _pourOverCount + _quizCount;
    }
  }
}
