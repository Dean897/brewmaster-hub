import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';

class PourOverScreen extends StatefulWidget {
  const PourOverScreen({super.key});

  @override
  State<PourOverScreen> createState() => _PourOverScreenState();
}

class _PourOverScreenState extends State<PourOverScreen> {
  static const _gameDuration = 10;
  static const _maxGlassVolume = 350.0;
  static const _pourRate = 3.5;

  final _random = Random();
  double _waterPoured = 0.0;
  int _timeRemaining = _gameDuration;
  int? _targetVolume;
  bool _isPouring = false;
  bool _isGameRunning = false;
  Timer? _countdownTimer;
  Timer? _pouringTimer;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  DateTime? _lastGyroscopeUpdate;

  void _startGame() {
    if (_isGameRunning) {
      return;
    }

    _countdownTimer?.cancel();
    _pouringTimer?.cancel();
    setState(() {
      _waterPoured = 0;
      _timeRemaining = _gameDuration;
      _targetVolume = 150 + _random.nextInt(151);
      _isPouring = false;
      _isGameRunning = true;
    });
    _startGyroscope();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining <= 1) {
        _finishGame();
        return;
      }

      setState(() {
        _timeRemaining--;
      });
    });
  }

  void _startGyroscope() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription =
        gyroscopeEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen(
          (event) {
            if (!_isGameRunning) {
              return;
            }

            final now = DateTime.now();
            final lastUpdate = _lastGyroscopeUpdate;
            if (lastUpdate != null &&
                now.difference(lastUpdate) < const Duration(milliseconds: 90)) {
              return;
            }
            _lastGyroscopeUpdate = now;

            final tilt = sqrt(event.x * event.x + event.y * event.y);
            if (tilt < 0.18 || !mounted) {
              return;
            }

            setState(() {
              _waterPoured = min(
                _maxGlassVolume,
                _waterPoured + max(0.8, tilt * 1.8),
              );
            });
          },
          onError: (_) {
            // The press-and-hold control remains available when a sensor is absent.
          },
        );
  }

  void _startPouring() {
    if (!_isGameRunning || _isPouring) {
      return;
    }

    setState(() {
      _isPouring = true;
    });

    _pouringTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isGameRunning) {
        _stopPouring();
        return;
      }

      setState(() {
        _waterPoured += _pourRate;
      });
    });
  }

  void _stopPouring() {
    _pouringTimer?.cancel();
    _pouringTimer = null;

    if (mounted && _isPouring) {
      setState(() {
        _isPouring = false;
      });
    }
  }

  void _finishGame() {
    if (!_isGameRunning) {
      return;
    }

    _countdownTimer?.cancel();
    _countdownTimer = null;
    _stopPouring();

    setState(() {
      _timeRemaining = 0;
      _isGameRunning = false;
    });

    _showResult();
  }

  Future<void> _showResult() async {
    final target = _targetVolume ?? 0;
    final difference = (_waterPoured - target).abs();
    final isSuccessful = difference <= 10;

    if (isSuccessful) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final current = prefs.getInt('total_pourover_success_count') ?? 0;
        await prefs.setInt('total_pourover_success_count', current + 1);
      } catch (_) {}
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isSuccessful ? 'Berhasil!' : 'Gagal!'),
          content: Text(
            'Target: $target ml\n'
            'Tuangan: ${_waterPoured.toStringAsFixed(0)} ml\n'
            'Selisih: ${difference.toStringAsFixed(0)} ml',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkCoffee,
                foregroundColor: AppColors.ivoryWhite,
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pouringTimer?.cancel();
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = _targetVolume;
    final waterHeight = (_waterPoured / _maxGlassVolume).clamp(0.0, 1.0) * 260;
    final targetPosition = target == null
        ? null
        : (target / _maxGlassVolume).clamp(0.0, 1.0) * 260;

    return Scaffold(
      appBar: coffeeAppBar(title: 'Pour-Over Challenge'),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                target == null ? 'Target: -' : 'Target: $target ml',
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sisa Waktu: $_timeRemaining detik',
                style: const TextStyle(
                  color: AppColors.mediumCoffee,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 170,
                    height: 280,
                    child: Stack(
                      children: [
                        Container(
                          width: 170,
                          height: 280,
                          decoration: BoxDecoration(
                            color: AppColors.ivoryWhite.withValues(alpha: 0.5),
                            border: Border.all(
                              color: AppColors.darkCoffee,
                              width: 3,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                              top: Radius.circular(8),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 3,
                          right: 3,
                          bottom: 3,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: waterHeight,
                            decoration: const BoxDecoration(
                              color: AppColors.mediumCoffee,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20),
                                top: Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                        if (targetPosition != null)
                          Positioned(
                            bottom: targetPosition + 3,
                            left: 3,
                            right: 3,
                            child: Container(
                              height: 3,
                              color: AppColors.darkCoffee,
                            ),
                          ),
                        if (targetPosition != null)
                          Positioned(
                            bottom: targetPosition + 8,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              color: AppColors.lightCream,
                              child: Text(
                                '$target ml',
                                style: const TextStyle(
                                  color: AppColors.darkCoffee,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Text(
                            '${_waterPoured.toStringAsFixed(0)} ml',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.ivoryWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isGameRunning)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton(
                    onPressed: _finishGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkCoffee,
                      foregroundColor: AppColors.ivoryWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Berhenti Tuang'),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton(
                    onPressed: _startGame,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.mediumCoffee,
                      foregroundColor: AppColors.ivoryWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                    ),
                    child: const Text('Mulai'),
                  ),
                ),
              if (_isGameRunning)
                GestureDetector(
                  onTapDown: (_) => _startPouring(),
                  onTapUp: (_) => _stopPouring(),
                  onTapCancel: _stopPouring,
                  child: Container(
                    width: 150,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: _isPouring
                          ? AppColors.darkCoffee
                          : AppColors.mediumCoffee,
                    ),
                    child: Center(
                      child: Text(
                        _isPouring ? 'Tuang...' : 'Tekan untuk Tuang',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.ivoryWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
