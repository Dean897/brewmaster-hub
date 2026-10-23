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
