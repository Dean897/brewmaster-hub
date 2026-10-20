import 'package:flutter/material.dart';

import '../../../core/database/db_helper.dart';
import '../../../core/theme/app_colors.dart';

class TebakKopiScreen extends StatefulWidget {
  const TebakKopiScreen({super.key});

  @override
  State<TebakKopiScreen> createState() => _TebakKopiScreenState();
}

class _TebakKopiScreenState extends State<TebakKopiScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await DbHelper.instance.getQuestions();

    if (!mounted) {
      return;
    }

    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  Future<void> _checkAnswer(String answer) async {
    final question = _questions[_currentIndex];
    if (answer == question['correct_answer']) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      return;
    }

    await _showScoreDialog();
  }

  Future<void> _showScoreDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kuis Selesai!'),
          content: Text(
            'Skor Anda: $_score dari ${_questions.length}',
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

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.ivoryWhite,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.mediumCoffee,
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tebak Kopi'),
          backgroundColor: AppColors.ivoryWhite,
          foregroundColor: AppColors.darkCoffee,
        ),
        body: const Center(
          child: Text(
            'Belum ada pertanyaan yang tersedia.',
            style: TextStyle(color: AppColors.darkCoffee),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final options = {
      'A': question['option_a'] as String,
      'B': question['option_b'] as String,
      'C': question['option_c'] as String,
      'D': question['option_d'] as String,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tebak Kopi'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pertanyaan ${_currentIndex + 1} dari ${_questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mediumCoffee,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                question['question'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkCoffee,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              for (final option in options.entries) ...[
                ElevatedButton(
                  onPressed: () => _checkAnswer(option.key),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightCream,
                    foregroundColor: AppColors.darkCoffee,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('${option.key}. ${option.value}'),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
