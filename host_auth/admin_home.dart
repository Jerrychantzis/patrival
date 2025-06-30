// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:carnival_app1/features/host_auth/group_edit.dart';
import 'package:carnival_app1/features/host_auth/captain_list.dart';
import 'package:carnival_app1/features/user_auth/presentation/pages/start_page.dart';
import 'package:carnival_app1/features/host_auth/parade_edit.dart';
import 'package:carnival_app1/features/host_auth/notifications/notification_center.dart';
import 'edit_live_parade/live_parade_edit.dart';
//import 'parade_live_change.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Κέντρο Διαχείρησης Εφαρμογής'),
        backgroundColor: Colors.pinkAccent, // AppBar color
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.orangeAccent], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupsEdit()),
                    );
                  },
                  child: Text('Επεξεργασία Group'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CaptainList()),
                    );
                  },
                  child: Text('Λίστα Αρχηγών & Διαχειριστών'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LiveParadeEditNew()),
                    );
                  },
                  child: Text('Επεξεργασία Ζωντανής Παρέλασης'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ParadeEdit()),
                    );
                  },
                  child: Text('Επεξεργασία Σειράς Παρέλασης'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationCenter()),
                    );
                  },
                  child: Text('Αποστολή Ειδοποιήσεων'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => StartPage()),
                          (route) => false,
                    );
                  },
                  child: Text('Αποσύνδεση'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
