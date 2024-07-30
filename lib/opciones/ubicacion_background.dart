import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:meta/meta.dart'; // Asegúrate de importar el paquete meta si no está ya incluido

const notificationChannelId = 'my_foreground';
const notificationId = 888;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();
  print("inicio de servicio");
  const int updateIntervalMinutes = 5; // Intervalo de actualización en minutos
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicializa las notificaciones
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Timer.periodic(const Duration(minutes: updateIntervalMinutes), (timer) async {
    print('Timer ejecutado');
    try {
      final position = await Geolocator.getCurrentPosition();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userId = user.uid;
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {
            'ubicacion': {
              'latitud': position.latitude,
              'longitud': position.longitude,
              'timestamp': FieldValue.serverTimestamp(),
            },
          },
          SetOptions(merge: true),
        );

        print('Ubicación guardada en Firestore');

        // Muestra una notificación con el mensaje actualizado
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'Ubicación Actualizada',
          'Tu ubicación se ha actualizado',
          NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'ic_launcher',
              ongoing:
                  false, // Permitir que el usuario descarte la notificación
              importance: Importance.high,
              priority: Priority.high,
              autoCancel:
                  true, // Añadir esta línea para hacer la notificación descartable
            ),
          ),
        );
      } else {
        print('No hay usuario autenticado');
      }
    } catch (e) {
      print("Error al obtener la ubicación o enviar a Firestore: $e");
    }
  });

  // Configura el servicio para que funcione en segundo plano
  service.invoke('setAsBackground');
}

Future<void> initializeService() async {
  await Firebase.initializeApp();
  final service = FlutterBackgroundService();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode:
          true, // Asegúrate de que el servicio esté en modo primer plano
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Servicio de ubicación',
      initialNotificationContent: 'Servicio de ubicación activo',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  // Inicia el servicio
  service.startService();
}
