// ignore_for_file: prefer_const_constructors, avoid_print, prefer_final_fields, use_build_context_synchronously

import 'package:carnival_app1/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:carnival_app1/features/user_auth/presentation/pages/login_page.dart';
import 'package:carnival_app1/features/user_auth/presentation/widgets/form_container_widget.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_app_bar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final String privacyPolicyText = '''
Πολιτική Προσωπικών Δεδομένων

Καλωσορίσατε στην εφαρμογή μας! Η προστασία των προσωπικών σας δεδομένων είναι πολύ σημαντική για μας. Αυτό το έγγραφο περιγράφει τον τρόπο που συλλέγουμε, χρησιμοποιούμε, διατηρούμε και προστατεύουμε τα προσωπικά σας δεδομένα στην εφαρμογή μας.

Συλλογή και Χρήση Προσωπικών Δεδομένων

Κατά την εγγραφή στην εφαρμογή μας, συλλέγουμε το email σας για να σας αναγνωρίζουμε και να σας παρέχουμε την κατάλληλη εξυπηρέτηση. Το email σας χρησιμοποιείται επίσης για να επικοινωνούμε μαζί σας σχετικά με την εφαρμογή και τις υπηρεσίες μας.

Προστασία και Ασφάλεια Δεδομένων

Τα προσωπικά σας δεδομένα αποθηκεύονται με ασφάλεια στη βάση δεδομένων Firestore της Google. Τα μέτρα που λαμβάνουμε για την προστασία των δεδομένων σας περιλαμβάνουν αλλά δεν περιορίζονται σε:

- Αυστηρή πολιτική πρόσβασης: Μόνο εξουσιοδοτημένοι υπάλληλοι έχουν πρόσβαση στα δεδομένα σας για να εκτελούν τις απαραίτητες λειτουργίες της εφαρμογής.
- Κρυπτογράφηση δεδομένων: Χρησιμοποιούμε ασφαλείς πρωτόκολλα επικοινωνίας και κρυπτογραφία για να προστατεύσουμε τα προσωπικά σας δεδομένα κατά τη μεταφορά και την αποθήκευση τους.
- Ανώνυμη χρήση: Τα δεδομένα σας χρησιμοποιούνται για εσωτερικούς σκοπούς ανάλυσης και βελτιστοποίησης της εφαρμογής, διατηρώντας πάντα την ανωνυμία σας.

Διαγραφή Δεδομένων

Έχετε το δικαίωμα να ζητήσετε τη διαγραφή ή την τροποποίηση των προσωπικών σας δεδομένων από την εφαρμογή μας. Για οποιεσδήποτε αιτήσεις ή αναζητήσεις σχετικά με την πολιτική προσωπικών δεδομένων μας, μπορείτε να επικοινωνήσετε μαζί μας στη διεύθυνση [email protected]

Συνεχίζοντας τη χρήση της εφαρμογής μας, συμφωνείτε με την παρούσα πολιτική προσωπικών δεδομένων.

Ευχαριστούμε που επιλέξατε την εφαρμογή μας και εμπιστευθήκατε τα προσωπικά σας δεδομένα σε εμάς.
''';

  bool isSigningUp = false;
  bool isTermsAccepted = false;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(context: context, heightPercentage: 20),
      backgroundColor: Colors.yellow[200],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Εγγραφή",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Όνομα Χρήστη",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Κωδικός Πρόσβασης",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isTermsAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          isTermsAccepted = value ?? false;
                        });
                      },
                    ),
                    Text("Δέχομαι τους όρους χρήσης"),
                    Spacer(),
                    TextButton(
                      onPressed: () => _showPrivacyPolicy(context),
                      child: Text("Όροι χρήσης"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: isTermsAccepted ? signUpCenter : null,
                  child: Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isTermsAccepted ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: isSigningUp
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        "Εγγραφή",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Έχετε ήδη λογαριασμό;"),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false,
                        );
                      },
                      child: Text(
                        "Σύνδεση",
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

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Πολιτική Προσωπικών Δεδομένων"),
          content: SingleChildScrollView(
            child: Text(privacyPolicyText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Κλείσιμο"),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
      showToastGood(message: "Εστάλη μήνυμα επαλήθευσης στο email σας. \n Ελέγξτε τον φάκελο ανεπιθύμητων. ");
    }
  }

  void signUpCenter() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String iconUrl = 'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/icons%2Fuser.png?alt=media&token=f5724129-e3a6-4c41-8b84-fe2e052e11df';
    bool isAdmin = false;

    final usernameSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (usernameSnapshot.exists) {
      showToast(message: 'Το όνομα χρήστη υπάρχει ήδη!');

      setState(() {
        isSigningUp = false;
      });
      return;
    } else {
      try {
        User? user = await _auth.signUpWithEmailAndPassword(email, password);

        if (user != null) {
          await sendEmailVerification(user);

          String userUid = user.uid;
          showToastGood(message: "Επιτυχής δημιουργία χρήστη!");

          await FirebaseFirestore.instance
              .collection('users')
              .doc(username)
              .set({
            'email': email,
            'username': username,
            'icon': iconUrl,
            'captain': false,
            'group': 0,
            'admin': isAdmin,
            'userUID': userUid,
          });

          await FirebaseMessaging.instance.subscribeToTopic("all");

          Navigator.pushNamedAndRemoveUntil(context, "/start", (route) => false);
        } else {
          showToast(message: "Πρόβλημα κατά τη δημιουργία του λογαριασμού");
        }
      } catch (e) {
        showToast(message: "Σφάλμα κατά τη δημιουργία του λογαριασμού: $e");
      }

      setState(() {
        isSigningUp = false;
      });
    }
  }
}
