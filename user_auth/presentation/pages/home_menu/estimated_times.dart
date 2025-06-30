// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables, sized_box_for_whitespace, deprecated_member_use, use_build_context_synchronously, sort_child_properties_last

import 'package:carnival_app1/global/common/format_id.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveParadeView extends StatefulWidget {
  @override
  _LiveParadeViewState createState() => _LiveParadeViewState();
}

class _LiveParadeViewState extends State<LiveParadeView> {
  String? selectedParade;
  CollectionReference? paradeCollection;
  DateTime? saturdayParadeDay;
  DateTime? sundayParadeDay;
  bool paradeStarted = false;
  bool paradeCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchParadeDays();
  }

  Future<void> fetchParadeDays() async {
    var saturdayDoc = await FirebaseFirestore.instance
        .collection('saturday_parade')
        .doc('settings')
        .get();
    var sundayDoc = await FirebaseFirestore.instance
        .collection('sunday_parade')
        .doc('settings')
        .get();

    setState(() {
      if (saturdayDoc.exists) {
        saturdayParadeDay = saturdayDoc['day']?.toDate();
      }
      if (sundayDoc.exists) {
        sundayParadeDay = sundayDoc['day']?.toDate();
      }
    });
  }

  void selectParade(String parade) {
    setState(() {
      selectedParade = parade;
      paradeCollection = FirebaseFirestore.instance.collection(parade);
      fetchParadeStatus();
    });
  }

  Future<void> fetchParadeStatus() async {
    if (paradeCollection != null) {
      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists) {
        setState(() {
          paradeStarted = settingsDoc['started'] ?? false;
          paradeCompleted = settingsDoc['completed'] ?? false;
        });
      }
    }
  }

  Future<void> watchParade() async {
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc('admin').get();
    if (userDoc.exists && userDoc['live_stream'] != null) {
      String liveStreamUrl = userDoc['live_stream'];
      if (await canLaunch(liveStreamUrl)) {
        await launch(liveStreamUrl);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Σφάλμα'),
            content: Text('Το βίντεο της παρέλασης δεν ειναι διαθεσιμο!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Κλείσιμο'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Προσοχή'),
          content: Text('Δεν βρέθηκε το link για την ζωντανή μετάδοση.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Κλείσιμο'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        title: Text('Ζωντανή Προβολή Παρέλασης',
            style: TextStyle(color: Colors.black)),
      ),
      backgroundColor: Colors.tealAccent,
      body: Column(
        children: [
          if (selectedParade == null &&
              saturdayParadeDay != null &&
              sundayParadeDay != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: watchParade,
                    child: Text('Παρακολούθηση Παρέλασης'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        'Παρέλαση Σαββάτου:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${saturdayParadeDay!.day}/${saturdayParadeDay!.month}/${saturdayParadeDay!.year} ${saturdayParadeDay!.hour}:${saturdayParadeDay!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 4.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        'Παρέλαση Κυριακής:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${sundayParadeDay!.day}/${sundayParadeDay!.month}/${sundayParadeDay!.year} ${sundayParadeDay!.hour}:${sundayParadeDay!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedParade,
                hint: Text('Επιλέξτε Παρέλαση',
                    style: TextStyle(color: Colors.black)),
                onChanged: (String? newValue) {
                  selectParade(newValue!);
                },
                items: [
                  DropdownMenuItem(
                    value: 'saturday_parade',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Παρέλαση Σαββάτου',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'sunday_parade',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.black),
                        SizedBox(width: 10),
                        Text('Παρέλαση Κυριακής',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selectedParade != null) ...[
            SizedBox(height: 20),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Material(
                      color: Colors.tealAccent,
                      child: TabBar(
                        tabs: [
                          Tab(
                              text: 'Αναμονή',
                              icon:
                                  Icon(Icons.access_time, color: Colors.black)),
                          Tab(
                              text: 'Ξεκίνησαν',
                              icon:
                                  Icon(Icons.play_arrow, color: Colors.black)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ParadeTabView(
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
      ),
    );
  }
}

class ParadeTabView extends StatefulWidget {
  final CollectionReference paradeCollection;
  final String status;
  final bool paradeStarted;
  final bool paradeCompleted;

  ParadeTabView({
    required this.paradeCollection,
    required this.status,
    required this.paradeStarted,
    required this.paradeCompleted,
  });

  @override
  _ParadeTabViewState createState() => _ParadeTabViewState();
}

class _ParadeTabViewState extends State<ParadeTabView> {
  DateTime? lastStarted;
  bool isLoading = true;
  int currentMembers = 0;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            stream: widget.paradeCollection.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                );
              }

              var documents = snapshot.data!.docs;
              var filteredDocuments = documents
                  .where(
                      (doc) => doc.id != 'settings' && doc['started'] == false)
                  .toList()
                ..sort((a, b) => a['queue'].compareTo(b['queue']));

              return ListView.builder(
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  var doc = filteredDocuments[index];
                  var groupName = doc.id;
                  return FutureBuilder<Map<String, dynamic>>(
                    future: fetchGroupData(groupName),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      }
                      var groupData = snapshot.data!;
                      String imageUrl = groupData['thumbnail'] ?? '';
                      String defaultImageUrl =
                          'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';
                      bool hasArma = groupData['arma'] == true;
                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 4.0,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8.0),
                          leading: imageUrl.isNotEmpty
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(imageUrl),
                                  backgroundColor: Colors.transparent,
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(defaultImageUrl),
                                  backgroundColor: Colors.transparent,
                                ),
                          title: Text(
                            '${reverseFormatDocumentID(doc.id)} - ${groupData['title']}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle:
                              widget.paradeCollection.id == 'sunday_parade'
                                  ? Text('Άρμα: ${hasArma ? 'Ναι' : 'Όχι'}')
                                  : null,
                          trailing: Text(
                            calculateWaitingTime(doc, index, filteredDocuments,
                                lastStarted!, hasArma),
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                        ),
                      );
                    },
                  );
                },
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
      return 'ξεκινάει τώρα';
    } else {
      _fetchCurrentMembers();

      for (var i = 0; i < index; i++) {
        var d = docs[i];
        int memberCount = d['member_count'].toInt();
        if (d['started'] == false) {
          waitingTimeInSeconds +=
              ((((memberCount + currentMembers) / 10).ceil() * 30) + gotArma);
        }
      }
    }

    DateTime estimatedStartTime =
        lastStarted.add(Duration(seconds: waitingTimeInSeconds));
    Duration difference = estimatedStartTime.difference(DateTime.now());

    if (difference.isNegative) {
      return 'Επόμενο..';
    } else {
      return '${difference.inMinutes} λεπτά ';
    }
  }

  Future<Map<String, dynamic>> fetchGroupData(String groupName) async {
    var groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .get();
    if (groupDoc.exists) {
      return groupDoc.data()!;
    } else {
      return {'title': 'Άγνωστο', 'thumbnail': null, 'arma': false};
    }
  }
}

class StartedParadeTabView extends StatelessWidget {
  final CollectionReference paradeCollection;

  StartedParadeTabView({required this.paradeCollection});

  Future<Map<String, dynamic>> fetchGroupData(String groupName) async {
    var groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .get();
    if (groupDoc.exists) {
      return groupDoc.data()!;
    } else {
      return {'title': 'Άγνωστο', 'thumbnail': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: paradeCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }

        var documents = snapshot.data!.docs;
        var filteredDocuments = documents
            .where((doc) => doc.id != 'settings' && doc['started'] == true)
            .toList()
          ..sort((a, b) => a['queue'].compareTo(b['queue']));

        return ListView.builder(
          itemCount: filteredDocuments.length,
          itemBuilder: (context, index) {
            var doc = filteredDocuments[index];
            var groupName = doc.id;
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchGroupData(groupName),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  );
                }
                var groupData = snapshot.data!;
                String imageUrl = groupData['thumbnail'] ?? '';
                String defaultImageUrl =
                    'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';
                String statusText =
                    doc['completed'] == true ? 'Τερμάτησε' : 'Παρελαύνει...';
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: imageUrl.isNotEmpty
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(imageUrl),
                            backgroundColor: Colors.transparent,
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(defaultImageUrl),
                            backgroundColor: Colors.transparent,
                          ),
                    title: Text(
                      '${reverseFormatDocumentID(doc.id)} - ${groupData['title']}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    subtitle: Text(
                      statusText,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
