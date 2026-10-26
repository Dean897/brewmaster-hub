import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/widgets/coffee_app_bar.dart';

enum _Rarity {
  ssr('BINTANG 5', 'Emas', Color(0xFFFFC857)),
  sr('BINTANG 4', 'Ungu', Color(0xFFB36BFF)),
  r('BINTANG 3', 'Biru', Color(0xFF55B9FF));

  const _Rarity(this.label, this.name, this.color);

  final String label;
  final String name;
  final Color color;
}

class _GachaReward {
  const _GachaReward(this.title, this.subtitle, this.icon, this.rarity);

  final String title;
  final String subtitle;
  final IconData icon;
  final _Rarity rarity;
}

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with TickerProviderStateMixin {
  static const _animationDuration = Duration(seconds: 4);
  static const _shakeThreshold = 15.0;
  static const _shakeDebounceDuration = Duration(seconds: 1);

  final _random = Random();
  final _rewards = const [
    _GachaReward(
      'V60 Japanese Iced',
      'Resep kopi dingin dengan karakter citrus',
      Icons.local_cafe_rounded,
      _Rarity.ssr,
    ),
    _GachaReward(
      'Espresso Tonic',
      'Perpaduan espresso berani dan tonic segar',
      Icons.bubble_chart_rounded,
      _Rarity.sr,
    ),
    _GachaReward(
      'Cold Brew',
      'Seduhan lembut untuk menemani harimu',
      Icons.coffee_rounded,
      _Rarity.r,
    ),
    _GachaReward(
      'Caramel Macchiato',
      'Manis, creamy, dan penuh aroma karamel',
      Icons.emoji_food_beverage_rounded,
      _Rarity.sr,
    ),
    _GachaReward(
      'Kopi Tubruk',
      'Seduhan tradisional dengan aroma kopi yang pekat',
      Icons.local_drink_rounded,
      _Rarity.r,
    ),
    _GachaReward(
      'Affogato',
      'Espresso hangat yang berpadu dengan gelato lembut',
      Icons.icecream_rounded,
      _Rarity.sr,
    ),
    _GachaReward(
      'Cappuccino',
      'Espresso klasik dengan foam susu yang lembut',
      Icons.coffee_rounded,
      _Rarity.r,
    ),
    _GachaReward(
      'Kopi Susu Gula Aren',
      'Kopi susu creamy dengan manis gula aren',
      Icons.local_cafe_rounded,
      _Rarity.sr,
    ),
    _GachaReward(
      'Nitro Cold Brew',
      'Cold brew bertekstur silky dengan sensasi nitrogen',
      Icons.bubble_chart_rounded,
      _Rarity.ssr,
    ),
    _GachaReward(
      'Mocha Mint',
      'Cokelat, espresso, dan mint dalam satu tegukan',
      Icons.auto_awesome_rounded,
      _Rarity.r,
    ),
    _GachaReward(
      'Flat White',
      'Espresso intens dengan microfoam susu yang halus',
      Icons.coffee_maker_rounded,
      _Rarity.sr,
    ),
  ];

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _shakeDebounceTimer;
  late final AnimationController _controller;
  late final Animation<double> _meteorProgress;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _cardFlip;
  late final Animation<double> _cardOpacity;

  _GachaReward? _reward;
  bool _isAnimating = false;
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _isAnimating = false);
        }
      });

    // The sequence weights map directly to the 1.5 / 2 / 4 second phases.
    _meteorProgress = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 37.5),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 62.5),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 37.5),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 8.5),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 50),
    ]).animate(_controller);
    _cardOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 8),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 42),
    ]).animate(_controller);
    _cardFlip = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(_controller);
    _listenToAccelerometer();
  }

  void _listenToAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final isAboveThreshold =
          event.x.abs() > _shakeThreshold ||
          event.y.abs() > _shakeThreshold ||
          event.z.abs() > _shakeThreshold;

      if (!mounted || !isAboveThreshold || _isAnimating || _isShaking) {
        return;
      }

      _isShaking = true;
      startGachaAnimation();
      _shakeDebounceTimer = Timer(_shakeDebounceDuration, () {
        _isShaking = false;
      });
    });
  }

  void startGachaAnimation() {
    if (!mounted || _isAnimating) {
      return;
    }
    setState(() {
      _reward = _rewards[_random.nextInt(_rewards.length)];
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _shakeDebounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reward = _reward;
    return Scaffold(
      appBar: coffeeAppBar(title: 'Gacha Kopi'),
      backgroundColor: const Color(0xFF120B1B),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _GachaBackdrop(color: reward?.rarity.color ?? Colors.deepPurple),
              SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 8),
                      child: Text(
                        'PANGGILAN TAKDIR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Text(
                      'Temukan resep kopi langka milikmu',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kocok perangkat atau tekan tombol untuk memulai',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Expanded(
                      child: _GachaStage(
                        meteorProgress: _meteorProgress.value,
                        cardOpacity: _cardOpacity.value,
                        cardFlip: _cardFlip.value,
                        reward: reward,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: _isAnimating ? null : startGachaAnimation,
                          icon: Icon(
                            _isAnimating
                                ? Icons.auto_awesome
                                : Icons.star_rounded,
                          ),
                          label: Text(
                            _isAnimating
                                ? 'MENYELARASKAN...'
                                : 'GACHA SEKARANG',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                reward?.rarity.color ?? const Color(0xFF8F5DE8),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _flashOpacity,
                child: const IgnorePointer(
                  child: ColoredBox(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GachaStage extends StatelessWidget {
  const _GachaStage({
    required this.meteorProgress,
    required this.cardOpacity,
    required this.cardFlip,
    required this.reward,
  });

  final double meteorProgress;
  final double cardOpacity;
  final double cardFlip;
  final _GachaReward? reward;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final meteorY =
            -constraints.maxHeight * 0.18 +
            constraints.maxHeight * 0.68 * meteorProgress;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (meteorProgress < 1)
              Transform.translate(
                offset: Offset(0, meteorY),
                child: _MeteorOrb(color: reward?.rarity.color ?? Colors.white),
              ),
            if (reward != null)
              Opacity(
                opacity: cardOpacity,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(pi * (1 - cardFlip)),
                  child: _RewardCard(reward: reward!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MeteorOrb extends StatelessWidget {
  const _MeteorOrb({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 100,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0),
                  color.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 155),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: color, blurRadius: 28, spreadRadius: 10),
                BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward});

  final _GachaReward reward;

  @override
  Widget build(BuildContext context) {
    final color = reward.rarity.color;
    return Container(
      width: min(MediaQuery.sizeOf(context).width - 56, 340),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF241632),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.7),
            blurRadius: 34,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 70,
            spreadRadius: 18,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(reward.icon, color: color, size: 74),
          const SizedBox(height: 18),
          Text(
            reward.rarity.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reward.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reward.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'KELANGKAAN ${reward.rarity.name.toUpperCase()}',
            style: TextStyle(color: color, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _GachaBackdrop extends StatelessWidget {
  const _GachaBackdrop({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [color.withValues(alpha: 0.2), const Color(0xFF120B1B)],
        ),
      ),
      child: CustomPaint(painter: _StarPainter(color)),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.28);
    for (var index = 0; index < 35; index++) {
      final x = (index * 67.0) % size.width;
      final y = (index * 113.0) % size.height;
      canvas.drawCircle(Offset(x, y), index.isEven ? 1.2 : 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => oldDelegate.color != color;
}
