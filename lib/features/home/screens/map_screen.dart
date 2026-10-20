import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';

class CoffeeShop {
  const CoffeeShop({
    required this.name,
    required this.location,
    required this.address,
    required this.description,
    required this.rating,
  });

  final String name;
  final LatLng location;
  final String address;
  final String description;
  final double rating;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PopupController _popupLayerController = PopupController();

  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _locationError;
  List<CoffeeShop> coffeeShops = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _fetchCoffeeShopsFromSupabase();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi diperlukan untuk menampilkan peta.');
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLocation = location;
        _isLoading = coffeeShops.isEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCoffeeShopsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('coffee_shops')
          .select();
      print('Jumlah kedai didapat: ${response.length}'); // ignore: avoid_print
      final shops = (response as List<dynamic>).map((item) {
        final data = item as Map<String, dynamic>;
        return CoffeeShop(
          name: data['name']?.toString() ?? 'Kedai Tanpa Nama',
          location: LatLng(
            _parseDouble(data['latitude'], 'latitude'),
            _parseDouble(data['longitude'], 'longitude'),
          ),
          address: data['address']?.toString() ?? 'Alamat tidak tersedia',
          rating: _parseDouble(data['rating'], 'rating'),
          description:
              data['description']?.toString() ?? 'Deskripsi tidak tersedia',
        );
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        coffeeShops = shops;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetch peta: $e'); // ignore: avoid_print

      if (!mounted) {
        return;
      }

      setState(() {
        _locationError = 'Gagal memuat data kedai: $e';
        _isLoading = false;
      });
    }
  }

  double _parseDouble(Object? value, String fieldName) {
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw FormatException('Nilai $fieldName tidak valid.');
    }
    return parsed;
  }

  Widget _buildShopPopup(BuildContext context, Marker marker) {
    final shop = coffeeShops.firstWhere(
      (item) => item.location == marker.point,
    );

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.ivoryWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shop.name,
              style: const TextStyle(
                color: AppColors.darkCoffee,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              shop.address,
              style: const TextStyle(color: AppColors.mediumCoffee),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  shop.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: AppColors.darkCoffee,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              shop.description,
              style: const TextStyle(color: AppColors.darkCoffee),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kedai Sekitar'),
        backgroundColor: AppColors.ivoryWhite,
        foregroundColor: AppColors.darkCoffee,
      ),
      backgroundColor: AppColors.ivoryWhite,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.mediumCoffee,
              ),
            )
          : _locationError != null || _currentLocation == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _locationError ?? 'Lokasi tidak tersedia.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.darkCoffee),
                ),
              ),
            )
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 14.0,
                onTap: (_, _) => _popupLayerController.hideAllPopups(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=${ApiConstants.cartoApiKey}',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.app',
                ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    popupController: _popupLayerController,
                    markers: [
                      for (final shop in coffeeShops)
                        Marker(
                          point: shop.location,
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.darkCoffee,
                            size: 42,
                          ),
                        ),
                    ],
                    popupDisplayOptions: PopupDisplayOptions(
                      builder: _buildShopPopup,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
