import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:frontend/ui/pages/hospitals/hospitals.dart';
import 'dart:convert';
import 'package:frontend/services/database_hospitals/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  QrScannerState createState() => QrScannerState();
}

class QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  //late final String _server = dotenv.env["SERVER"]!;
  String? sinceToken;
  Timer? _timer;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
          title: Text('Añadir establecimiento',
              style: TextStyle(
                  fontFamily: "Lato",
                  fontSize: screenWidth * 0.06,
                  color: const Color(0xFF4F4F69),
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Color(0xFF4F4F69)),
              onPressed: () => {Navigator.pop(context)}),
          backgroundColor: const Color(0xFFF2F2F4)),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
              child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderColor: const Color(0xFFFF6600),
                    borderRadius: 20,
                    borderLength: 50,
                    borderWidth: 15,
                    cutOutSize: screenWidth * 0.6,
                    overlayColor: const Color(0xFF000000).withOpacity(0.6)),
              ),
              Positioned(
                  top: screenHeight * 0.62,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        'Escanee el código QR de',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Lato",
                          color: const Color(0xFFFFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'su establecimiento',
                        style: TextStyle(
                          fontSize: screenHeight * 0.025,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Lato",
                          color: const Color(0xFFFFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  )),
            ],
          )),
        ],
      ),
    );
  }

  Future<void> sendMessage(String roomId, String message, String accessToken,
      String matrixServer) async {
    final String serverUrl = "https://$matrixServer";
    final String url =
        "$serverUrl/_matrix/client/r0/rooms/$roomId/send/m.room.message?access_token=$accessToken";

    final Map<String, dynamic> body = {
      "msgtype": "m.text",
      "body": message,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // print("Mensaje enviado con éxito");
      } else {
        print("Error al enviar el mensaje: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("Error en la solicitud: $e");
    }
  }

  Future<void> fetchMessages(String accessToken, String roomId,
      String matrixServer, String hash) async {
    await Future.delayed(const Duration(seconds: 1));
    final String serverUrl = "https://$matrixServer";
    final String syncUrl =
        "$serverUrl/_matrix/client/r0/sync?access_token=$accessToken";

    try {
      final response = await http.get(Uri.parse(syncUrl), headers: {
        if (sinceToken != null) 'since': sinceToken!,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sinceToken = data['next_batch'];
        final rooms = data['rooms']?['join'] ?? {};

        for (var room in rooms.keys) {
          if (room == roomId) {
            final events = rooms[room]['timeline']['events'];
            for (var event in events) {
              if (event['type'] == 'm.room.message') {
                final sender = event['sender'];
                final message = event['content']['body'];
                // print("Mensaje fetcheado de $sender: $message");
                handleMessage(sender, message, matrixServer,
                    hash); // Llama a handleMessage para cada mensaje
              }
            }
          }
        }
      } else {
        print("Error en la sincronización: ${response.statusCode}");
      }
    } catch (e) {
      print("Error en la solicitud de sincronización: $e");
    }
  }

  void handleMessage(
      String sender, String message, String matrixServer, String hash) {
    // Filtra los mensajes solo del administrador
    if (sender == "@admin:$matrixServer") {
      try {
        // Decodifica el mensaje en JSON
        Map<String, dynamic> data = jsonDecode(message);

        DatabaseHelper dbHelper = DatabaseHelper();

        print("El hash recibido es: ${data['hash']}");
        print("El hash esperado es: $hash");
        if (data['hash'] == hash) {
          // Extrae los datos necesarios y los inserta en la base de datos
          Map<String, dynamic> nuevoHospital = {
            'nombre_hospital': data['nombre_hospital'],
            'nombre_servidor_local': data['nombre_servidor_local'],
            'nombre_servidor_remoto': data['nombre_servidor_remoto'],
            'user_local': data['user_local'],
            'pass_local': data['pass_local'],
            'id_hospital': data['id_hospital'],
            'ending_task_time': data['ending_task_time'],
          };

          dbHelper.insertHospital(nuevoHospital);
          print("Nuevo hospital agregado de $sender : $message");
        }
      } catch (e) {
        print("Error al decodificar el mensaje JSON: $e");
      }
    } else {
      // print("Mensaje recibido de $sender: $message");
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      Map<String, dynamic> data = json.decode(scanData.code!);

      sendMessage(data['send_to'], data['hash'], data['access_token'],
          data['matrix_server']);
      fetchMessages(data['access_token'], data['send_to'],
          data['matrix_server'], data['hash']);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Hospitals(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller?.dispose();
    super.dispose();
  }
}
