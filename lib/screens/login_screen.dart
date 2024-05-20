import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'otp_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  bool isVerificationInProgress = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: mobileController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerificationInProgress
                  ? null
                  : () {
                      final phoneNumber = mobileController.text.trim();
                      setState(() {
                        isVerificationInProgress = true;
                      });

                      authService.verifyPhoneNumber(
                        phoneNumber,
                        (PhoneAuthCredential credential) async {
                          User? user = await authService
                              .signInWithCredential(credential);
                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => HomeScreen()));
                          }
                        },
                        (FirebaseAuthException e) {
                          setState(() {
                            isVerificationInProgress = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(e.message ?? 'Verification failed')));
                        },
                        (String verificationId, int? resendToken) {
                          setState(() {
                            isVerificationInProgress = false;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => OTPScreen(
                              verificationId: verificationId,
                              firstName:
                                  '', // Not needed for login, pass empty or null
                              lastName:
                                  '', // Not needed for login, pass empty or null
                              dob:
                                  '', // Not needed for login, pass empty or null
                              email:
                                  '', // Not needed for login, pass empty or null
                              password:
                                  '', // Not needed for login, pass empty or null
                            ),
                          ));
                        },
                        (String verificationId) {
                          setState(() {
                            isVerificationInProgress = false;
                          });
                          print("Code Auto Retrieval Timeout: $verificationId");
                        },
                      );
                    },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                child: isVerificationInProgress
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Login'),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => RegistrationScreen()));
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
