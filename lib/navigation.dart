import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'opciones/area.dart';
import 'opciones/gestion.dart';
import 'opciones/ubicacion.dart';
import 'loginpage.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const GestionPage(),
    const Ubicacion(
      title: 'Ubicación',
    ),
    const Area(title: 'Area'),
  ];

  void onTabTapped(int index) async {
    if (index == 3) {
      // Acción de cerrar sesión
      await FirebaseAuth.instance.signOut(); // Cerrar sesión
      // Redirigir directamente a LoginPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue, // Color para el ítem seleccionado
        unselectedItemColor:
            Colors.black, // Color para los ítems no seleccionados
        backgroundColor:
            Colors.white, // Color de fondo de la barra de navegación
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Gestión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Area',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.logout,
              color: Colors.red, // Color del ícono de cerrar sesión
            ),
            label: 'Cerrar Sesión',
          ),
        ],
      ),
    );
  }
}
