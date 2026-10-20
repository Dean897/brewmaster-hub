import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';

class CoffeeShop {
  const CoffeeShop({
    required this.name,
    required this.location,
    required this.description,
    required this.rating,
    required this.review,
  });

  final String name;
  final LatLng location;
  final String description;
  final double rating;
  final String review;
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
  List<CoffeeShop> _coffeeShops = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
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
        _coffeeShops = _createDummyShops(location);
        _isLoading = false;
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

  List<CoffeeShop> _createDummyShops(LatLng center) {
    return [
      CoffeeShop(
        name: 'Kopi Sudut Senja',
        location: LatLng(center.latitude + 0.0012, center.longitude - 0.0010),
        description: 'Kedai nyaman dengan pilihan manual brew.',
        rating: 4.8,
        review: 'Tempat tenang dan kopinya harum.',
      ),
      CoffeeShop(
        name: 'Brew Veteran',
        location: LatLng(center.latitude - 0.0011, center.longitude + 0.0013),
        description: 'Spesialis espresso dan latte art.',
        rating: 4.6,
        review: 'Latte-nya lembut dan baristanya ramah.',
      ),
      CoffeeShop(
        name: 'Kedai Pagi',
        location: LatLng(center.latitude + 0.0018, center.longitude + 0.0017),
        description: 'Tempat sarapan dengan kopi lokal.',
        rating: 4.5,
        review: 'Cocok untuk memulai hari.',
      ),
      CoffeeShop(
        name: 'Ruang Kopi',
        location: LatLng(center.latitude - 0.0020, center.longitude - 0.0015),
        description: 'Ruang kerja santai dengan Wi-Fi cepat.',
        rating: 4.7,
        review: 'Nyaman untuk bekerja sambil ngopi.',
      ),
      CoffeeShop(
        name: 'Gayo Corner',
        location: LatLng(center.latitude + 0.0007, center.longitude + 0.0024),
        description: 'Menyajikan biji kopi Gayo pilihan.',
        rating: 4.9,
        review: 'Aroma dan rasa kopinya sangat berkarakter.',
      ),
      CoffeeShop(
        name: 'Kopi Lereng',
        location: LatLng(center.latitude - 0.0017, center.longitude + 0.0022),
        description: 'Kopi single origin dengan suasana hangat.',
        rating: 4.4,
        review: 'Pilihan single origin-nya menarik.',
      ),
      CoffeeShop(
        name: 'Teras Seduh',
        location: LatLng(center.latitude + 0.0024, center.longitude - 0.0021),
        description: 'Kedai terbuka untuk menikmati sore.',
        rating: 4.6,
        review: 'Pemandangan dan kopinya sama-sama menyenangkan.',
      ),
      CoffeeShop(
        name: 'Bean House',
        location: LatLng(center.latitude - 0.0008, center.longitude - 0.0025),
        description: 'Pilihan biji kopi dan alat seduh rumahan.',
        rating: 4.3,
        review: 'Bisa konsultasi alat seduh dengan bebas.',
      ),
      CoffeeShop(
        name: 'Kopi Kampus',
        location: LatLng(center.latitude + 0.0021, center.longitude + 0.0005),
        description: 'Kedai ekonomis favorit mahasiswa.',
        rating: 4.2,
        review: 'Harga bersahabat dan porsinya pas.',
      ),
      CoffeeShop(
        name: 'Manual Brew Lab',
        location: LatLng(center.latitude - 0.0024, center.longitude + 0.0004),
        description: 'Eksperimen rasa melalui beragam metode seduh.',
        rating: 4.8,
        review: 'Baristanya membantu memilih profil rasa.',
      ),
    ];
  }

  Widget _buildShopPopup(BuildContext context, Marker marker) {
    final shop = _coffeeShops.firstWhere(
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
              shop.description,
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
              '"${shop.review}"',
              style: const TextStyle(
                color: AppColors.darkCoffee,
                fontStyle: FontStyle.italic,
              ),
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
                      for (final shop in _coffeeShops)
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
