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
  bool isProcessingQRCode = false;

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.stop(); // Ensure the scanner stops when the screen is closed
    _controller.dispose(); // Dispose of the scanner controller
    super.dispose();
  }

  void handleQRCodeScanned(String scannedQRCode) async {
    if (isProcessingQRCode) return; // Prevent multiple scans while processing

    setState(() {
      isProcessingQRCode = true; // Lock scanner while processing
    });

    try {
      // Compare the scanned QR code with the stored raw data
      if (scannedQRCode == widget.qrCodeRawData) {
        // Check if the user is already marked as attended
        final isAlreadyMarked =
            await AttendanceService().isAlreadyMarked(widget.postId);

        if (!isAlreadyMarked) {
          // Mark the user's attendance
          await AttendanceService().markAsAttended(widget.postId);

          if (mounted) {
            Navigator.pop(context); // Close the scanner
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance marked successfully!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance already marked.')),
            );
          }
          restartScanner(); // Restart scanning if the user is already marked
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code.')),
          );
        }
        restartScanner(); // Restart scanning for invalid QR code
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      restartScanner(); // Restart scanning in case of an error
    } finally {
      setState(() {
        isProcessingQRCode = false; // Unlock scanner
      });
    }
  }

  void restartScanner() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.start(); // Restart the scanner after a delay
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
        onDetect: (barcodeCapture) {
          if (!isProcessingQRCode) {
            final barcode = barcodeCapture.barcodes.first;
            if (barcode.rawValue != null) {
              _controller
                  .stop(); // Temporarily stop the scanner while processing
              handleQRCodeScanned(barcode.rawValue!);
            }
          }
        },
      ),
    );
  }
}
