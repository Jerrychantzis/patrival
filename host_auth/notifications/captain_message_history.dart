// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CaptainMessageHistory extends StatefulWidget {
  @override
  _CaptainMessageHistoryState createState() => _CaptainMessageHistoryState();
}

class _CaptainMessageHistoryState extends State<CaptainMessageHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getCaptainMessageHistory() async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications_to_captains')
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<void> _editMessage(
      BuildContext context, String id, Map<String, dynamic> message) async {
    final titleController = TextEditingController(text: message['title']);
    final bodyController = TextEditingController(text: message['body']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Επεξεργασία Μηνύματος'),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ακύρωση'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _firestore
                      .collection('notifications_to_captains')
                      .doc(id)
                      .update({
                    'title': titleController.text,
                    'body': bodyController.text,
                    'timestamp': message['timestamp'],
                  });
                  setState(() {});
                } catch (e) {
                  print('Error updating message: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Σφάλμα κατά την ενημέρωση του μηνύματος.')),
                  );
                }
              },
              child: Text('Αποθήκευση'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(BuildContext context, String id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Διαγραφή Μηνύματος'),
          content:
              Text('Είστε σίγουροι ότι θέλετε να διαγράψετε αυτό το μήνυμα;'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ακύρωση'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _firestore
                      .collection('notifications_to_captains')
                      .doc(id)
                      .delete();
                  setState(() {}); // Refresh the list
                } catch (e) {
                  print('Error deleting message: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Σφάλμα κατά τη διαγραφή του μηνύματος.')),
                  );
                }
              },
              child: Text('Διαγραφή'),
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
        title:
            Text('Ιστορικό Μηνυμάτων', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a rebuild of the widget tree to refresh data
          setState(() {});
        },
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _getCaptainMessageHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Προέκυψε σφάλμα'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Δεν βρέθηκαν μηνύματα'));
            }

            final messages = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index].data() as Map<String, dynamic>;
                var id = messages[index].id;
                var timestamp = message['timestamp'] as Timestamp;
                var formattedDate =
                    DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate());

                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      message['title'] ?? 'Χωρίς Τίτλο',
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Text(
                          message['body'] ?? 'Χωρίς Μήνυμα',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Ημερομηνία: $formattedDate',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editMessage(context, id, message),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMessage(context, id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
