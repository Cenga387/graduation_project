// import 'package:flutter/material.dart';
// import 'package:graduation_project/services/attendance_service.dart';

// class QRCodeScannerScreen extends StatefulWidget {
//   final String postId;

//   const QRCodeScannerScreen({super.key, required this.postId});

//   @override
//   State<QRCodeScannerScreen> createState() => _QRCodeScannerScreenState();
// }

// class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
//   final AttendanceService _attendanceService = AttendanceService();
//   bool isScanning = false;

//   void handleQRCodeScanned(String qrData) async {
//     if (isScanning) return;

//     setState(() {
//       isScanning = true;
//     });

//     try {
//       if (qrData.contains(widget.postId)) {
//         await _attendanceService.markAsAttended(widget.postId);
//         Navigator.pop(context); // Close scanner
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Attendance marked successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid QR code.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }

//     setState(() {
//       isScanning = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan QR Code')),
//       body: MobileScanner(
//         onDetect: (barcode, args) {
//           if (barcode.rawValue != null) {
//             handleQRCodeScanned(barcode.rawValue!);
//           }
//         },
//       ),
//     );
//   }
// }
