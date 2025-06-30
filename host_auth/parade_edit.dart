// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/toast.dart';

class ParadeEdit extends StatefulWidget {
  @override
  _ParadeEditState createState() => _ParadeEditState();
}

class _ParadeEditState extends State<ParadeEdit> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;
  String selectedParade = 'saturday_parade'; // Default collection

  @override
  void initState() {
    super.initState();
    _subscribeToChanges();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<List<DocumentSnapshot>> getDocuments(String collection) async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection(collection).get();
      List<DocumentSnapshot> docs =
          querySnapshot.docs.where((doc) => doc.id != 'settings').toList();
      docs.sort((a, b) => (a['queue'] as int).compareTo(b['queue'] as int));
      return docs;
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  void updateQueue(String documentId, String newQueue) async {
    try {
      int? parsedValue = int.tryParse(newQueue);
      if (parsedValue != null) {
        var documentSnapshot =
            await firestore.collection(selectedParade).doc(documentId).get();
        int oldQueue = documentSnapshot['queue'];

        var querySnapshot = await firestore
            .collection(selectedParade)
            .where('queue', isEqualTo: parsedValue)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          var otherDoc = querySnapshot.docs.first;
          if (otherDoc.id != documentId) {
            _showConflictDialog(documentId, oldQueue, otherDoc.id, parsedValue);
            return;
          }
        }
        await firestore
            .collection(selectedParade)
            .doc(documentId)
            .update({'queue': parsedValue});
        showToastGood(message: 'Επιτυχής Αλλαγή Σειράς');
        setState(() {});
      } else {
        showToast(message: 'Εισάγεται αριθμό στην σειρά');
      }
    } catch (e) {
      print('Error updating queue: $e');
    }
  }

  void updateGroupQueue(String documentId, int newQueue) async {
    try {
      await firestore
          .collection('groups')
          .doc(documentId)
          .update({'queue': newQueue});
      print('Group queue updated successfully');
    } catch (e) {
      print('Error updating group queue: $e');
    }
  }

  void _showConflictDialog(
      String docId1, int oldQueue, String docId2, int newQueue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Σύγκρουση Σειρών', style: TextStyle(color: Colors.black)),
          content: Text(
              'Η σειρά $newQueue είναι ήδη σε χρήση. Θέλετε να ανταλλάξετε τις σειρές των groups;',
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ακύρωση', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _exchangeQueues(docId1, oldQueue, docId2, newQueue);
                Navigator.of(context).pop();
              },
              child: Text('Ανταλλαγή', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _exchangeQueues(
      String docId1, int oldQueue, String docId2, int newQueue) async {
    try {
      await firestore.runTransaction((transaction) async {
        transaction.update(firestore.collection(selectedParade).doc(docId1),
            {'queue': newQueue});
        transaction.update(firestore.collection(selectedParade).doc(docId2),
            {'queue': oldQueue});
        transaction.update(
            firestore.collection('groups').doc(docId1), {'queue': newQueue});
        transaction.update(
            firestore.collection('groups').doc(docId2), {'queue': oldQueue});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Οι ουρές ανταλλάχθηκαν επιτυχώς',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
        ),
      );
      setState(() {});
    } catch (e) {
      print('Error exchanging queues: $e');
    }
  }

  void _selectParade(String parade) {
    setState(() {
      selectedParade = parade;
      _subscription?.cancel();
      _subscribeToChanges();
    });
  }

  void _subscribeToChanges() {
    _subscription =
        firestore.collection(selectedParade).snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.modified) {
          var modifiedDocument = change.doc;
          var modifiedId = modifiedDocument.id;
          var modifiedQueue = modifiedDocument['queue'];

          if (selectedParade == 'saturday_parade') {
            updateGroupQueue(modifiedId, modifiedQueue);
          } else if (selectedParade == 'sunday_parade') {
            _checkAndUpdateGroupQueue(modifiedId, modifiedQueue);
          }
        }
      });
    });
  }

  void _checkAndUpdateGroupQueue(String documentId, int newQueue) async {
    try {
      var groupDocument =
          await firestore.collection('groups').doc(documentId).get();
      var parade = groupDocument['parade'];

      if (parade == 'both') {
        await firestore
            .collection('groups')
            .doc(documentId)
            .update({'queue_2': newQueue});
        print('Group queue_2 updated successfully');
      } else {
        await firestore
            .collection('groups')
            .doc(documentId)
            .update({'queue': newQueue});
        print('Group queue updated successfully');
      }
    } catch (e) {
      print('Error updating group queue: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      // Set background color to light purple
      appBar: AppBar(
        title: Text('Επεξεργασία Σειράς Παρέλασης'),
        backgroundColor: Colors.purple, // AppBar color
      ),
      body: Column(
        children: [
          PopupMenuButton<String>(
            onSelected: _selectParade,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'saturday_parade',
                  child: Text(
                    'Παρέλαση Σαββάτου',
                    style: TextStyle(
                        fontSize: 18, color: Colors.black), // Text color
                  ),
                ),
                PopupMenuItem(
                  value: 'sunday_parade',
                  child: Text(
                    'Παρέλαση Κυριακής',
                    style: TextStyle(
                        fontSize: 18, color: Colors.black), // Text color
                  ),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.black), // Icon color
                  SizedBox(width: 10),
                  Text(
                    selectedParade == 'saturday_parade'
                        ? 'Παρέλαση Σαββάτου'
                        : 'Παρέλαση Κυριακής',
                    style: TextStyle(
                        fontSize: 20, color: Colors.black), // Text color
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: getDocuments(selectedParade),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.black)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No documents found',
                          style: TextStyle(color: Colors.black)));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data![index];
                      var id = document.id;
                      var initialQueue = (document['queue'] ?? 0).toString();

                      return Column(
                        children: [
                          SizedBox(height: 10),
                          Text('Group: ${reverseFormatDocumentID(id)}',
                              style: TextStyle(color: Colors.black)),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: initialQueue,
                                  decoration: InputDecoration(
                                    labelText: 'Σειρά Παρέλασης',
                                    border: OutlineInputBorder(),
                                    labelStyle: TextStyle(color: Colors.black),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (newValue) {
                                    initialQueue = newValue;
                                  },
                                  onFieldSubmitted: (newValue) {
                                    updateQueue(id, newValue);
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.save, color: Colors.black),
                                // Icon color
                                onPressed: () {
                                  updateQueue(id, initialQueue);
                                },
                              ),
                            ],
                          ),
                          Divider(color: Colors.black), // Divider color
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
