import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
    if (rawValue.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    await _controller.stop();

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic> ||
          decoded['action'] != 'add_stamp' ||
          decoded['signature'] != 'rahasia_kopi_123') {
        throw const FormatException('QR Code bukan milik Brewmaster.');
      }

      final merchant = decoded['merchant']?.toString().trim();
      if (merchant == null || merchant.isEmpty) {
        throw const FormatException('Nama kedai pada QR Code tidak valid.');
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(merchant);
    } on FormatException {
      await _showScanError('QR Code tidak valid atau bukan milik Brewmaster.');
    } on Object catch (error) {
      debugPrint('QR scan failed: $error');
      await _showScanError('QR Code tidak dapat diproses. Coba lagi.');
    }
  }

  Future<void> _showScanError(String message) async {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isProcessing = false);
    await _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Stempel'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetection),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.ivoryWhite, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Text(
              'Arahkan kamera ke QR Code stempel kedai kopi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
