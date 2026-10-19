import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/theme/app_colors.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
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
  String? _selectedRecipe;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _shakeDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kocok Resep'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
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
                    ? const SizedBox(
                        key: ValueKey('empty-recipe'),
                        height: 120,
                      )
                    : Card(
                        key: ValueKey(_selectedRecipe),
                        color: AppColors.lightCream,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
