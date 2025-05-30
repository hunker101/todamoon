import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todamoon_app/firebase_options.dart';
import 'package:todamoon_app/screens/first_screen.dart';
import 'package:todamoon_app/screens/home.dart';
import 'package:todamoon_app/screens/nav/nav_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(TodaMoon());
}

class TodaMoon extends StatelessWidget {
  const TodaMoon({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            var uid = snapshot.data?.uid ?? '';
            print(uid);
            return FutureBuilder(
              future:
                  FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, docSnapshot) {
                if (docSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                var data = docSnapshot.data;
                if (data != null) {
                  return MainNavScreen(uid: uid); //data['firstName']
                } else {
                  return HomeScreen();
                }
              },
            );
          }
          return FirstScreen(); //no user data
        },
      ),
    );
  }
}
