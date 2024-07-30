import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'opciones/ubicacion.dart';

class GoogleLogin extends StatelessWidget {
  const GoogleLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            signInWithGoogle(context); // Pasa el contexto a signInWithGoogle
          },
          child: const Text('Inicio de sesión con Google'),
        ),
      ),
    );
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        print(userCredential.user?.displayName);

        // Navega a la pantalla de Ubicación si el inicio de sesión es exitoso
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const Ubicacion(title: 'Ubicación')),
          (Route<dynamic> route) => false,
        );
      } else {
        print('Inicio de sesión cancelado por el usuario.');
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
    }
  }
}
