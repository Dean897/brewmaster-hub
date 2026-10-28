import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/database/db_helper.dart';
import '../../../core/services/brew_points_service.dart';
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
  int _correctCount = 0;
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
        _correctCount = 0;
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
      _correctCount++;
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
    final bool earnedPoint = _correctCount >= 8;
    if (earnedPoint) {
      await BrewPointsService.instance.addQuizPoint();
    }

    if (!mounted) return;

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
            const SizedBox(height: 12),
            Text(
              'Jawaban Benar: $_correctCount / ${_sessionQuestions.length}',
              style: const TextStyle(
                color: AppColors.mediumCoffee,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (earnedPoint) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mediumCoffee, width: 0.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      color: AppColors.darkCoffee,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '+1 Poin Level Seduh Diperoleh!',
                      style: TextStyle(
                        color: AppColors.darkCoffee,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    return coffeeAppBar(title: 'Kuis Kopi');
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
