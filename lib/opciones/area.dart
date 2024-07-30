import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geodesy/geodesy.dart' as geodesy;

class Area extends StatefulWidget {
  const Area({super.key, required this.title});

  final String title;

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<gmaps.Polygon> _polygons = {};
  Set<gmaps.Marker> _markers = {};
  List<gmaps.LatLng> _puntos = [];
  gmaps.GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUbicaciones();
  }

  @override
  void dispose() {
    _mapController?.dispose(); // Limpiar el controlador del mapa
    super.dispose();
  }

  Future<void> _cargarUbicaciones() async {
    try {
      final users = await _firestore.collection('users').get();
      List<gmaps.LatLng> puntos = [];

      for (var userDoc in users.docs) {
        final userData = userDoc.data();
        final ubicacion = userData['ubicacion'];
        final email = userData['email']; // Obtener el correo del usuario

        if (ubicacion != null) {
          final lat = ubicacion['latitud'];
          final lng = ubicacion['longitud'];

          if (lat != null && lng != null) {
            final point = gmaps.LatLng(lat, lng);
            puntos.add(point);
            _markers.add(
              gmaps.Marker(
                markerId: gmaps.MarkerId(point.toString()),
                position: point,
                infoWindow: gmaps.InfoWindow(
                  title: email,
                  snippet: 'Lat: $lat, Lng: $lng',
                ),
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _puntos = puntos;

          if (_puntos.length >= 3) {
            _polygons = {
              gmaps.Polygon(
                polygonId: gmaps.PolygonId('terreno'),
                points: _puntos,
                strokeColor: Colors.blue,
                strokeWidth: 2,
                fillColor: Colors.blue.withOpacity(0.2),
              )
            };
          } else {
            _polygons = {};
          }

          if (_mapController != null) {
            _mapController!.animateCamera(
              gmaps.CameraUpdate.newLatLngBounds(
                gmaps.LatLngBounds(
                  southwest: gmaps.LatLng(
                    _puntos.isNotEmpty
                        ? _puntos
                            .map((e) => e.latitude)
                            .reduce((a, b) => a < b ? a : b)
                        : 0.0,
                    _puntos.isNotEmpty
                        ? _puntos
                            .map((e) => e.longitude)
                            .reduce((a, b) => a < b ? a : b)
                        : 0.0,
                  ),
                  northeast: gmaps.LatLng(
                    _puntos.isNotEmpty
                        ? _puntos
                            .map((e) => e.latitude)
                            .reduce((a, b) => a > b ? a : b)
                        : 0.0,
                    _puntos.isNotEmpty
                        ? _puntos
                            .map((e) => e.longitude)
                            .reduce((a, b) => a > b ? a : b)
                        : 0.0,
                  ),
                ),
                50,
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Error al cargar ubicaciones: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Conversión de coordenadas geográficas a coordenadas cartesianas
  double latLngToX(double lat) {
    return lat * 111320; // Aproximadamente 111,320 metros por grado de latitud
  }

  double latLngToY(double lng) {
    return lng *
        40008000 /
        360; // Aproximadamente 40,008,000 metros de circunferencia terrestre dividido entre 360 grados
  }

  // Cálculo del área en coordenadas cartesianas
  double _calcularArea(List<gmaps.LatLng> puntos) {
    if (puntos.length < 3) {
      return 0.0; // No es posible calcular el área con menos de 3 puntos
    }

    List<geodesy.LatLng> latLngList = puntos
        .map((e) =>
            geodesy.LatLng(latLngToX(e.latitude), latLngToY(e.longitude)))
        .toList();

    // Usa el método estático calculatePolygonArea de PolygonArea
    double area = geodesy.PolygonArea.calculatePolygonArea(latLngList);
    return area;
  }

  @override
  Widget build(BuildContext context) {
    double area = _calcularArea(_puntos);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                gmaps.GoogleMap(
                  initialCameraPosition: gmaps.CameraPosition(
                    target: _puntos.isNotEmpty
                        ? _puntos.first
                        : gmaps.LatLng(-0.180653, -78.467838), // Quito, Ecuador
                    zoom: 15,
                  ),
                  markers: _markers,
                  polygons: _polygons,
                  onMapCreated: (gmaps.GoogleMapController controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                ),
                if (_puntos.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(8),
                      child: Text(
                          'Área del polígono: ${area.toStringAsFixed(2)} m²'),
                    ),
                  ),
              ],
            ),
    );
  }
}
