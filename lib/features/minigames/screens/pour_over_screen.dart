import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PourOverScreen extends StatefulWidget {
  const PourOverScreen({super.key});

  @override
  State<PourOverScreen> createState() => _PourOverScreenState();
}

class _PourOverScreenState extends State<PourOverScreen> {
  double _waterPoured = 0.0;
  int _timeRemaining = 30;
  bool _isPouring = false;
  Timer? _countdownTimer;
  Timer? _pouringTimer;

  void _startGame() {
    if (_countdownTimer != null || _timeRemaining <= 0) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining <= 1) {
        _countdownTimer?.cancel();
        _countdownTimer = null;
        _stopPouring();
        setState(() {
          _timeRemaining = 0;
        });
        _showResult();
        return;
      }

      setState(() {
        _timeRemaining--;
      });
    });
  }

  void _startPouring() {
    if (_isPouring || _timeRemaining <= 0) {
      return;
    }

    _startGame();
    setState(() {
      _isPouring = true;
    });

    _pouringTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_waterPoured >= 250) {
        _stopPouring();
        return;
      }

      setState(() {
        _waterPoured = (_waterPoured + 3.5).clamp(0.0, 250.0);
      });
    });
  }

  void _stopPouring() {
    _pouringTimer?.cancel();
    _pouringTimer = null;

    if (mounted) {
      setState(() {
        _isPouring = false;
      });
    }
  }

  Future<void> _showResult() async {
    final isPerfect = _waterPoured >= 245 && _waterPoured <= 255;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isPerfect ? 'Perfect Brew!' : 'Rasa Kopi Kurang Pas!'),
          content: Text(
            'Jumlah air: ${_waterPoured.toStringAsFixed(0)} ml dari target 250 ml.',
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
  void dispose() {
    _countdownTimer?.cancel();
    _pouringTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_waterPoured / 250).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pour-Over Challenge'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Target: 250 ml',
                style: TextStyle(
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
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 18,
                        backgroundColor: AppColors.lightCream,
                        color: AppColors.mediumCoffee,
                      ),
                    ),
                    Text(
                      '${_waterPoured.toStringAsFixed(0)} ml',
                      style: const TextStyle(
                        color: AppColors.darkCoffee,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => _startPouring(),
                onTapUp: (_) => _stopPouring(),
                onTapCancel: _stopPouring,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPouring
                        ? AppColors.darkCoffee
                        : AppColors.mediumCoffee,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isPouring ? 'Tuang...' : 'Tekan\nuntuk Tuang',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.ivoryWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
