// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:carnival_app1/global/common/format_id.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GroupNotificationHistory extends StatefulWidget {
  final String group;

  GroupNotificationHistory({required this.group});

  @override
  _GroupNotificationHistoryState createState() => _GroupNotificationHistoryState();
}

class _GroupNotificationHistoryState extends State<GroupNotificationHistory> {
  void _editNotification(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController(text: data['title']);
        final TextEditingController bodyController = TextEditingController(text: data['body']);

        return AlertDialog(
          title: Text('Επεξεργασία Ειδοποίησης'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Τίτλος'),
                ),
                TextField(
                  controller: bodyController,
                  decoration: InputDecoration(labelText: 'Κείμενο'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ακύρωση'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.group)
                    .collection('notifications')
                    .doc(id)
                    .update({
                  'title': titleController.text,
                  'body': bodyController.text,
                  'timestamp': data['timestamp'],
                }).then((_) {
                  Navigator.of(context).pop(); // Close the dialog
                  setState(() {}); // Refresh the list
                });
              },
              child: Text('Αποθήκευση'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Διαγραφή Ειδοποίησης'),
          content: Text('Είστε σίγουροι ότι θέλετε να διαγράψετε αυτήν την ειδοποίηση;'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ακύρωση'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.group)
                      .collection('notifications')
                      .doc(id)
                      .delete();
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the list
                } catch (e) {
                  print('Error deleting notification: $e');
                }
              },
              child: Text('Διαγραφή'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Άγνωστη ημερομηνία';
    final dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ιστορικό Ειδοποιήσεων για ${reverseFormatDocumentID(widget.group)}'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.group)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα κατά την φόρτωση δεδομένων'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Δεν έχει σταλθεί ακόμα καμία ειδοποίηση.'));
          } else {
            final notifications = snapshot.data!.docs;

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final doc = notifications[index];
                final id = doc.id;
                final notification = doc.data() as Map<String, dynamic>;
                final title = notification['title'] ?? 'Χωρίς τίτλος';
                final body = notification['body'] ?? 'Χωρίς κείμενο';

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(body),
                      SizedBox(height: 5),
                      Text(
                        _formatTimestamp(notification['timestamp']),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editNotification(id, notification),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNotification(id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
