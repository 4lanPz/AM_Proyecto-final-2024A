import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'loginpage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Carga las variables de entorno
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showPermissionsDialog = false;

  @override
  void initState() {
    super.initState();
    // Inicializa la pantalla de inicio de sesión y muestra el diálogo después de que se renderice
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Platform.isAndroid || Platform.isIOS) {
        setState(() {
          _showPermissionsDialog = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Muestra el formulario de inicio de sesión
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) {
          if (_showPermissionsDialog) {
            // Muestra el diálogo para los permisos después de que el formulario de inicio de sesión se haya renderizado
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await requestLocationPermissions(context);
            });
          }
          return const LoginPage();
        },
      ),
    );
  }

  Future<void> requestLocationPermissions(BuildContext context) async {
    bool hasAccepted = await showLocationPermissionDialog(context);

    if (hasAccepted) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Manejar la denegación de permisos
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        // Manejar la denegación permanente de permisos
        return;
      }
      // Permisos concedidos
    }
  }

  Future<bool> showLocationPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permisos de Ubicación Necesarios'),
            content: Text(
                'Se necesitan permisos de ubicación para poder utilizar esta aplicación.'),
            actions: [
              TextButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
