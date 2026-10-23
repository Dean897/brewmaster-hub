import 'package:flutter/material.dart';

import '../../../core/services/blockchain_service.dart';
import '../../../core/theme/app_colors.dart';

class LoyaltyStampsScreen extends StatelessWidget {
  const LoyaltyStampsScreen({super.key});

  static const _maxStamps = 10;

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
                  return DecoratedBox(
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
                          color: isStamped ? AppColors.darkCoffee : Colors.grey,
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
                  );
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: stampCount >= _maxStamps
                    ? null
                    : () => Blockchain.instance.addBlock(
                        'Stempel Kopi ${stampCount + 1}',
                      ),
                icon: const Icon(Icons.add_circle_outline),
                label: Text(
                  stampCount >= _maxStamps
                      ? 'Kartu Stempel Penuh'
                      : 'Simulasikan Dapat Stempel',
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
