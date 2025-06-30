// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, avoid_print, library_private_types_in_public_api, unused_field, prefer_const_constructors_in_immutables, sort_child_properties_last
import 'package:flutter/material.dart';
import '../admin_home.dart';
import 'notification_to_all.dart';
import 'notification_to_group.dart';

class NotificationCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Light purple background
      appBar: AppBar(
        title: Text('Κέντρο Ειδοποιήσεων'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminHomePage(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationSenderToAll()),
                  );
                },
                child: Text('Αποστολή προς όλους τους χρήστες'),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationToGroup()),
                  );
                },
                child: Text('Αποστολή προς ένα group'),
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
            ],
          ),
        ),
      ),
    );
  }
}
