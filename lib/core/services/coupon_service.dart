import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coupon_model.dart';

class CouponService extends ChangeNotifier {
  CouponService._() {
    _loadFuture = loadCoupons();
  }

  static final CouponService instance = CouponService._();
  static const _storageKey = 'loyalty_coupons';

  late final Future<void> _loadFuture;
  final List<Coupon> _coupons = [];

  List<Coupon> get coupons => List.unmodifiable(_coupons);

  Future<void> addCoupon() async {
    await _loadFuture;
    await _removeExpiredCoupons();
    final coupon = Coupon(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: 'Gratis 1 Kopi Bebas',
      merchant: 'Berlaku di semua merchant mitra',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
    );
    _coupons.insert(0, coupon);
    await saveCoupons();
    notifyListeners();
  }

  Future<void> removeCoupon(String id) async {
    await _loadFuture;
    _coupons.removeWhere((coupon) => coupon.id == id);
    await saveCoupons();
    notifyListeners();
  }

  Future<void> purgeExpiredCoupons() async {
    await _loadFuture;
    final removed = await _removeExpiredCoupons();
    if (removed) {
      notifyListeners();
    }
  }

  Future<void> loadCoupons() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedCoupons = preferences.getString(_storageKey);
    if (encodedCoupons == null || encodedCoupons.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(encodedCoupons);
      if (decoded is! List) {
        return;
      }
      _coupons
        ..clear()
        ..addAll(
          decoded.map((item) => Coupon.fromJson(item as Map<String, dynamic>)),
        );
      await _removeExpiredCoupons();
      notifyListeners();
    } on FormatException catch (error) {
      debugPrint('Kupon tidak dapat dimuat: $error');
    } on TypeError catch (error) {
      debugPrint('Format kupon tidak valid: $error');
    }
  }

  Future<void> saveCoupons() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(_coupons.map((coupon) => coupon.toJson()).toList()),
    );
  }

  Future<bool> _removeExpiredCoupons() async {
    final activeCoupons = _coupons
        .where((coupon) => !coupon.isExpired)
        .toList();
    if (activeCoupons.length != _coupons.length) {
      _coupons
        ..clear()
        ..addAll(activeCoupons);
      await saveCoupons();
      return true;
    }
    return false;
  }
}
