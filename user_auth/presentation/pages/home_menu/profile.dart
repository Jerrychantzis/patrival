// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avatar_change.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? userEmail;
  String? userIcon;
  int? userGroup;
  String? groupTitle;
  bool isLoading = true;
  String errorMessage = '';

  final String backgroundUrl =
      'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2FPATRA4-1024x683.jpg?alt=media&token=d00a8868-e91f-4650-92b4-cb8ceee4f5e7';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (userData.docs.isNotEmpty) {
          setState(() {
            username = userData.docs.first['username'];
            userEmail = userData.docs.first['email'];
            userIcon = userData.docs.first['icon'];
            userGroup = userData.docs.first['group'];
            isLoading = false;
          });

          if (userGroup != null) {
            await fetchGroupTitle(userGroup!);
          }
        } else {
          setState(() {
            errorMessage = 'Δεν βρέθηκαν δεδομένα για τον χρήστη';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Σφάλμα κατά την ανάκτηση των δεδομένων: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Δεν είναι συνδεδεμένος κάποιος χρήστης';
      });
    }
  }

  Future<void> fetchGroupTitle(int groupId) async {
    try {
      DocumentSnapshot groupData = await FirebaseFirestore.instance
          .collection('groups')
          .doc(formatDocumentID(groupId.toString()))
          .get();

      if (groupData.exists) {
        setState(() {
          groupTitle = groupData['title'];
        });
      } else {
        setState(() {
          groupTitle = 'Δεν βρέθηκε τίτλος για το group';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Σφάλμα κατά την ανάκτηση του τίτλου του group: $e';
      });
    }
  }

  void _getImage() async {
    String? imageUrl = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AvatarChange(currentIconUrl: userIcon, username: username),
      ),
    );

    if (imageUrl != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'icon': imageUrl});

      setState(() {
        userIcon = imageUrl;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Θέλετε να αποσυνδεθείτε;"),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/start', (route) => false);
              },
              child: Text(
                "Ναι",
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Όχι",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Αλλαγή Κωδικού Πρόσβασης"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Τρέχων Κωδικός'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Νέος Κωδικός'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Ακύρωση",
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;

                if (newPassword.length < 6) {
                  showToast(
                      message:
                          'Ο νέος κωδικός πρέπει να είναι τουλάχιστον 6 χαρακτήρες.');
                  return;
                }
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: currentPassword,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassword);
                  showToastGood(
                      message: 'Ο κωδικός πρόσβασης ενημερώθηκε επιτυχώς.');
                  Navigator.of(context).pop();
                } catch (e) {
                  showToast(
                      message:
                          'Σφάλμα κατά την αλλαγή κωδικού: Λανθασμένος τρέχων κωδικός');
                }
              },
              child: Text(
                "Αποθήκευση",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Προφίλ Χρήστη'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(backgroundUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.blueGrey.withOpacity(0.7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Όνομα Χρήστη:',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            username ?? 'Δεν βρέθηκε όνομα χρήστη',
                            style: TextStyle(fontSize: 23, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Email:',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            userEmail ?? 'Δεν βρέθηκε email',
                            style: TextStyle(fontSize: 23, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Group:',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            userGroup != null && userGroup != 0
                                ? '${userGroup.toString()} - ${groupTitle ?? 'Φόρτωση τίτλου...'}'
                                : 'Δεν έχετε group ακόμα',
                            style: TextStyle(fontSize: 23, color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Κωδικός Πρόσβασης:',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    '**********',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: _showChangePasswordDialog,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _getImage,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.transparent,
                                    child:
                                        userIcon != null && userIcon!.isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  userIcon!,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.lightBlue,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLogoutDialog,
        tooltip: 'Αποσύνδεση',
        child: Icon(Icons.logout),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
