// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_declarations, avoid_print, prefer_const_constructors, sort_child_properties_last, unnecessary_cast, use_build_context_synchronously, prefer_const_constructors_in_immutables
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../global/common/toast.dart';
import 'captain_home.dart';

class CaptainNotificationToGroup extends StatefulWidget {
  final String groupID;

  CaptainNotificationToGroup({required this.groupID});

  @override
  _CaptainNotificationToGroupState createState() =>
      _CaptainNotificationToGroupState();
}

class _CaptainNotificationToGroupState
    extends State<CaptainNotificationToGroup> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendNotification(
      String title, String messageBody, String group) async {
    setState(() {
      _isLoading = true;
    });
    final credentials = ServiceAccountCredentials.fromJson({
     //Here goes database's keys
    });
    final client = await clientViaServiceAccount(
      credentials,
      ['https://www.googleapis.com/auth/firebase.messaging'],
    );
    try {
      final fcmUrl =
          'https://fcm.googleapis.com/v1/projects/carnivaldatabase-1f814/messages:send';
      final message = jsonEncode({
        'message': {
          'topic': group,
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
        print('Notification sent successfully');
        showToastGood(message: "Επιτυχής αποστολή ειδοποίησης!");
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(formatDocumentID(group))
            .collection('notifications')
            .add({
          'title': title,
          'body': messageBody,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CaptainHomePage(),
          ),
          (route) => false,
        );
      } else {
        print('Failed to send notification: ${response.body}');
        showToast(
            message:
                "Υπήρξε κάποιο πρόβλημα με την αποστολή! \n Δοκιμάστε Ξανά!");
      }
    } catch (e) {
      print('Error sending notification: $e');
    } finally {
      client.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Αποστολή προς group'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group: ${widget.groupID}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Τίτλος ειδοποίησης',
                        border: OutlineInputBorder(),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        labelText: 'Κείμενο',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 10,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final title = _titleController.text.trim();
                        final messageBody = _bodyController.text.trim();

                        if (title.isEmpty) {
                          showToast(message: "Παρακαλώ συμπληρώστε τον τίτλο.");
                        } else if (messageBody.isEmpty) {
                          showToast(
                              message: "Παρακαλώ συμπληρώστε το κείμενο.");
                        } else {
                          sendNotification(title, messageBody, widget.groupID);
                        }
                      },
                      child: Text('Αποστολή'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
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
