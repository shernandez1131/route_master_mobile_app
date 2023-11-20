import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/services/services.dart';

class TransferBalanceScreen extends StatefulWidget {
  final String saldo;
  const TransferBalanceScreen({Key? key, required this.saldo})
      : super(key: key);

  @override
  State<TransferBalanceScreen> createState() => _TransferBalanceScreenState();
}

class _TransferBalanceScreenState extends State<TransferBalanceScreen> {
  late String userName;
  final Strategy strategy = Strategy.P2P_STAR;
  late Passenger passenger;
  Map<String, ConnectionInfo> endpointMap = {};
  bool isSearching = false;
  bool canSendBalance = false;
  String balanceReceiver = "";
  late int? userId;
  late String? token;

  @override
  void initState() {
    super.initState();
    checkAndRequestPermissions();
    loadPassengerData().then((value) {
      passenger = value!;
      userName = passenger.user!.username ?? passenger.user!.email;
    });
  }

  Future<Passenger?> loadPassengerData() async {
    userId = await UserService.getUserId();
    token = await UserService.getToken();

    if (userId != null && token != null) {
      return PassengerService.getPassengerByUserId(userId!, token!);
    }
    return null;
  }

  Future<void> checkAndRequestPermissions() async {
    // Permissions checking and requesting logic
    var permissions = [
      ph.Permission.location,
      ph.Permission.bluetooth,
      ph.Permission.bluetoothAdvertise,
      ph.Permission.bluetoothConnect,
      ph.Permission.bluetoothScan,
      ph.Permission.nearbyWifiDevices,
    ];

    var statusList = await permissions.request();

    // If any permission is permanently denied, prompt the user to enable it manually
    if (statusList.containsKey(ph.PermissionStatus.permanentlyDenied) ||
        statusList.containsKey(ph.PermissionStatus.denied)) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Permission Required'),
          content:
              Text('Please enable the necessary permissions from Settings'),
          actions: [
            TextButton(
              onPressed: () {
                // Open app settings to let the user enable permissions manually
                ph.openAppSettings();
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      ).then((value) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WillPopScope(
        onWillPop: () async {
          // Perform actions before navigating back
          bool shouldNavigate = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  '¿Está seguro que desea salir?',
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  'Si tiene una transferencia en progreso, no podrá ser cancelada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false); // Don't exit
                    },
                    child: Text('No'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (isSearching) {
                        stopServices();
                      }
                      Navigator.pop(context, true); // Exit
                    },
                    child: Text('Sí'),
                  ),
                ],
              );
            },
          );

          // Return whether to allow back navigation or not
          return shouldNavigate; // If null is returned, default to false
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                !isSearching
                    ? FutureBuilder<Passenger?>(
                        future: loadPassengerData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return ElevatedButton(
                            child: const Text(
                                "Buscar Dispositivos para Transferir"),
                            onPressed: () async {
                              try {
                                isSearching = await Nearby().startAdvertising(
                                    userName, strategy,
                                    onConnectionInitiated: (id, info) {
                                  onConnectionInit(id, info);
                                }, onConnectionResult: (id, status) {
                                  showSnackbar(context, status);
                                }, onDisconnected: (id) {
                                  showSnackbar(context,
                                      "Disconnected: ${endpointMap[id]!.endpointName}, id $id");
                                  setState(() {
                                    endpointMap.remove(id);
                                  });
                                },
                                    serviceId:
                                        'com.example.route_master_mobile_app');
                                showSnackbar(context, "BUSCANDO DISPOSITIVOS");
                                setState(() {});
                              } catch (exception) {
                                showSnackbar(context, exception.toString());
                              }
                            },
                          );
                        })
                    : ElevatedButton(
                        child: const Text("Detener Búsqueda"),
                        onPressed: () async {
                          stopServices();
                        },
                      ),
                const Divider(),
                canSendBalance
                    ? ElevatedButton(
                        child: Column(
                          children: [
                            Text(
                              "Enviar S/. ${widget.saldo}",
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "a $balanceReceiver",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        ),
                        onPressed: () async {
                          endpointMap.forEach((key, value) {
                            var transferObject = {
                              "walletId": passenger.wallet!.walletId,
                              "userEmail": passenger.user!.email,
                              "saldo": widget.saldo
                            };
                            String transferString = jsonEncode(transferObject);
                            // showSnackbar(context,
                            //     "Sending $transferString to ${value.endpointName}");
                            Nearby().sendBytesPayload(key,
                                Uint8List.fromList(transferString.codeUnits));
                          });
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void stopServices() async {
    await Nearby().stopAdvertising().then((value) async {
      isSearching = false;
      canSendBalance = false;
      await Nearby().stopAllEndpoints();
      setState(() {
        endpointMap.clear();
      });
    });
  }

  void showSnackbar(BuildContext context, dynamic content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content.toString()),
      ),
    );
  }

  void onConnectionInit(String id, ConnectionInfo info) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(
                children: [
                  const Text(
                    "Establecer conexión con el usuario:",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Text(info.endpointName, style: const TextStyle(fontSize: 15))
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      ),
                      child: Text(
                        "Rechazar Conexión",
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          canSendBalance = false;
                          await Nearby().rejectConnection(id);
                        } catch (e) {
                          showSnackbar(context, e.toString());
                        }
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      ),
                      child: Text(
                        "Aceptar Conexión",
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          endpointMap[id] = info;
                          balanceReceiver = info.endpointName;
                          canSendBalance = true;
                        });
                        Nearby().acceptConnection(
                          id,
                          onPayLoadRecieved: (endid, payload) async {
                            if (payload.type == PayloadType.BYTES) {
                              //String str = String.fromCharCodes(payload.bytes!);
                              //showSnackbar(context, "Mensaje recibido: $str");
                            }
                          },
                          onPayloadTransferUpdate:
                              (endid, payloadTransferUpdate) {
                            if (payloadTransferUpdate.status ==
                                PayloadStatus.IN_PROGRESS) {
                              print(payloadTransferUpdate.bytesTransferred);
                              showSnackbar(context, "Procesando saldo...");
                            } else if (payloadTransferUpdate.status ==
                                PayloadStatus.FAILURE) {
                              print("failed");
                              showSnackbar(
                                  context, "Fallo en transferencia de saldo");
                            } else if (payloadTransferUpdate.status ==
                                PayloadStatus.SUCCESS) {
                              stopServices();
                              double actualBalance =
                                  double.parse(passenger.wallet!.balance);
                              passenger.wallet!.balance =
                                  (actualBalance - double.parse(widget.saldo))
                                      .toString();
                              //UPDATE WALLET
                              WalletService.putWallet(passenger.wallet!, token!)
                                  .then((value) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: EdgeInsets.all(8.0),
                                      title: Text(
                                        "Saldo transferido con éxito",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                          "Regresando a la vista de perfil...",
                                          textAlign: TextAlign.center),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Aceptar'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            Navigator.of(context)
                                                .pop(); // Pop the current screen
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
