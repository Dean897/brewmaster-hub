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
