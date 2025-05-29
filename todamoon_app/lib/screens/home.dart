import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todamoon_app/screens/auth/login_screen.dart';
import 'package:todamoon_app/screens/auth/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg.png'),
              alignment: Alignment.topCenter,
              opacity: 0.12,
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🚀 ToDaMoon',
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Text(
                'Your gateway to learning & tracking crypto!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blueGrey[200],
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login, color: Colors.black),
                  label: Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => LoginScreen())),
                ),
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.app_registration,
                    color: Colors.lightBlueAccent,
                  ),
                  label: Text(
                    'Register',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.lightBlueAccent,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      ),
                ),
              ),
              const Gap(48),
            ],
          ),
        ),
      ),
    );
  }
}
