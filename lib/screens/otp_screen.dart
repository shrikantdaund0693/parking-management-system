import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String? firstName;
  final String? lastName;
  final String? dob;
  final String? email;
  final String? password;

  OTPScreen({
    required this.verificationId,
    this.firstName,
    this.lastName,
    this.dob,
    this.email,
    this.password,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final otp = otpController.text.trim();
                final credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: otp,
                );
                User? user = await authService.signInWithCredential(credential);
                if (user != null) {
                  if (widget.firstName != null && widget.lastName != null && widget.dob != null && widget.email != null) {
                    // Registration flow
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'firstName': widget.firstName,
                      'lastName': widget.lastName,
                      'dob': widget.dob,
                      'email': widget.email,
                      'phoneNumber': user.phoneNumber,
                    });
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to sign in')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
