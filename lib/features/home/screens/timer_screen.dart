import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../../core/services/brew_timer_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _timerService = BrewTimerService.instance;
  int _selectedMinutes = 3;
  int _selectedSeconds = 0;
  int _lastCompletionCount = 0;

  String _formattedTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _selectedMinutes = _timerService.durationSeconds ~/ 60;
    _selectedSeconds = _timerService.durationSeconds % 60;
    _lastCompletionCount = _timerService.completionCount;
    _timerService.addListener(_handleTimerChanged);
  }

  void _handleTimerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    if (_timerService.completionCount != _lastCompletionCount) {
      _lastCompletionCount = _timerService.completionCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FlutterRingtonePlayer().playAlarm();
          _showFinishedDialog();
        }
      });
    }
  }

  Future<void> _updateDuration() {
    return _timerService.updateDuration(
      minutes: _selectedMinutes,
      seconds: _selectedSeconds,
    );
  }

  Future<void> _showFinishedDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Waktu Seduh Selesai!'),
          content: const Text('Kopi Anda sudah siap.'),
          actions: [
            FilledButton(
              onPressed: () {
                FlutterRingtonePlayer().stop();
                NotificationService.instance.cancelTimerCompletion();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkCoffee,
                foregroundColor: AppColors.ivoryWhite,
              ),
              child: const Text('Matikan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timerService.removeListener(_handleTimerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _timerService.isRunning;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Seduh'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                _formattedTime(_timerService.remainingSeconds),
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DurationPicker(
                    label: 'Menit',
                    value: _selectedMinutes,
                    values: List.generate(60, (index) => index),
                    onChanged: isRunning
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _selectedMinutes = value);
                            _updateDuration();
                          },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: AppColors.darkCoffee,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _DurationPicker(
                    label: 'Detik',
                    value: _selectedSeconds,
                    values: List.generate(60, (index) => index),
                    onChanged: isRunning
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _selectedSeconds = value);
                            _updateDuration();
                          },
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: isRunning ? null : _timerService.start,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.darkCoffee,
                        foregroundColor: AppColors.ivoryWhite,
                      ),
                      child: const Text('Mulai'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isRunning ? _timerService.pause : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkCoffee,
                        side: const BorderSide(color: AppColors.mediumCoffee),
                      ),
                      child: const Text('Jeda'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _timerService.reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkCoffee,
                        side: const BorderSide(color: AppColors.mediumCoffee),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> values;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.mediumCoffee)),
        DropdownButton<int>(
          value: value,
          dropdownColor: AppColors.ivoryWhite,
          style: const TextStyle(color: AppColors.darkCoffee, fontSize: 18),
          items: values
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item,
                  child: Text(item.toString().padLeft(2, '0')),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
