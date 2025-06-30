// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, use_build_context_synchronously, use_key_in_widget_constructors
import 'package:carnival_app1/features/user_auth/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../global/common/toast.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/form_container_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  bool isSigningIn = false;
  bool rememberMe = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveUserCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', rememberMe);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context: context, heightPercentage: 20),
      backgroundColor: Colors.green[200],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Σύνδεση",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Κωδικός Πρόσβασης",
                  isPasswordField: true,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text("Απομνημόνευση Στοιχείων"),
                  ],
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: signInCenter,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isSigningIn
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        "Σύνδεση",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Δεν έχετε λογαριασμό;"),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                              (route) => false,
                        );
                      },
                      child: Text(
                        "Εγγραφή",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // αυτη η signInCenter ειναι για δοκιμαστικο σκοπο. παρακατω εχω την τελικη με το email verification
  void signInCenter() async {
    setState(() {
      isSigningIn = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      isSigningIn = false;
    });

    if (user != null) {

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Λαμβάνουμε το πρώτο έγγραφο από τα αποτελέσματα
        DocumentSnapshot userDoc = snapshot.docs.first;

        // Έλεγχος αν ο χρήστης είναι διαχειριστής
        if (userDoc.exists) {
          Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

          if (userData != null && userData['admin'] == true) {
            Navigator.pushNamedAndRemoveUntil(
                context, "/admin_home", (route) => false);
          } else if (userData != null &&
              userData['admin'] == false &&
              userData['captain'] == true) {

            Navigator.pushNamedAndRemoveUntil(
                context, "/captain_home", (route) => false);

          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, "/home", (route) => false);
          }
          await _saveUserCredentials();
          showToastGood(message: "Επιτυχής σύνδεση!");
          return;
        }
      }
    }

    showToast(message: "Σφάλμα κατά τη σύνδεση. Ελέγξτε τα διαπιστευτήρια σας.");
  }

  // η τελικη signInCenter
/*
  void signInCenter() async {
    setState(() {
      isSigningIn = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      isSigningIn = false;
    });

    if (user != null) {
      if (user.emailVerified) {
        // Ελέγχουμε αν υπάρχει έγγραφο με το συγκεκριμένο email
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Λαμβάνουμε το πρώτο έγγραφο από τα αποτελέσματα
          DocumentSnapshot userDoc = snapshot.docs.first;

          // Έλεγχος αν ο χρήστης είναι διαχειριστής
          if (userDoc.exists) {
            Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

            if (userData != null && userData['admin'] == true) {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/admin_home", (route) => false);
            } else if (userData != null &&
                userData['admin'] == false &&
                userData['captain'] == true) {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/captain_home", (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/home", (route) => false);
            }
            await _saveUserCredentials();
            showToastGood(message: "Επιτυχής σύνδεση!");
            return;
          }
        }
      } else {
        // Email δεν έχει επαληθευτεί
        await FirebaseAuth.instance.signOut();
        showToast(message: "Παρακαλώ επιβεβαιώστε το email σας.");
      }
    } else {
      showToast(message: "Σφάλμα κατά τη σύνδεση. Ελέγξτε τα διαπιστευτήρια σας.");
    }
  }
   */
}
