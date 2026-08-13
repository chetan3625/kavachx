import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kavachx/Services/api_service.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final ApiService _apiService = Get.find<ApiService>();
  bool isScanning = true;

  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => isScanning = false);

        String scannedValue = barcode.rawValue!;
        
        // Extract token if scanned value is a full URL (e.g. https://kavachx.com/join/TOKEN)
        if (scannedValue.contains('/join/')) {
          scannedValue = scannedValue.split('/join/').last;
        }

        // Send API request using extracted token
        final response = await _apiService.joinRequest(gymToken: scannedValue);

        if (response.isOk) {
          Get.back();
          Get.snackbar(
            'Success',
            'Join request sent to gym owner!',
            backgroundColor: const Color(0xFF1C1C22),
            colorText: Colors.white,
            borderColor: const Color(0xFF34C759),
            borderWidth: 1,
          );
        } else {
          Get.snackbar(
            'Failed',
            response.body?['message'] ?? 'Invalid QR Code',
            backgroundColor: const Color(0xFF1C1C22),
            colorText: Colors.white,
            borderColor: const Color(0xFFFF3B30),
            borderWidth: 1,
          );
          setState(() => isScanning = true);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        title: const Text('Scan Gym QR'),
        backgroundColor: const Color(0xFF1C1C22),
      ),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}