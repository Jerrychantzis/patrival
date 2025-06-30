// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/format_id.dart';

class HostParadeTabView extends StatefulWidget {
  final CollectionReference paradeCollection;
  final String status;
  final bool paradeStarted;
  final bool paradeCompleted;

  HostParadeTabView({
    required this.paradeCollection,
    required this.status,
    required this.paradeStarted,
    required this.paradeCompleted,
  });

  @override
  _HostParadeTabViewState createState() => _HostParadeTabViewState();
}

class _HostParadeTabViewState extends State<HostParadeTabView> {
  Timer? _timer;
  DateTime? lastStarted;
  bool isLoading = true;
  int currentMembers = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    _fetchLastStarted();
    _fetchCurrentMembers();
  }

  Future<void> _fetchCurrentMembers() async {
    var settingsDoc = await widget.paradeCollection.doc('settings').get();
    if (settingsDoc.exists) {
      if (mounted) {
        setState(() {
          currentMembers = settingsDoc['current_members']?.toInt() ?? 0;
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchLastStarted() async {
    var settingsDoc = await widget.paradeCollection.doc('settings').get();
    if (settingsDoc.exists) {
      if (mounted) {
        setState(() {
          lastStarted = settingsDoc['lastStarted']?.toDate();
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startGroup(DocumentSnapshot doc) async {
    await doc.reference.update({
      'started': true,
      'started_at': FieldValue.serverTimestamp(),
    });

    var updatedDoc = await doc.reference.get();
    var startedAt =
        (updatedDoc.data() as Map<String, dynamic>)['started_at']?.toDate();

    if (startedAt != null) {
      await widget.paradeCollection.doc('settings').update({
        'lastStarted': startedAt,
        'current_members': doc['member_count'],
      });
      if (mounted) {
        setState(() {
          lastStarted = startedAt;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: widget.paradeCollection.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var documents = snapshot.data!.docs;
              var filteredDocuments = documents
                  .where(
                      (doc) => doc.id != 'settings' && doc['started'] == false)
                  .toList()
                ..sort((a, b) => a['queue'].compareTo(b['queue']));

              return SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocuments[index];
                    var data =
                        doc.data() as Map<String, dynamic>?; // safely cast data
                    bool hasArma = data != null &&
                        data.containsKey('arma') &&
                        data['arma'] == true;
                    return GestureDetector(
                      onTap: widget.paradeStarted && !widget.paradeCompleted
                          ? () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Ξεκίνησε το group;'),
                                    content: Text(
                                        'Το group ID: ${doc.id} ξεκίνησε;'),
                                    actions: [
                                      TextButton(
                                        child: Text('Όχι'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Ναι'),
                                        onPressed: () {
                                          startGroup(doc);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : null,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                                'Group: ${reverseFormatDocumentID(doc.id)}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Μέλη: ${doc['member_count']}'),
                                if (widget.paradeCollection.id ==
                                    'sunday_parade')
                                  Text('Άρμα: ${hasArma ? 'Ναι' : 'Όχι'}'),
                              ],
                            ),
                            trailing: Text(
                              ' ${calculateWaitingTime(doc, index, filteredDocuments, lastStarted!, hasArma)}',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  String calculateWaitingTime(DocumentSnapshot doc, int index,
      List<DocumentSnapshot> docs, DateTime lastStarted, bool hasArma) {
    if (!widget.paradeStarted || doc['started'] == true) {
      return '...';
    }

    if (lastStarted == DateTime(2000, 1, 1)) {
      lastStarted = DateTime.now();
    }

    int waitingTimeInSeconds = 0;
    int gotArma = hasArma ? 60 : 0;

    if (doc['queue'] == 1 && doc['started'] == false) {
      _fetchLastStarted();
      return 'Ξεκινάει τώρα';
    } else {
      _fetchCurrentMembers();

      for (var i = 0; i < index; i++) {
        var d = docs[i];
        int memberCount = d['member_count'].toInt();
        if (d['started'] == false) {
          waitingTimeInSeconds +=
              (((memberCount + currentMembers) / 10).ceil() * 30) + gotArma;
        }
      }
    }

    DateTime estimatedStartTime =
        lastStarted.add(Duration(seconds: waitingTimeInSeconds));
    Duration difference = estimatedStartTime.difference(DateTime.now());

    if (difference.isNegative) {
      return 'Επόμενο.. ';
    } else {
      return '${difference.inMinutes} λεπτά ';
    }
  }
}
