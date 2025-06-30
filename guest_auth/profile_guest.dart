// ignore_for_file: use_super_parameters, prefer_const_constructors, avoid_print, prefer_const_declarations
import 'package:carnival_app1/features/user_auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../user_auth/presentation/pages/signup_page.dart';

class ProfileGuest extends StatelessWidget {
  const ProfileGuest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL της εικόνας από τη βάση δεδομένων
    final String imageUrl = 'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2FPATRA4-1024x683.jpg?alt=media&token=d00a8868-e91f-4650-92b4-cb8ceee4f5e7';

    return Scaffold(
      appBar: AppBar(
        title: Text('Προφίλ'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      TextSpan(
                        text:
                        "Δεν είστε συνδεδεμένοι! Για να μπορέσετε να επικοινωνήσετε με τους διοργανωτές για συμμετοχή σας στην παρέλαση μπορείτε να κάνετε ",
                      ),
                      TextSpan(
                        text: "εγγραφή",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                                  (route) => false,
                            );
                          },
                      ),
                      TextSpan(
                        text: " στην εφαρμογή! Αν έχετε ήδη λογαριασμό ",
                      ),
                      TextSpan(
                        text: "συνδεθείτε",
                        style: TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                                  (route) => false,
                            );
                          },
                      ),
                      TextSpan(
                        text: "!",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
