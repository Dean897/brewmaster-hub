import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

class BrewTimerService extends ChangeNotifier {
  BrewTimerService._();

  static final instance = BrewTimerService._();

  static const _remainingKey = 'brew_timer_remaining_seconds';
  static const _durationKey = 'brew_timer_duration_seconds';
  static const _endTimeKey = 'brew_timer_end_time';
  static const _runningKey = 'brew_timer_is_running';

  final _notificationService = NotificationService.instance;
  Timer? _ticker;
  SharedPreferences? _preferences;
  int _remainingSeconds = 180;
  int _durationSeconds = 180;
  DateTime? _endTime;
  bool _isRunning = false;
  int _completionCount = 0;

  int get remainingSeconds {
    if (!_isRunning || _endTime == null) {
      return _remainingSeconds;
    }

    final milliseconds = _endTime!.difference(DateTime.now()).inMilliseconds;
    return (milliseconds / 1000).ceil().clamp(0, _durationSeconds);
  }

  int get durationSeconds => _durationSeconds;
  bool get isRunning => _isRunning;
  int get completionCount => _completionCount;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _remainingSeconds =
        _preferences?.getInt(_remainingKey) ?? _remainingSeconds;
    _durationSeconds = _preferences?.getInt(_durationKey) ?? _durationSeconds;

    final endTimeMilliseconds = _preferences?.getInt(_endTimeKey);
    final wasRunning = _preferences?.getBool(_runningKey) ?? false;
    if (wasRunning && endTimeMilliseconds != null) {
      _endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMilliseconds);
      if (_endTime!.isAfter(DateTime.now())) {
        _isRunning = true;
        _startTicker();
        await _notificationService.scheduleTimerCompletion(_endTime!);
        return;
      }

      _remainingSeconds = 0;
      _isRunning = false;
      await _clearRunningState();
    }
  }

  Future<void> start() async {
    if (_isRunning || remainingSeconds <= 0) {
      return;
    }

    _remainingSeconds = remainingSeconds;
    _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _isRunning = true;
    _startTicker();
    notifyListeners();

    await _saveState();
    await _notificationService.scheduleTimerCompletion(_endTime!);
  }

  Future<void> pause() async {
    if (!_isRunning) {
      return;
    }

    _remainingSeconds = remainingSeconds;
    _isRunning = false;
    _endTime = null;
    _ticker?.cancel();
    _ticker = null;
    await _notificationService.cancelTimerCompletion();
    await _saveState();
    notifyListeners();
  }

  Future<void> reset() async {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _endTime = null;
    _remainingSeconds = _durationSeconds;
    await _notificationService.cancelTimerCompletion();
    await _saveState();
    notifyListeners();
  }

  Future<void> updateDuration({
    required int minutes,
    required int seconds,
  }) async {
    if (_isRunning) {
      return;
    }

    _durationSeconds = (minutes * 60) + seconds;
    _remainingSeconds = _durationSeconds;
    await _saveState();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds = remainingSeconds;
      if (_remainingSeconds <= 0) {
        _complete();
        return;
      }
      notifyListeners();
    });
  }

  Future<void> _complete() async {
    _ticker?.cancel();
    _ticker = null;
    _remainingSeconds = 0;
    _isRunning = false;
    _endTime = null;
    _completionCount++;
    await _clearRunningState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    await preferences.setInt(_remainingKey, _remainingSeconds);
    await preferences.setInt(_durationKey, _durationSeconds);
    await preferences.setBool(_runningKey, _isRunning);
    if (_endTime == null) {
      await preferences.remove(_endTimeKey);
    } else {
      await preferences.setInt(_endTimeKey, _endTime!.millisecondsSinceEpoch);
    }
  }

  Future<void> _clearRunningState() async {
    _remainingSeconds = _remainingSeconds.clamp(0, _durationSeconds);
    await _saveState();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
