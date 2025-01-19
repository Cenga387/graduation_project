import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:graduation_project/services/attendance_service.dart';

class QRCodeScannerScreen extends StatefulWidget {
  final String postId;
  final String? qrCodeImageUrl;
  final String? qrCodeRawData;

  const QRCodeScannerScreen(
      {super.key,
      required this.postId,
      required this.qrCodeImageUrl,
      required this.qrCodeRawData});

  @override
  State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    // Listen for barcode detection events
    _controller.barcodes.listen((barcodeCapture) {
      if (!isScanning) {
        final barcode = barcodeCapture.barcodes.first;
        if (barcode.rawValue != null) {
          handleQRCodeScanned(barcode.rawValue!);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  void handleQRCodeScanned(String scannedQRCode) async {
    setState(() {
      isScanning = true;
    });

    try {
      // Compare scanned QR code with the stored QR code image URL
      if (scannedQRCode == widget.qrCodeRawData) {
        await AttendanceService()
            .markAsAttended(widget.postId); // Mark attendance

        if (mounted) {
          Navigator.pop(context); // Close scanner
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance marked successfully!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
      ),
    );
  }
}
