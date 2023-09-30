// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:image_picker/image_picker.dart';

// class QRScannerPage extends StatefulWidget {
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }

// class _QRScannerPageState extends State<QRScannerPage> {
//   QRViewController? controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: <Widget>[
//           QRView(
//             key: qrKey,
//             onQRViewCreated: _onQRViewCreated,
//             overlay: QrScannerOverlayShape(
//               borderColor: Colors.white,
//               borderRadius: 10,
//               borderLength: 30,
//               borderWidth: 10,
//               cutOutSize: MediaQuery.of(context).size.width * 0.8,
//               overlayColor: Colors.black.withOpacity(0.7),
//             ),
//           ),
//           Positioned(
//             top: 50.0,
//             child: Text(
//               "Escanear código QR",
//               style: TextStyle(color: Colors.white, fontSize: 20),
//             ),
//           ),
//           Positioned(
//             bottom: 50.0,
//             left: MediaQuery.of(context).size.width * 0.25,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: <Widget>[
//                 IconButton(
//                   icon: Icon(Icons.flash_on, color: Colors.white),
//                   onPressed: () async {
//                     await controller?.toggleFlash();
//                   },
//                 ),
//                 SizedBox(width: MediaQuery.of(context).size.width * 0.2),
//                 IconButton(
//                   icon: Icon(Icons.photo_library, color: Colors.white),
//                   onPressed: () async {
//                     final pickedFile = await ImagePicker()
//                         .pickImage(source: ImageSource.gallery);
//                     // Handle the picked image file
//                   },
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       // Handle the QR code that was scanned
//       // For instance: Navigator.pop(context, scanData.code);
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
