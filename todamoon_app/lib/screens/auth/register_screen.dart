import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:todamoon_app/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  final fnCtrl = TextEditingController();
  final lnCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

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
                      'Register New Account 🚀',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    Text(
                      'Fill in the form to create a client account.',
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey[200],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),

                    // First Name
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: setTextDecoration(
                        'First Name',
                        icon: Icons.person,
                      ),
                      controller: fnCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),

                    // Last Name
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: setTextDecoration(
                        'Last Name',
                        icon: Icons.person_outline,
                      ),
                      controller: lnCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),

                    // Email
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

                    // Password
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
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),

                    // Confirm Password
                    TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: setTextDecoration(
                        'Confirm Password',
                        isPasswordField: true,
                        icon: Icons.lock_outline,
                      ),
                      obscureText: hidePassword,
                      controller: confirmPassCtrl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '*Required';
                        }
                        if (passwordCtrl.text != value) {
                          return '*Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const Gap(30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: doRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const Gap(16),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.lightBlueAccent),
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

  void doRegister() async {
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
          Text("Registering account...", style: TextStyle(color: Colors.white)),
        ],
      ),
      dialogBackgroundColor: const Color(0xFF1C1F2A),
    )..show();

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': fnCtrl.text.trim(),
            'lastName': lnCtrl.text.trim(),
            'email': emailCtrl.text.trim(),
          });

      _loadingDialog?.dismiss();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Success',
        desc: 'Your account has been registered successfully.',
        btnOkText: 'Login',
        btnOkOnPress: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        dialogBackgroundColor: const Color(0xFF1C1F2A),
        titleTextStyle: const TextStyle(
          color: Colors.lightGreenAccent,
          fontWeight: FontWeight.bold,
        ),
        descTextStyle: const TextStyle(color: Colors.white70),
      ).show();
    } on FirebaseAuthException catch (ex) {
      _loadingDialog?.dismiss();
      String errorMessage = ex.message ?? 'Registration failed';

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Registration Failed',
        desc: errorMessage,
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
}
