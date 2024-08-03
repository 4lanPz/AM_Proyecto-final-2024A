import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key, required this.title});

  final String title;

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Marker? _currentMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (kIsWeb) {
      try {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          _updateLocation(LatLng(position.latitude, position.longitude));
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition();
        if (mounted) {
          _updateLocation(LatLng(position.latitude, position.longitude));
        }

        Geolocator.getPositionStream().listen((Position position) {
          if (mounted) {
            _updateLocation(LatLng(position.latitude, position.longitude));
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _updateLocation(LatLng position) {
    setState(() {
      _currentPosition = position;
      if (kIsWeb) {
        // Solo actualizar el marcador en la vista web
        _currentMarker = Marker(
          markerId: MarkerId('currentLocation'),
          position: position,
          infoWindow: InfoWindow(title: 'Tu Ubicación Actual'),
        );
      }
      _isLoading = false;
    });

    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    }
  }

  Future<void> _guardarUbicacion() async {
    if (_currentPosition != null) {
      final user = _auth.currentUser;
      if (user != null) {
        final userId = user.uid;

        try {
          await _firestore.collection('users').doc(userId).set(
            {
              'ubicacion': {
                'latitud': _currentPosition!.latitude,
                'longitud': _currentPosition!.longitude,
                'timestamp': FieldValue.serverTimestamp(),
              },
            },
            SetOptions(merge: true),
          );

          if (mounted) {
            _showSnackBar('Ubicación guardada correctamente');
          }
        } catch (e) {
          if (mounted) {
            _showSnackBar('Error al guardar la ubicación: $e');
          }
        }
      }
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Cerrar',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? LatLng(-0.180653, -78.467838),
                    zoom: 15,
                  ),
                  myLocationEnabled: !kIsWeb, // Desactivar solo en web
                  myLocationButtonEnabled: !kIsWeb, // Desactivar solo en web
                  mapType: MapType.normal,
                  markers: kIsWeb && _currentMarker != null
                      ? {_currentMarker!}
                      : {}, // Mostrar marcador solo en web
                  onMapCreated: (GoogleMapController controller) {
                    if (mounted) {
                      setState(() {
                        _mapController = controller;
                      });
                    }
                  },
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: _guardarUbicacion,
                    child: Text('Guardar Ubicación'),
                  ),
                ),
              ],
            ),
    );
  }
}
