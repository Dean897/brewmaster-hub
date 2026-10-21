import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/database/db_helper.dart';
import '../../../core/theme/app_colors.dart';

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

    return Question(
      question: row['question'] as String,
      options: [
        row['option_a'] as String,
        row['option_b'] as String,
        row['option_c'] as String,
        row['option_d'] as String,
      ],
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

class _TebakKopiScreenState extends State<TebakKopiScreen> {
  static const _questionLimit = 10;
  static const _questionDuration = 10;

  List<Question> _sessionQuestions = [];
  Timer? _countdownTimer;
  int _currentIndex = 0;
  int _remainingSeconds = _questionDuration;
  int _totalScore = 0;
  bool _isLoading = true;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final rows = await DbHelper.instance.getQuestions();
    if (!mounted) {
      return;
    }

    final questions = rows.map(Question.fromDatabase).toList();
    setState(() {
      _sessionQuestions = questions.take(_questionLimit).toList();
      _currentIndex = 0;
      _totalScore = 0;
      _isAnswering = false;
      _isLoading = false;
    });
    _startCountdown();
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
    if (answer == question.correctAnswer) {
      _totalScore += _remainingSeconds * 10;
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
    _startCountdown();
  }

  Future<void> _showHighScore() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('High Score'),
        content: Text(
          'Sesi selesai!\n\nTotal poin: $_totalScore',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _fetchQuestions();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkCoffee,
              foregroundColor: AppColors.ivoryWhite,
            ),
            child: const Text('Main Lagi'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(this.context).pop();
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.mediumCoffee),
        ),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        body: Center(
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
      appBar: AppBar(
        title: const Text('Tebak Kopi Arcade'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentIndex + 1}/$_questionLimit',
                    style: const TextStyle(
                      color: AppColors.mediumCoffee,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Skor: $_totalScore',
                    style: const TextStyle(
                      color: AppColors.darkCoffee,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: AppColors.lightCream,
                  color: _remainingSeconds <= 3
                      ? Colors.red
                      : AppColors.mediumCoffee,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Waktu: $_remainingSeconds detik',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _remainingSeconds <= 3
                      ? Colors.red
                      : AppColors.darkCoffee,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        question.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.darkCoffee,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),
                      for (final option in question.options) ...[
                        ElevatedButton(
                          onPressed: _isAnswering
                              ? null
                              : () => _submitAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightCream,
                            foregroundColor: AppColors.darkCoffee,
                            disabledBackgroundColor: AppColors.lightCream
                                .withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(option, textAlign: TextAlign.center),
                        ),
                        const SizedBox(height: 12),
                      ],
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
