import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:todamoon_app/screens/dashboard.dart.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool hidePassword = true;
  late AwesomeDialog? _loadingDialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome Back 🚀',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Text(
                      'Login to your ToDaMoon account',
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey[200],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),

                    // Email Field
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: setTextDecoration(
                        'Email address',
                        icon: Icons.email,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required';
                        }
                        if (!EmailValidator.validate(value)) {
                          return '*Invalid email';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),

                    // Password Field
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: setTextDecoration(
                        'Password',
                        isPasswordField: true,
                        icon: Icons.lock,
                      ),
                      obscureText: hidePassword,
                      controller: passwordCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required';
                        }
                        return null;
                      },
                    ),
                    const Gap(30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration setTextDecoration(
    String label, {
    bool isPasswordField = false,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.blueGrey[900],
      prefixIcon:
          icon != null ? Icon(icon, color: Colors.lightBlueAccent) : null,
      suffixIcon:
          isPasswordField
              ? IconButton(
                onPressed: toggleShowPassword,
                icon: Icon(
                  hidePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.lightBlueAccent,
                ),
              )
              : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void toggleShowPassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void doLogin() async {
    if (!formKey.currentState!.validate()) return;

    _loadingDialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      body: Column(
        children: const [
          CircularProgressIndicator(color: Colors.lightBlueAccent),
          SizedBox(height: 20),
          Text("Logging in...", style: TextStyle(color: Colors.white)),
        ],
      ),
      dialogBackgroundColor: const Color(0xFF1C1F2A),
    )..show();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text.trim(),
          );

      final userId = userCredential.user?.uid ?? '';
      final document =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      _loadingDialog?.dismiss();

      if (document.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboadScreen(uid: userId)),
        );
      } else {
        showErrorDialog('No user data found in Firestore');
      }
    } on FirebaseAuthException catch (_) {
      _loadingDialog?.dismiss();
      showErrorDialog('Incorrect email or password');
    }
  }

  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      title: 'Login Failed',
      desc: message,
      btnOkText: 'Okay',
      btnOkOnPress: () {},
      dialogBackgroundColor: const Color(0xFF1C1F2A),
      titleTextStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
      ),
      descTextStyle: const TextStyle(color: Colors.white70),
    ).show();
  }
}
