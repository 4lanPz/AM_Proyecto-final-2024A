import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ubicacion_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class GestionPage extends StatefulWidget {
  const GestionPage({super.key});

  @override
  _GestionPageState createState() => _GestionPageState();
}

class _GestionPageState extends State<GestionPage> {
  @override
  void initState() {
    super.initState();
    dotenv.load();
    _startLocationService();
  }

  Future<void> _startLocationService() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if (!isRunning) {
      await initializeService();
    }
  }

  Future<String> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        return userDoc['role'] ?? 'user';
      }
    }
    return 'user';
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> users = usersSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ubicacion = data['ubicacion'] as Map<String, dynamic>?;

      return {
        'id': doc.id,
        'email': data['email'],
        'role': data['role'],
        'latitud': ubicacion?['latitud'],
        'longitud': ubicacion?['longitud'],
      };
    }).toList();

    // Convertir coordenadas a direcciones
    for (var user in users) {
      final lat = user['latitud'];
      final lon = user['longitud'];
      if (lat != null && lon != null) {
        user['direccion'] = await _getAddressFromCoordinates(lat, lon);
      } else {
        user['direccion'] = 'Dirección no disponible';
      }
    }

    return users;
  }

  Future<String> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) {
      throw Exception('API Key no encontrada en el archivo .env');
    }
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'Dirección no encontrada';
      }
    } else {
      throw Exception('Error al obtener la dirección');
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gestión de Usuarios'),
      ),
      body: FutureBuilder<String>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            String userRole = snapshot.data ?? 'user';
            if (userRole == 'admin') {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadUsers(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (userSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${userSnapshot.error}'),
                    );
                  } else {
                    List<Map<String, dynamic>> users = userSnapshot.data ?? [];
                    String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    List<Map<String, dynamic>> admins =
                        users.where((user) => user['role'] == 'admin').toList();
                    List<Map<String, dynamic>> commonUsers =
                        users.where((user) => user['role'] != 'admin').toList();

                    return SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Administradores',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              admins.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No hay administradores para mostrar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    )
                                  : _buildUserTable(admins, currentUserId),
                              SizedBox(height: 20),
                              Text(
                                'Usuarios',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              commonUsers.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No hay usuarios para mostrar',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    )
                                  : _buildUserTable(commonUsers, currentUserId),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No tiene permitido gestionar usuarios',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildUserTable(
      List<Map<String, dynamic>> users, String currentUserId) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: users.map((user) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Correo: ${user['email']}'),
                  Text(
                      'Última ubicación: ${user['direccion'] ?? 'Dirección no disponible'}'),
                  Text(
                      'Últimas coordenadas: ${user['latitud']?.toString() ?? 'N/A'} ${user['longitud']?.toString() ?? 'N/A'}'),
                  if (user['id'] != currentUserId)
                    Center(
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user['id']),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
