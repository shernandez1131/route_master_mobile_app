import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:route_master_mobile_app/models/ticket_model.dart';
import 'package:route_master_mobile_app/screens/ticket_info_screen.dart';
import 'package:route_master_mobile_app/services/services.dart';
import 'package:scan/scan.dart';
import 'dart:convert';

class QRScannerPage extends StatefulWidget {
  final List<String> allowedBusesList;
  final Function(dynamic) callback;
  const QRScannerPage(
      {super.key, required this.allowedBusesList, required this.callback});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool canScan = true;
  String? lastScanData;
  DateTime? lastScanTime;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
    ].request();
  }

  // Modify your existing build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
              overlayColor: Colors.black.withOpacity(0.7),
            ),
          ),
          Positioned(
            top: 230.0,
            left: MediaQuery.of(context).size.width * 0.27,
            child: const Text(
              "Escanear código QR",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Positioned(
            top: 60,
            left: MediaQuery.of(context).size.width * 0.09,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 200.0,
            left: MediaQuery.of(context).size.width * 0.29,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () async {
                    await controller?.toggleFlash();
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                IconButton(
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  onPressed: () async {
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      String? str = await Scan.parse(pickedFile.path);
                      if (str != null && str.isNotEmpty) {
                        if (context.mounted) {
                          _handleQRCode(context, str);
                        }
                      } else {
                        // Show dialog if QR code data is not found
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    const Text('No se encontró un código QR'),
                                content: const Text(
                                    'La imagen seleccionada no contiene un código QR.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (canScan) {
        if (lastScanData == scanData.code &&
            lastScanTime != null &&
            DateTime.now().difference(lastScanTime!) <
                const Duration(seconds: 10)) {
          // Ignore repeated scans of the same code within 5 seconds
          return;
        }
        lastScanData = scanData.code;
        lastScanTime = DateTime.now();
        _handleQRCode(context, scanData.code ?? "");
      }
    });
  }

  void _handleQRCode(BuildContext context, String qrData) async {
    try {
      // Decode the QR code data
      Map<String, dynamic> decodedData = jsonDecode(qrData);

      // Validate the data
      if (decodedData.containsKey('companyName') &&
          decodedData.containsKey('busName') &&
          decodedData.containsKey('fares') &&
          decodedData['fares'] is Map &&
          widget.allowedBusesList.contains(decodedData['busName'])) {
        // Create a Ticket instance
        Ticket tempTicket = Ticket.fromJson(decodedData);
        tempTicket.userId = (await UserService.getUserId())!;

        // Show the confirmation dialog
        bool? confirmTicket;
        if (context.mounted) {
          confirmTicket = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirmación"),
                content: Text(
                  "¿Estás seguro de generar un boleto para el bus ${tempTicket.busName} de la empresa ${tempTicket.companyName}?",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Accept button
                    },
                    child: const Text('Aceptar'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Cancel button
                    },
                    child: const Text('Cancelar'),
                  ),
                ],
              );
            },
          );
        }
        // If the user confirms the ticket, create and navigate to the TicketInfoScreen
        if (confirmTicket == true) {
          var ticket = await TicketService.postTicket(
              tempTicket, (await UserService.getToken())!);
          ticket.amount = 0.0;
          ticket.fares = tempTicket.fares;

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketInfoScreen(
                  ticket: ticket,
                  isFromQrScan: true,
                  callback: widget.callback,
                ),
              ),
            );
          }
        }
      } else {
        _showAlertDialog(
          context,
          "Código QR inválido",
          "El código QR no contiene la información necesaria o no es de un bus para tu actual ruta.",
        );
      }
    } catch (e) {
      // Error handling (e.g., invalid JSON data)
      if (context.mounted) {
        _showAlertDialog(
          context,
          "Error",
          "El código QR es inválido, intente de nuevo.",
        );
      }
    }
  }

  void _showAlertDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
