// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_declarations, avoid_print, prefer_const_constructors, use_build_context_synchronously
import 'package:carnival_app1/global/common/toast.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin_home.dart';

class NotificationsToCaptains extends StatefulWidget {
  @override
  _NotificationsToCaptainsState createState() => _NotificationsToCaptainsState();
}

class _NotificationsToCaptainsState extends State<NotificationsToCaptains> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Future<void> sendNotification(String title, String messageBody) async {

    if (title.trim().isEmpty || messageBody.trim().isEmpty) {
      showToast(message: 'Ο τίτλος και το κείμενο δεν μπορούν να είναι κενά.');
      return;
    }

    final credentials = ServiceAccountCredentials.fromJson({
     // database keys
    });


    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );

    try {

      final fcmUrl = 'https://fcm.googleapis.com/v1/projects/carnivaldatabase-1f814/messages:send';

      final message = jsonEncode({
        'message': {
          'topic': 'captains',
          'notification': {
            'title': title,
            'body': messageBody,
          },
        },
      });

      final response = await client.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: message,
      );

      if (response.statusCode == 200) {

        await FirebaseFirestore.instance.collection('notifications_to_captains').add({
          'title': title,
          'body': messageBody,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showToastGood(message: 'Επιτυχής αποστολή ειδοποίησης!');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AdminHomePage(),
          ),
              (route) => false,
        );
      } else {
        print('Failed to send notification: ${response.body}');
        showToast(message: 'Αποτυχία αποστολής ειδοποίησης. Προσπαθήστε ξανά.');
      }
    } catch (e) {
      print('Error sending notification: $e');
      showToast(message: 'Παρουσιάστηκε σφάλμα κατά την αποστολή. Προσπαθήστε ξανά.');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Αποστολή προς αρχηγούς'),
        backgroundColor: Colors.teal,
        shadowColor: Colors.tealAccent,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Τίτλος ειδοποίησης',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Κείμενο',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final messageBody = _bodyController.text;
                sendNotification(title, messageBody);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Αποστολή'),
            ),
          ],
        ),
      ),
    );
  }
}
