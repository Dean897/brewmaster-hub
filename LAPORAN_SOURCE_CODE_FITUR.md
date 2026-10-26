# Source Code Lengkap Fitur BrewMaster Hub

Dokumen ini berisi salinan lengkap source code dari file fitur yang diminta.

## gacha_screen.dart

Lokasi file: `lib/features/minigames/screens/gacha_screen.dart`

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with SingleTickerProviderStateMixin {
  static const _shakeThreshold = 15.0;
  static const _shakeDebounceDuration = Duration(seconds: 1);

  final _random = Random();
  final _recipes = const [
    'V60 Japanese Iced',
    'Espresso Tonic',
    'Cold Brew',
    'Caramel Macchiato',
  ];

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _shakeDebounceTimer;
  late final AnimationController _particleController;
  String? _selectedRecipe;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _listenToAccelerometer();
  }

  void _listenToAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final isAboveThreshold =
          event.x.abs() > _shakeThreshold ||
          event.y.abs() > _shakeThreshold ||
          event.z.abs() > _shakeThreshold;

      if (isAboveThreshold && !_isShaking) {
        _isShaking = true;
        _showRandomRecipe();
        _shakeDebounceTimer = Timer(_shakeDebounceDuration, () {
          _isShaking = false;
        });
      }
    });
  }

  void _showRandomRecipe() {
    setState(() {
      _selectedRecipe = _recipes[_random.nextInt(_recipes.length)];
    });
    _particleController.forward(from: 0);
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _shakeDebounceTimer?.cancel();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: coffeeAppBar(title: 'Kocok Resep'),
      backgroundColor: AppColors.ivoryWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.screen_rotation,
                color: AppColors.mediumCoffee,
                size: 96,
              ),
              const SizedBox(height: 24),
              const Text(
                'Kocok HP Anda untuk mendapatkan resep acak!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _showRandomRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: AppColors.darkCoffee,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text('Simulasikan Kocok HP (Untuk Test Web)'),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _selectedRecipe == null
                    ? const SizedBox(key: ValueKey('empty-recipe'), height: 120)
                    : Card(
                        key: ValueKey(_selectedRecipe),
                        color: AppColors.lightCream,
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Text(
                                    'Resep Anda:',
                                    style: TextStyle(
                                      color: AppColors.mediumCoffee,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedRecipe!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.darkCoffee,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _particleController,
                                  builder: (context, child) => CustomPaint(
                                    painter: _SurpriseParticlePainter(
                                      progress: _particleController.value,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurpriseParticlePainter extends CustomPainter {
  const _SurpriseParticlePainter({required this.progress});

  final double progress;

  static const _colors = [
    AppColors.darkCoffee,
    AppColors.mediumCoffee,
    AppColors.ivoryWhite,
    Color(0xFFD6A85F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var index = 0; index < 24; index++) {
      final angle = (index * 2.399) + (index.isEven ? 0.2 : -0.2);
      final distance = 12 + (progress * (36 + (index % 5) * 9));
      final drift = ((index % 3) - 1) * progress * 10;
      final position = Offset(
        center.dx + cos(angle) * distance + drift,
        center.dy + sin(angle) * distance + progress * progress * 18,
      );
      final radius = (2 + (index % 3) * 1.2) * fade;
      paint.color = _colors[index % _colors.length].withValues(
        alpha: fade * 0.95,
      );

      if (index.isEven) {
        canvas.drawCircle(position, radius, paint);
      } else {
        final rect = Rect.fromCenter(
          center: position,
          width: radius * 1.4,
          height: radius * 2.8,
        );
        canvas.save();
        canvas.translate(position.dx, position.dy);
        canvas.rotate(angle);
        canvas.translate(-position.dx, -position.dy);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(radius)),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_SurpriseParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
```

## pour_over_screen.dart

Lokasi file: `lib/features/minigames/screens/pour_over_screen.dart`

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
```

## tebak_kopi_screen.dart

Lokasi file: `lib/features/minigames/screens/tebak_kopi_screen.dart`

```dart
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/db_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';

class Question {
  const Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromDatabase(Map<String, dynamic> row) {
    final correctAnswer = row['correct_answer'] as String;
    final correctOption = switch (correctAnswer) {
      'A' => row['option_a'] as String,
      'B' => row['option_b'] as String,
      'C' => row['option_c'] as String,
      'D' => row['option_d'] as String,
      _ => correctAnswer,
    };

    final options = [
      row['option_a'] as String,
      row['option_b'] as String,
      row['option_c'] as String,
      row['option_d'] as String,
    ]..shuffle(Random());

    return Question(
      question: row['question'] as String,
      options: options,
      correctAnswer: correctOption,
    );
  }

  final String question;
  final List<String> options;
  final String correctAnswer;
}

class TebakKopiScreen extends StatefulWidget {
  const TebakKopiScreen({super.key});

  @override
  State<TebakKopiScreen> createState() => _TebakKopiScreenState();
}

class _TebakKopiScreenState extends State<TebakKopiScreen>
    with SingleTickerProviderStateMixin {
  static const _questionLimit = 10;
  static const _questionDuration = 10;

  List<Question> _sessionQuestions = [];
  Timer? _countdownTimer;
  int _currentIndex = 0;
  int _remainingSeconds = _questionDuration;
  int _totalScore = 0;
  bool _isLoading = true;
  bool _isAnswering = false;
  String? _loadingError;
  String? _selectedAnswer;
  late final AnimationController _wrongAnswerController;
  late final Animation<double> _wrongAnswerOffset;

  @override
  void initState() {
    super.initState();
    _wrongAnswerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _wrongAnswerOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -7), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7, end: 5), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5, end: -3), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3, end: 0), weight: 1),
    ]).animate(_wrongAnswerController);
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _loadingError = null;
    });

    try {
      final rows = await DbHelper.instance.getQuestions(limit: _questionLimit);
      if (!mounted) {
        return;
      }

      final questions = rows.map(Question.fromDatabase).toList();
      setState(() {
        _sessionQuestions = questions;
        _currentIndex = 0;
        _totalScore = 0;
        _isAnswering = false;
        _selectedAnswer = null;
        _isLoading = false;
      });
      if (_sessionQuestions.isNotEmpty) {
        _startCountdown();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingError = 'Gagal memuat pertanyaan: $error';
        _isLoading = false;
      });
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = _questionDuration;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _countdownTimer?.cancel();
        _submitAnswer(null);
        return;
      }
      if (mounted) {
        setState(() => _remainingSeconds--);
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submitAnswer(String? answer) async {
    if (_isAnswering || !mounted) {
      return;
    }

    _isAnswering = true;
    _countdownTimer?.cancel();
    final question = _sessionQuestions[_currentIndex];
    _selectedAnswer = answer;
    if (answer == question.correctAnswer) {
      _totalScore += _remainingSeconds * 10;
    } else if (answer != null) {
      unawaited(HapticFeedback.heavyImpact());
      _wrongAnswerController.forward(from: 0);
    }
    setState(() {});

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }

    if (_currentIndex == _sessionQuestions.length - 1) {
      await _showHighScore();
      return;
    }

    _currentIndex++;
    _isAnswering = false;
    _selectedAnswer = null;
    _startCountdown();
  }

  Future<void> _showHighScore() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ivoryWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.lightCream),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.lightCream,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ivoryWhite, width: 3),
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: AppColors.darkCoffee,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Permainan Selesai!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkCoffee,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.lightCream),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Skor',
                    style: TextStyle(color: AppColors.mediumCoffee),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_totalScore',
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _fetchQuestions();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCoffee,
                  foregroundColor: AppColors.ivoryWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Main Lagi'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(this.context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkCoffee,
                  side: const BorderSide(color: AppColors.lightCream),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return coffeeAppBar(title: 'Tebak Kopi Arcade');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _wrongAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        appBar: _buildAppBar(),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mediumCoffee),
        ),
      );
    }

    if (_loadingError != null) {
      return Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadingError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.darkCoffee),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _fetchQuestions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkCoffee,
                    foregroundColor: AppColors.ivoryWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        appBar: _buildAppBar(),
        body: const Center(
          child: Text(
            'Belum ada pertanyaan yang tersedia.',
            style: TextStyle(color: AppColors.darkCoffee),
          ),
        ),
      );
    }

    final question = _sessionQuestions[_currentIndex];
    final progress = _remainingSeconds / _questionDuration;

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 44,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatusPill(
                        icon: Icons.coffee_outlined,
                        label: 'Soal ${_currentIndex + 1}/$_questionLimit',
                      ),
                      _StatusPill(
                        icon: Icons.star_rounded,
                        label: 'Skor: $_totalScore',
                        highlighted: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.lightCream),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkCoffee.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: AppColors.lightCream,
                            color: AppColors.mediumCoffee,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              color: AppColors.mediumCoffee,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Waktu: $_remainingSeconds detik',
                              style: const TextStyle(
                                color: AppColors.darkCoffee,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.lightCream),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkCoffee.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(
                            Icons.coffee_maker_outlined,
                            size: 42,
                            color: AppColors.lightCream,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PERTANYAAN',
                              style: TextStyle(
                                color: AppColors.mediumCoffee,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(right: 28),
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  color: AppColors.darkCoffee,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  AnimatedBuilder(
                    animation: _wrongAnswerController,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_wrongAnswerOffset.value, 0),
                      child: child,
                    ),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < question.options.length;
                          index++
                        ) ...[
                          _AnswerOption(
                            index: index,
                            text: question.options[index],
                            isCorrectAnswer:
                                _isAnswering &&
                                question.options[index] ==
                                    question.correctAnswer,
                            isSelectedWrong:
                                _isAnswering &&
                                question.options[index] == _selectedAnswer &&
                                _selectedAnswer != question.correctAnswer,
                            onTap: _isAnswering
                                ? null
                                : () => _submitAnswer(question.options[index]),
                          ),
                          if (index != question.options.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.darkCoffee : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? AppColors.darkCoffee : AppColors.lightCream,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlighted ? AppColors.lightCream : AppColors.mediumCoffee,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.ivoryWhite : AppColors.darkCoffee,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.text,
    required this.onTap,
    required this.isCorrectAnswer,
    required this.isSelectedWrong,
  });

  final int index;
  final String text;
  final VoidCallback? onTap;
  final bool isCorrectAnswer;
  final bool isSelectedWrong;

  @override
  Widget build(BuildContext context) {
    final label = String.fromCharCode(65 + index);
    final backgroundColor = isCorrectAnswer
        ? const Color(0xFFE9F8F1)
        : isSelectedWrong
        ? const Color(0xFFFFF0F1)
        : Colors.white;
    final borderColor = isCorrectAnswer
        ? const Color(0xFF20B989)
        : isSelectedWrong
        ? const Color(0xFFFF1744)
        : AppColors.lightCream;
    final badgeColor = isCorrectAnswer
        ? const Color(0xFF20B989)
        : isSelectedWrong
        ? const Color(0xFFE91E4D)
        : AppColors.lightCream;
    final badgeTextColor = isCorrectAnswer || isSelectedWrong
        ? Colors.white
        : AppColors.darkCoffee;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ).copyWith(color: badgeTextColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.darkCoffee,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## news_tab.dart

Lokasi file: `lib/features/news/screens/news_tab.dart`

```dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/coffee_app_bar.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  static const _ratesUrl =
      'https://api.frankfurter.dev/v1/latest?base=USD&symbols=IDR,EUR,JPY,GBP';
  static const _feedUrl = 'https://dailycoffeenews.com/feed/';

  static const _basePrices = <String, double>{'Arabica': 5.40, 'Robusta': 2.80};

  static const _currencies = <String, String>{
    'USD': 'USD',
    'IDR': 'IDR',
    'EUR': 'EUR',
    'JPY': 'JPY',
  };

  static final _events = [
    CoffeeEvent(
      title: 'Jakarta Coffee Week',
      location: 'JIExpo',
      utcDate: DateTime.utc(2026, 10, 24, 3),
    ),
    CoffeeEvent(
      title: 'Webinar Latte Art',
      location: 'Zoom',
      utcDate: DateTime.utc(2026, 11, 12, 12),
    ),
    CoffeeEvent(
      title: 'Brew Innovation Forum',
      location: 'Bandung',
      utcDate: DateTime.utc(2026, 12, 5, 2),
    ),
  ];

  static const _webFallbackRates = <String, double>{
    'USD': 1,
    'IDR': 16800,
    'EUR': 0.86,
    'JPY': 159,
  };

  static const _webFallbackArticles = <NewsPreview>[
    NewsPreview(
      title: 'Daily Coffee News',
      description:
          'Berita kopi terbaru tersedia saat akses RSS browser diizinkan.',
    ),
    NewsPreview(
      title: 'Jelajahi dunia kopi',
      description:
          'Buka aplikasi Android/iOS untuk memuat RSS Daily Coffee News secara langsung.',
    ),
  ];

  Map<String, double> _rates = _webFallbackRates;
  List<RssItem> _articles = [];
  List<NewsPreview> _fallbackArticles = [];
  String _selectedCurrency = 'IDR';
  int _selectedUtcOffset = 7;
  bool _isLoadingRates = true;
  bool _isLoadingNews = true;
  String? _ratesError;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    _fetchRates();
    _fetchNews();
  }

  Future<void> _fetchRates() async {
    try {
      final response = await http.get(Uri.parse(_ratesUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = response.body;
      final decoded = _decodeJsonObject(body);
      final rawRates = decoded['rates'];
      if (rawRates is! Map) {
        throw const FormatException('Format kurs tidak valid');
      }

      final rates = <String, double>{'USD': 1};
      for (final currency in _currencies.keys) {
        if (currency == 'USD') {
          continue;
        }
        final value = rawRates[currency];
        if (value is num) {
          rates[currency] = value.toDouble();
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _rates = rates;
        _isLoadingRates = false;
        _ratesError = null;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRates = false;
        _ratesError = kIsWeb
            ? null
            : 'Harga dan kurs tidak dapat dimuat: $error';
        if (kIsWeb) {
          _rates = _webFallbackRates;
        }
      });
    }
  }

  Future<void> _fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_feedUrl));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final feed = RssFeed.parse(response.body);
      final articles = (feed.items ?? []).take(5).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _articles = articles;
        _fallbackArticles = [];
        _isLoadingNews = false;
        _newsError = null;
      });
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingNews = false;
        _newsError = kIsWeb ? null : 'Berita tidak dapat dimuat: $error';
        if (kIsWeb) {
          _fallbackArticles = _webFallbackArticles;
        }
      });
    }
  }

  Map<String, dynamic> _decodeJsonObject(String source) {
    final value = const JsonDecoder().convert(source);
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw const FormatException('Respons kurs bukan object JSON');
  }

  double _priceFor(String product) {
    final basePrice = _basePrices[product] ?? 0;
    return basePrice * (_rates[_selectedCurrency] ?? 1);
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      name: _selectedCurrency,
      decimalDigits: _selectedCurrency == 'IDR' ? 0 : 2,
    ).format(price);
  }

  DateTime _localEventDate(DateTime utcDate) {
    return utcDate.add(Duration(hours: _selectedUtcOffset));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: coffeeAppBar(title: 'Info Global'),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([_fetchRates(), _fetchNews()]);
        },
        color: AppColors.mediumCoffee,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _buildPriceCard(),
            const SizedBox(height: 28),
            _buildEventsSection(),
            const SizedBox(height: 28),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.darkCoffee,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCoffee.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Harga Biji Global',
                  style: TextStyle(
                    color: AppColors.ivoryWhite,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedCurrency,
                dropdownColor: AppColors.darkCoffee,
                underline: const SizedBox.shrink(),
                iconEnabledColor: AppColors.ivoryWhite,
                style: const TextStyle(color: AppColors.ivoryWhite),
                items: _currencies.keys
                    .map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      ),
                    )
                    .toList(),
                onChanged: (currency) {
                  if (currency != null) {
                    setState(() => _selectedCurrency = currency);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoadingRates)
            const Center(
              child: CircularProgressIndicator(color: AppColors.lightCream),
            )
          else if (_ratesError != null)
            Text(
              _ratesError!,
              style: const TextStyle(color: AppColors.lightCream),
            )
          else
            Row(
              children: [
                Expanded(child: _buildPriceTile('Arabica')),
                const SizedBox(width: 14),
                Expanded(child: _buildPriceTile('Robusta')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPriceTile(String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumCoffee.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name (kg)',
            style: const TextStyle(color: AppColors.ivoryWhite, fontSize: 16),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatPrice(_priceFor(name)),
              style: const TextStyle(
                color: AppColors.ivoryWhite,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name == 'Arabica' ? '▲ Base USD 5.40' : '▲ Base USD 2.80',
            style: const TextStyle(color: Colors.lightGreenAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Event & Webinar',
                style: TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownButton<int>(
              value: _selectedUtcOffset,
              underline: const SizedBox.shrink(),
              style: const TextStyle(color: AppColors.darkCoffee),
              items: const [
                DropdownMenuItem(value: 7, child: Text('WIB')),
                DropdownMenuItem(value: 8, child: Text('WITA')),
                DropdownMenuItem(value: 9, child: Text('WIT')),
                DropdownMenuItem(value: 0, child: Text('UTC')),
              ],
              onChanged: (offset) {
                if (offset != null) {
                  setState(() => _selectedUtcOffset = offset);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final event in _events) ...[
          _buildEventTile(event),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildEventTile(CoffeeEvent event) {
    final localDate = _localEventDate(event.utcDate);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.mediumCoffee.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormat('MMM').format(localDate).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${localDate.day}',
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${DateFormat('dd MMM yyyy - HH:mm').format(localDate)} '
                    '· ${event.location}',
                    style: const TextStyle(color: AppColors.mediumCoffee),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Berita Terkini',
          style: TextStyle(
            color: AppColors.darkCoffee,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingNews)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.mediumCoffee),
            ),
          )
        else if (_newsError != null)
          _buildErrorMessage(_newsError!, _fetchNews)
        else if (_articles.isEmpty && _fallbackArticles.isEmpty)
          const Text(
            'Belum ada berita yang tersedia.',
            style: TextStyle(color: AppColors.mediumCoffee),
          )
        else if (_articles.isNotEmpty)
          for (final article in _articles) _buildNewsTile(article)
        else
          for (final article in _fallbackArticles)
            _buildFallbackNewsTile(article),
      ],
    );
  }

  Widget _buildNewsTile(RssItem article) {
    final title = article.title?.trim();
    final description = _cleanDescription(article.description);
    final date = article.pubDate == null
        ? 'Tanggal tidak tersedia'
        : DateFormat('dd MMM yyyy - HH:mm').format(article.pubDate!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.mediumCoffee,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.coffee,
            color: AppColors.lightCream,
            size: 34,
          ),
        ),
        title: Text(
          title == null || title.isEmpty ? 'Berita tanpa judul' : title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkCoffee,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            '$date\n${description.isEmpty ? 'Baca berita selengkapnya di Daily Coffee News.' : description}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.mediumCoffee),
          ),
        ),
        onTap: article.link == null
            ? null
            : () => _showArticleLink(article.link!),
      ),
    );
  }

  Widget _buildFallbackNewsTile(NewsPreview article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.mediumCoffee,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.coffee,
            color: AppColors.lightCream,
            size: 34,
          ),
        ),
        title: Text(
          article.title,
          style: const TextStyle(
            color: AppColors.darkCoffee,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            article.description,
            style: const TextStyle(color: AppColors.mediumCoffee),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, VoidCallback retry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: const TextStyle(color: Colors.red)),
        TextButton(onPressed: retry, child: const Text('Coba lagi')),
      ],
    );
  }

  String _cleanDescription(String? description) {
    if (description == null) {
      return '';
    }
    return description
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showArticleLink(String link) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka Berita'),
        content: Text(link),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class CoffeeEvent {
  const CoffeeEvent({
    required this.title,
    required this.location,
    required this.utcDate,
  });

  final String title;
  final String location;
  final DateTime utcDate;
}

class NewsPreview {
  const NewsPreview({required this.title, required this.description});

  final String title;
  final String description;
}
```

## edit_profile_screen.dart

Lokasi file: `lib/features/profile/screens/edit_profile_screen.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import 'profile_avatars.dart';

/// Hasil `pop` layar ini: [saveOk] jika semua berhasil, atau teks peringatan
/// jika profil tersimpan tetapi sinkronisasi ke tabel `profiles` gagal.
const String saveOk = 'ok';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const String _bucket = 'avatars';

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;

  String _avatarUrl = '';
  Uint8List? _pickedBytes;
  String _pickedMime = 'image/jpeg';
  bool _removeRequested = false;
  bool _isSaving = false;

  bool get _hasPhoto =>
      _pickedBytes != null || (_avatarUrl.isNotEmpty && !_removeRequested);

  @override
  void initState() {
    super.initState();
    final metadata =
        Supabase.instance.client.auth.currentUser?.userMetadata ?? {};
    _nameController = TextEditingController(
      text: metadata['full_name']?.toString() ?? '',
    );
    _avatarUrl = metadata['avatar_url']?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _mimeFor(XFile file) {
    final mime = file.mimeType;
    if (mime != null && mime.startsWith('image/')) {
      return mime;
    }
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (file == null) {
        return; // dibatalkan
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedMime = _mimeFor(file);
        _removeRequested = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka galeri: $error')));
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ivoryWhite,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.darkCoffee,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickFromGallery();
              },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red[800]),
                title: const Text('Hapus Foto'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  setState(() {
                    _pickedBytes = null;
                    _removeRequested = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis, silakan login ulang.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final path = '${user.id}/avatar';
    var avatarUrl = _removeRequested ? '' : _avatarUrl;

    try {
      if (_pickedBytes != null) {
        await client.storage
            .from(_bucket)
            .uploadBinary(
              path,
              _pickedBytes!,
              fileOptions: FileOptions(upsert: true, contentType: _pickedMime),
            );
        // Parameter ?v= mengubah URL tiap unggah agar cache gambar diperbarui.
        avatarUrl =
            '${client.storage.from(_bucket).getPublicUrl(path)}'
            '?v=${DateTime.now().millisecondsSinceEpoch}';
      } else if (_removeRequested && _avatarUrl.isNotEmpty) {
        try {
          await client.storage.from(_bucket).remove([path]);
        } catch (error) {
          debugPrint('Hapus file avatar gagal: $error');
        }
      }

      await client.auth.updateUser(
        UserAttributes(data: {'full_name': name, 'avatar_url': avatarUrl}),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $error')),
      );
      return;
    }

    // Sinkronkan ke tabel `profiles` (tidak fatal jika gagal, mis. RLS).
    var result = saveOk;
    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': name,
        'avatar_url': avatarUrl.isEmpty ? null : avatarUrl,
      });
    } catch (error) {
      debugPrint('Sinkron tabel profiles gagal: $error');
      result =
          'Profil tersimpan, tetapi sinkron ke tabel profiles gagal: $error';
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _showPhotoOptions,
                  child: Stack(
                    children: [
                      ProfileAvatar(
                        radius: 56,
                        imageUrl: _removeRequested ? null : _avatarUrl,
                        memoryBytes: _pickedBytes,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.darkCoffee,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: AppColors.ivoryWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isSaving ? null : _showPhotoOptions,
                child: const Text('Ubah Foto Profil'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCoffee,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ivoryWhite,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## favorite_recipe_screens.dart

Lokasi file: `lib/features/profile/screens/favorite_recipe_screens.dart`

```dart
import 'package:flutter/material.dart';

import '../../../../core/services/favorite_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home/models/recipe_model.dart';
import '../../home/screens/recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  State<FavoriteRecipesScreen> createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  @override
  void initState() {
    super.initState();
    FavoriteService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Resep Favorit Saya'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: ValueListenableBuilder<List<Recipe>>(
        valueListenable: FavoriteService.instance.favorites,
        builder: (context, recipes, _) {
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: AppColors.mediumCoffee,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada resep favorit.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCoffee,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Buka detail resep di Buku Resep, lalu ketuk ikon '
                      'bookmark untuk menyimpannya di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mediumCoffee),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                color: AppColors.lightCream,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.mediumCoffee,
                    foregroundColor: AppColors.lightCream,
                    child: Icon(Icons.coffee),
                  ),
                  title: Text(
                    recipe.title,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${recipe.category} • ${recipe.source}',
                    style: const TextStyle(color: AppColors.mediumCoffee),
                  ),
                  trailing: IconButton(
                    tooltip: 'Hapus dari favorit',
                    icon: const Icon(
                      Icons.bookmark,
                      color: AppColors.darkCoffee,
                    ),
                    onPressed: () => FavoriteService.instance.toggle(recipe),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## loyalty_stamps_screen.dart

Lokasi file: `lib/features/profile/screens/loyalty_stamps_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/blockchain_service.dart';
import '../../../core/services/coupon_service.dart';
import '../../../core/theme/app_colors.dart';
import 'my_coupons_screen.dart';
import 'qr_scanner_screen.dart';

class LoyaltyStampsScreen extends StatefulWidget {
  const LoyaltyStampsScreen({super.key});

  @override
  State<LoyaltyStampsScreen> createState() => _LoyaltyStampsScreenState();
}

class _LoyaltyStampsScreenState extends State<LoyaltyStampsScreen> {
  static const _maxStamps = 10;

  String _merchantFromBlock(Block block) => block.data;

  void _showStampDetails(Block block) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.ivoryWhite,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Stempel',
                style: TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Nama Merchant: ${_merchantFromBlock(block)}'),
              const SizedBox(height: 8),
              Text(
                'Waktu Scan: ${DateFormat('dd MMM yyyy HH:mm').format(block.timestamp.toLocal())}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeemCoupon() async {
    await CouponService.instance.addCoupon();
    await Blockchain.instance.resetChain();
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penukaran Berhasil'),
        content: const Text(
          '10 stempel telah ditukar menjadi kupon Gratis 1 Kopi Bebas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyCouponsScreen(),
                ),
              );
            },
            child: const Text('Lihat Kupon'),
          ),
        ],
      ),
    );
  }

  Future<void> _scanStamp() async {
    final merchant = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || merchant == null) {
      return;
    }

    final blockchain = Blockchain.instance;
    if (blockchain.stampCount >= _maxStamps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartu stempel sudah penuh.')),
      );
      return;
    }

    await blockchain.addBlock(merchant);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stempel dari $merchant berhasil ditambahkan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Loyalty Stamps'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: AnimatedBuilder(
        animation: Blockchain.instance,
        builder: (context, _) {
          final blockchain = Blockchain.instance;
          final isValid = blockchain.isChainValid();
          final stampCount = blockchain.stampCount.clamp(0, _maxStamps);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isValid
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isValid ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isValid ? Icons.verified : Icons.warning_amber_rounded,
                      color: isValid ? Colors.green[700] : Colors.red[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isValid
                            ? 'Status Data: Aman / Valid'
                            : 'Status Data: Rusak / Tidak Valid',
                        style: TextStyle(
                          color: isValid ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$stampCount dari $_maxStamps stempel terkumpul',
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _maxStamps,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final isStamped = index < stampCount;
                  final block = isStamped ? blockchain.chain[index + 1] : null;
                  return InkWell(
                    onTap: block == null
                        ? null
                        : () => _showStampDetails(block),
                    borderRadius: BorderRadius.circular(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isStamped
                            ? AppColors.lightCream
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isStamped
                              ? AppColors.mediumCoffee
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isStamped
                                ? Icons.local_cafe
                                : Icons.local_cafe_outlined,
                            size: 36,
                            color: isStamped
                                ? AppColors.darkCoffee
                                : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isStamped
                                ? 'Stempel ${index + 1}'
                                : 'Slot ${index + 1}',
                            style: TextStyle(
                              color: isStamped
                                  ? AppColors.darkCoffee
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (stampCount >= _maxStamps)
                FilledButton.icon(
                  onPressed: _redeemCoupon,
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('Tukar 10 Stempel Jadi Kupon!'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.mediumCoffee,
                    foregroundColor: AppColors.ivoryWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              if (stampCount >= _maxStamps) const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: stampCount >= _maxStamps ? null : _scanStamp,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(
                  stampCount >= _maxStamps
                      ? 'Kartu Stempel Penuh'
                      : 'Scan QR Stempel',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCoffee,
                  foregroundColor: AppColors.ivoryWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Setiap stempel disimpan sebagai blok yang terhubung dengan hash blok sebelumnya.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.mediumCoffee),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## my_coupons_screen.dart

Lokasi file: `lib/features/profile/screens/my_coupons_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/services/coupon_service.dart';
import '../../../core/theme/app_colors.dart';

class MyCouponsScreen extends StatelessWidget {
  const MyCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoryWhite,
      appBar: AppBar(
        title: const Text('Kupon Saya'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: AnimatedBuilder(
        animation: CouponService.instance,
        builder: (context, _) {
          final coupons = CouponService.instance.coupons
              .where((coupon) => !coupon.isExpired)
              .toList();
          if (coupons.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kupon aktif.',
                style: TextStyle(color: AppColors.mediumCoffee),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Card(
                color: AppColors.lightCream,
                margin: const EdgeInsets.only(bottom: 14),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_activity,
                    color: AppColors.darkCoffee,
                    size: 32,
                  ),
                  title: Text(
                    coupon.title,
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${coupon.merchant}\nBerlaku sampai ${DateFormat('dd MMM yyyy').format(coupon.expiryDate)}',
                    style: const TextStyle(color: AppColors.mediumCoffee),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Hapus kupon',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        CouponService.instance.removeCoupon(coupon.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

## profile_avatars.dart

Lokasi file: `lib/features/profile/screens/profile_avatars.dart`

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Avatar bulat: menampilkan foto (dari URL atau byte lokal) bila ada,
/// dan ikon orang sebagai cadangan bila foto kosong / gagal dimuat.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.radius,
    this.imageUrl,
    this.memoryBytes,
    super.key,
  });

  final double radius;
  final String? imageUrl;
  final Uint8List? memoryBytes;

  @override
  Widget build(BuildContext context) {
    final ImageProvider? image = memoryBytes != null
        ? MemoryImage(memoryBytes!)
        : (imageUrl != null && imageUrl!.isNotEmpty)
        ? NetworkImage(imageUrl!)
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.lightCream,
      foregroundImage: image,
      onForegroundImageError: image == null ? null : (_, _) {},
      child: Icon(
        Icons.person,
        size: radius * 1.1,
        color: AppColors.darkCoffee,
      ),
    );
  }
}
```

## profile_tab.dart

Lokasi file: `lib/features/profile/screens/profile_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/models/recipe_model.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/favorite_recipe_screens.dart';
import '../screens/loyalty_stamps_screen.dart';
import '../screens/my_coupons_screen.dart';
import 'profile_avatars.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  /*
  static const List<String> _teamMembers = [
    'Deandra Naufal Maulana (124240186)',
    'Habrian Daffa Dwiyandana (124240126)',
    'Muhammad Titan Deannova (124240152)',
  ];
  static const String _appVersion = '0.1.0';
  */

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    FavoriteService.instance.ensureLoaded();
  }

  /// Level & badge ditentukan dari jumlah resep favorit.
  ({String level, String badge}) _rankFor(int savedCount) {
    if (savedCount >= 10) {
      return (level: 'Master Brewer', badge: 'Master Brewer');
    }
    if (savedCount >= 6) {
      return (level: 'Skilled Barista', badge: 'Coffee Connoisseur');
    }
    if (savedCount >= 3) {
      return (level: 'Home Brewer', badge: 'Coffee Lover');
    }
    return (level: 'Barista Novice', badge: 'Coffee Enthusiast');
  }

  String _memberSince(User? user) {
    final date = DateTime.tryParse(user?.createdAt ?? '')?.toLocal();
    if (date == null) {
      return '-';
    }
    return '${_months[date.month - 1]} ${date.year}';
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const EditProfileScreen()),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {}); // baca ulang metadata user terbaru
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == saveOk ? 'Profil berhasil diperbarui!' : result,
        ),
      ),
    );
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const FavoriteRecipesScreen()),
    );
  }

  void _openLoyaltyStamps() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoyaltyStampsScreen()),
    );
  }

  void _openMyCoupons() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MyCouponsScreen()));
  }

  Future<void> _showFeedbackDialog() async {
    final controller = TextEditingController();
    var isSubmitting = false;

    try {
      final submitted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text(
              'Saran & Kesan Mata Kuliah Pemrograman Aplikasi Mobile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Tuliskan saran & kesan Anda di sini...',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.mediumCoffee),
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final feedback = controller.text.trim();
                          if (feedback.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Silakan tuliskan saran terlebih dahulu.',
                                ),
                              ),
                            );
                            return;
                          }

                          final user =
                              Supabase.instance.client.auth.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sesi login tidak ditemukan. Silakan login ulang.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            await Supabase.instance.client
                                .from('course_feedbacks')
                                .insert({
                                  'feedback': feedback,
                                  'user_id': user.id,
                                });
                          } catch (error) {
                            debugPrint(
                              'Course feedback submission failed: $error',
                            );
                            if (dialogContext.mounted) {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal mengirim feedback: $error',
                                  ),
                                ),
                              );
                            }
                            return;
                          }

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mediumCoffee,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kirim Feedback'),
                ),
              ),
            ],
          ),
        ),
      );

      if (submitted == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas saran Anda!')),
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red[800]),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    try {
      await AuthService().signOut();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout gagal: $error')));
      }
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: AppColors.lightCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.mediumCoffee, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCoffee,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumCoffee,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata;
    final email = user?.email ?? 'Email tidak ditemukan';
    final rawName = (metadata?['full_name'] as String?)?.trim();
    final fullName = (rawName == null || rawName.isEmpty)
        ? 'Pengguna BrewMaster'
        : rawName;
    final avatarUrl = metadata?['avatar_url'] as String?;

    return SafeArea(
      child: ValueListenableBuilder<List<Recipe>>(
        valueListenable: FavoriteService.instance.favorites,
        builder: (context, favorites, _) {
          final rank = _rankFor(favorites.length);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Profil & Akun',
                        style: TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // A. HEADER PROFIL PENGGUNA
                      Center(
                        child: Column(
                          children: [
                            ProfileAvatar(radius: 48, imageUrl: avatarUrl),
                            const SizedBox(height: 16),
                            Text(
                              fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCoffee,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.mediumCoffee,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightCream,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.mediumCoffee,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                rank.badge,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkCoffee,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // B. RINGKASAN AKTIVITAS
                      Row(
                        children: [
                          _statCard(
                            value: '${favorites.length}',
                            label: 'Resep Tersimpan',
                          ),
                          const SizedBox(width: 12),
                          _statCard(value: rank.level, label: 'Level Seduh'),
                          const SizedBox(width: 12),
                          _statCard(
                            value: _memberSince(user),
                            label: 'Bergabung',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // C. DAFTAR MENU PENGATURAN
                      Card(
                        elevation: 0,
                        color: AppColors.lightCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: AppColors.mediumCoffee,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Edit Profil'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openEditProfile,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.bookmark,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Resep Favorit Saya'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openFavorites,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.local_activity_outlined,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Kupon Saya'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openMyCoupons,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.card_giftcard,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Loyalty Stamps'),
                              subtitle: const Text('Kumpulkan 10 stempel kopi'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _openLoyaltyStamps,
                            ),
                            const Divider(
                              height: 1,
                              color: AppColors.mediumCoffee,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: AppColors.darkCoffee,
                              ),
                              title: const Text('Tentang BrewMaster Hub'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _showFeedbackDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // D. TOMBOL LOGOUT (tetap di bagian bawah layar)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

## qr_scanner_screen.dart

Lokasi file: `lib/features/profile/screens/qr_scanner_screen.dart`

```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
    if (rawValue.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    await _controller.stop();

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic> ||
          decoded['action'] != 'add_stamp' ||
          decoded['signature'] != 'rahasia_kopi_123') {
        throw const FormatException('QR Code bukan milik Brewmaster.');
      }

      final merchant = decoded['merchant']?.toString().trim();
      if (merchant == null || merchant.isEmpty) {
        throw const FormatException('Nama kedai pada QR Code tidak valid.');
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(merchant);
    } on FormatException {
      await _showScanError('QR Code tidak valid atau bukan milik Brewmaster.');
    } on Object catch (error) {
      debugPrint('QR scan failed: $error');
      await _showScanError('QR Code tidak dapat diproses. Coba lagi.');
    }
  }

  Future<void> _showScanError(String message) async {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isProcessing = false);
    await _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Stempel'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetection),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ivoryWhite, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Text(
              'Arahkan kamera ke QR Code stempel kedai kopi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```
