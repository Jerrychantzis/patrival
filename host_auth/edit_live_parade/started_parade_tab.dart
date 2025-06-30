// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/format_id.dart';

class StartedParadeTabView extends StatelessWidget {
  final CollectionReference paradeCollection;

  StartedParadeTabView({required this.paradeCollection});

  Future<void> markGroupAsCompleted(String docId) async {
    await paradeCollection.doc(docId).update({
      'completed': true,
      'finished_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: paradeCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var documents = snapshot.data!.docs;
        var startedDocuments = documents
            .where((doc) => doc.id != 'settings' && doc['started'] == true)
            .toList()
          ..sort((a, b) => a['started_at'].compareTo(b['started_at']));

        return SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: startedDocuments.length,
            itemBuilder: (context, index) {
              var doc = startedDocuments[index];
              bool isCompleted = doc['completed'] ?? false;

              return Column(
                children: [
                  ListTile(
                    title: Text('Group: ${reverseFormatDocumentID(doc.id)}'),
                    subtitle: Text('Μέλη: ${doc['member_count']}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isCompleted ? 'Τερμάτισε' : 'Παρελαύνει...',
                          style: TextStyle(
                            color: isCompleted ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!isCompleted) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Ολοκλήρωση Group'),
                              content: Text(
                                  'Είστε σίγουροι ότι θέλετε να τερματίσετε το group;'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Άκυρο'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await markGroupAsCompleted(doc.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Τερματισμός'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
