import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _displayName;
  String? _email;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(widget.uid).get();
      final user = _auth.currentUser;

      if (user != null) {
        setState(() {
          _email = user.email ?? '';
          _displayName = userDoc.exists ? userDoc['displayName'] ?? '' : '';
          _nameController.text = _displayName ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateDisplayName() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('users').doc(widget.uid).set({
        'displayName': _nameController.text.trim(),
      }, SetOptions(merge: true));

      setState(() {
        _displayName = _nameController.text.trim();
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Display name updated')));
    } catch (e) {
      print('Failed to update display name: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    // Navigate back to login or splash screen after logout
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1C1F2A),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.lightBlueAccent),
              )
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email:', style: _labelStyle()),
                    const SizedBox(height: 4),
                    Text(_email ?? 'No email', style: _valueStyle()),
                    const SizedBox(height: 24),

                    Text('Display Name:', style: _labelStyle()),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _nameController,
                      style: _valueStyle(),
                      decoration: InputDecoration(
                        hintText: 'Enter display name',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1C1F2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: updateDisplayName,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Save'),
                    ),

                    const Spacer(),

                    Center(
                      child: OutlinedButton(
                        onPressed: signOut,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          minimumSize: const Size(150, 44),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  TextStyle _labelStyle() =>
      const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold);
  TextStyle _valueStyle() => const TextStyle(color: Colors.white, fontSize: 16);
}
