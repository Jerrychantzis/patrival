// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'package:carnival_app1/features/host_auth/edit_live_parade/parade_stats.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:carnival_app1/global/common/format_id.dart';
import '../../../global/common/toast.dart';
import 'parade_tab_view.dart';
import 'started_parade_tab.dart';

class LiveParadeEditNew extends StatefulWidget {
  @override
  _LiveParadeEditNewState createState() => _LiveParadeEditNewState();
}

class _LiveParadeEditNewState extends State<LiveParadeEditNew> {
  String? selectedParade;
  CollectionReference? paradeCollection;
  DateTime? paradeDay;
  bool paradeStarted = false;
  bool paradeCompleted = false;
  bool isLoading = false;
  TextEditingController liveStreamController = TextEditingController();

  void selectParade(String parade) async {
    setState(() {
      isLoading = true;
    });

    selectedParade = parade;
    paradeCollection = FirebaseFirestore.instance.collection(parade);
    await fetchParadeDay();
    await fetchParadeStatus();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchParadeDay() async {
    if (paradeCollection != null) {
      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists) {
        if (mounted) {
          setState(() {
            paradeDay = settingsDoc['day']?.toDate();
          });
        }
      }
    }
  }

  Future<void> fetchParadeStatus() async {
    if (paradeCollection != null) {
      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists) {
        if (mounted) {
          setState(() {
            paradeStarted = settingsDoc['started'] ?? false;
            paradeCompleted = settingsDoc['completed'] ?? false;
          });
        }
      }
    }
  }

  Future<void> startParade() async {
    if (paradeCollection != null) {
      await paradeCollection!.doc('settings').update({
        'started': true,
        'started_at': FieldValue.serverTimestamp(),
        'lastStarted': FieldValue.serverTimestamp(),
      });
      fetchParadeStatus();
    }
  }

  Future<void> completeParade() async {
    if (paradeCollection != null) {
      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists && settingsDoc['started'] == true) {
        await paradeCollection!.doc('settings').update({
          'completed': true,
          'finished_at': FieldValue.serverTimestamp(),
        });
        fetchParadeStatus();
      }
    }
  }

  Future<void> resetParade() async {
    if (paradeCollection != null) {
      var snapshot = await paradeCollection!.get();
      var docs = snapshot.docs;

      for (var doc in docs) {
        await doc.reference.update({
          'started': false,
          'completed': false,
        });
      }

      fetchParadeStatus();

      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists &&
          settingsDoc['started'] == true &&
          docs.every((doc) => doc['started'] == false)) {
        if (mounted) {
          setState(() {
            paradeStarted = true;
            paradeCompleted = false;
            paradeDay = DateTime.now();
          });
        }
      }

      await paradeCollection!.doc('settings').update({
        'current_members': 0,
        'lastStarted': Timestamp.fromDate(DateTime(2000, 1, 1)),
      });
    }
  }

  Future<void> changeParadeDay() async {
    if (paradeCollection != null) {
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: paradeDay ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (selectedDate != null) {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(paradeDay ?? DateTime.now()),
        );

        if (selectedTime != null) {
          DateTime selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          await paradeCollection!.doc('settings').update({
            'day': selectedDateTime,
          });

          if (mounted) {
            setState(() {
              paradeDay = selectedDateTime;
            });
          }
        }
      }
    }
  }

  Future<void> setLiveStreamUrl() async {
    if (liveStreamController.text.isNotEmpty) {

      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('admin', isEqualTo: true)
          .get();

      for (var doc in adminSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .update({
          'live_stream': liveStreamController.text,
        });
      }
        showToastGood(message: 'Η ζωντανή μετάδοση ενημερώθηκε επιτυχώς ');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Επεξεργασία Ζωντανής Παρέλασης'),
      ),
      body: Column(
        children: [
          if (isLoading) ...[
            Center(
              child: CircularProgressIndicator(),
            ),
            SizedBox(height: 16),
            Center(
              child: CircularProgressIndicator(),
            ),
          ] else ...[
            if (paradeDay != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ημέρα και Ώρα Παρέλασης: ${paradeDay!.day}/${paradeDay!.month}/${paradeDay!.year} ${paradeDay!.hour}:${paradeDay!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  onSelected: selectParade,
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'saturday_parade',
                        child: Text('Παρέλαση Σαββάτου',
                            style: TextStyle(fontSize: 18)),
                      ),
                      PopupMenuItem(
                        value: 'sunday_parade',
                        child: Text('Παρέλαση Κυριακής',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ];
                  },
                  child: Text(
                    selectedParade == null
                        ? 'Επιλέξτε Παρέλαση'
                        : selectedParade == 'saturday_parade'
                        ? 'Παρέλαση Σαββάτου'
                        : 'Παρέλαση Κυριακής',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            if (selectedParade == null) ...[
              SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ParadeStats()),
                      );
                    },
                    child: Text('Στατιστικά Παρελάσεων'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ορισμός ζωντανής μετάδοσης'),
                            content: TextField(
                              controller: liveStreamController,
                              decoration: InputDecoration(
                                hintText: 'Εισάγετε το URL',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Άκυρο'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setLiveStreamUrl();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Αποθήκευση'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('Ορισμός ζωντανής μετάδοσης'),
                  ),
                ],
              ),
            ],
            if (selectedParade != null) ...[
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Επιβεβαίωση Έναρξης'),
                              content: Text('Είστε σίγουροι ότι θέλετε να ξεκινήσετε την παρέλαση;'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Άκυρο'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    startParade();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Έναρξη'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Έναρξη Παρέλασης'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: changeParadeDay,
                      child: Text('Ημέρα Παρέλασης'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Επιβεβαίωση Τερματισμού'),
                              content: Text('Είστε σίγουροι ότι θέλετε να τερματίσετε την παρέλαση;'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Άκυρο'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    completeParade();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Τερματισμός'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Τερματισμός Παρέλασης'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Επιβεβαίωση Επαναφοράς'),
                              content: Text('Είστε σίγουροι ότι θέλετε να επαναφέρετε την παρέλαση; ΠΡΟΣΟΧΗ!!! Αυτή η ενέργεια θα επαναφέρει και τα στατιστικά των παρελάσεων! '),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Άκυρο'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    resetParade();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Επαναφορά'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Επαναφορά Παρέλασης'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Αναμονή'),
                          Tab(text: 'Ξεκίνησαν'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            HostParadeTabView(
                              paradeCollection: paradeCollection!,
                              status: 'waiting',
                              paradeStarted: paradeStarted,
                              paradeCompleted: paradeCompleted,
                            ),
                            StartedParadeTabView(
                              paradeCollection: paradeCollection!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

}
