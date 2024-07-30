import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State createState() => _RegistroState();
}

class _RegistroState extends State<RegistroPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: error.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Correo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Este campo es obligatorio";
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    UserCredential? userCredential =
                        await register(email, password);
                    if (userCredential != null) {
                      setState(() {
                        error = ''; // Limpiar error al registrar correctamente
                      });
                      // Registro exitoso, redirigir a la pantalla de login
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    }
                  }
                },
                child: const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential?> register(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Después de registrar el usuario, agregar detalles a Firestore
      await _createUserInFirestore(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'email-already-in-use') {
            error = 'Correo en uso, pruebe otro correo';
          } else {
            error = 'Error al registrar al usuario: ${e.message}';
          }
        });
        // Clear error after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              error = '';
            });
          }
        });
      }
      return null;
    }
  }

  Future<void> _createUserInFirestore(User? user) async {
    if (user == null) return;

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        await userDoc.set({
          'email': user.email,
          'role': 'user',
          'uid': user.uid,
          'ubicacion': {
            'latitud': -0.180653,
            'longitud': -78.467838,
            'timestamp': FieldValue.serverTimestamp(),
          },
        });
        print('Usuario añadido a Firestore: ${user.uid}');
      } else {
        print('Usuario ya existe en Firestore: ${user.uid}');
      }
    } catch (e) {
      print('Error al agregar usuario a Firestore: $e');
    }
  }
}
