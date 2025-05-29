import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboadScreen extends StatelessWidget {
  const DashboadScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: doLogout, icon: Icon(Icons.logout))],
      ),
      body: Text("Dashboad"),
    );
  }

  void doLogout() async {
    await FirebaseAuth.instance.signOut();
  }
}
