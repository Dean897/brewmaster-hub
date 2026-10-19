import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  static const _initialCenter = LatLng(-7.7610, 110.4098);

  void _showShopMessage(BuildContext context, String shopName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(shopName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shops = [
      (
        point: const LatLng(-7.7598, 110.4089),
        name: 'Kopi Veteran',
      ),
      (
        point: const LatLng(-7.7621, 110.4110),
        name: 'Kedai Senja',
      ),
      (
        point: const LatLng(-7.7630, 110.4079),
        name: 'Brew Corner',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kedai Sekitar'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: _initialCenter,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              for (final shop in shops)
                Marker(
                  point: shop.point,
                  width: 48,
                  height: 48,
                  child: GestureDetector(
                    onTap: () => _showShopMessage(context, shop.name),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.darkCoffee,
                      size: 42,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
