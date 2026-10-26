import 'dart:async';

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
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

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
    final blockchain = Blockchain.instance;
    if (blockchain.isScanOnCooldown) {
      _showCooldownMessage(blockchain.cooldownRemaining);
      return;
    }

    final merchant = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || merchant == null) {
      return;
    }

    if (blockchain.stampCount >= _maxStamps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kartu stempel sudah penuh.')),
      );
      return;
    }

    try {
      await blockchain.addBlock(merchant);
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
      return;
    }
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Stempel dari $merchant berhasil ditambahkan.')),
    );
  }

  void _showCooldownMessage(Duration remaining) {
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);
    final formatted = minutes > 0
        ? '$minutes menit ${seconds.toString().padLeft(2, '0')} detik'
        : '$seconds detik';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scan QR berikutnya tersedia dalam $formatted.')),
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
          final isScanOnCooldown = blockchain.isScanOnCooldown;

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
                onPressed: stampCount >= _maxStamps || isScanOnCooldown
                    ? null
                    : _scanStamp,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(
                  stampCount >= _maxStamps
                      ? 'Kartu Stempel Penuh'
                      : isScanOnCooldown
                      ? 'Tunggu ${blockchain.cooldownRemaining.inMinutes}:${blockchain.cooldownRemaining.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                      : 'Scan QR Stempel',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCoffee,
                  foregroundColor: AppColors.ivoryWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              if (isScanOnCooldown)
                Text(
                  'Untuk mencegah spam, satu QR hanya dapat dipindai setiap 20 menit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orange[800]),
                ),
              if (isScanOnCooldown) const SizedBox(height: 8),
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
