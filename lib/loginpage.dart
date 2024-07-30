import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registerpage.dart';
import 'navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  late String email, password;
  final _formKey = GlobalKey<FormState>();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Inicio de sesión",
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: formulario(),
          ),
          buttonLogin(),
          const SizedBox(height: 12),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ElevatedButton(
              onPressed: () async {
                await signInWithGoogle(context);
              },
              child: const Text("Iniciar sesión con Google"),
            ),
          ),
          const SizedBox(height: 12),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroPage()),
                );
              },
              child: const Text("Registrarse"),
            ),
          ),
        ],
      ),
    );
  }

  Widget formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmail(),
          const Padding(padding: EdgeInsets.only(top: 12)),
          buildPassword(),
        ],
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Correo",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (String? value) {
        email = value!;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "Este campo es obligatorio";
        }
        return null;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
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
      onSaved: (String? value) {
        password = value!;
      },
    );
  }

  Widget buttonLogin() {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            UserCredential? credenciales = await login(email, password);
            if (credenciales != null) {
              await _checkAndCreateUser(credenciales.user);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Navigation()),
                (Route<dynamic> route) => false,
              );
            }
          }
        },
        child: const Text("Iniciar sesión"),
      ),
    );
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Para la web
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithPopup(authProvider);
        if (userCredential.user != null) {
          await _checkAndCreateUser(userCredential.user);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Navigation()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Para Android
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut(); // Cierra la sesión actual

        GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser != null) {
          GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _checkAndCreateUser(userCredential.user);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Navigation()),
              (Route<dynamic> route) => false,
            );
          }
        }
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
    }
  }

  Future<void> _checkAndCreateUser(User? user) async {
    if (user == null) return;

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    DocumentSnapshot doc = await userDoc.get();
    if (!doc.exists) {
      // Si el usuario no existe en Firestore, créalo con un rol básico
      await userDoc.set({
        'email': user.email,
        'role':
            'user', // O 'admin' si quieres hacer que ciertos usuarios sean administradores por defecto
        'uid': user.uid,
      });
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        error = ''; // Limpiar error al iniciar sesión correctamente
      });
      await _checkAndCreateUser(userCredential.user);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          error = 'Contraseña incorrecta';
        } else {
          error = 'Usuario no existe o contraseña incorrecta';
        }
      });
      // Clear error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          error = '';
        });
      });
      return null;
    }
  }
}
