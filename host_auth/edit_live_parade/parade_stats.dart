// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, unnecessary_string_interpolations, unnecessary_null_in_if_null_operators, unnecessary_to_list_in_spreads, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ParadeStats extends StatefulWidget {
  @override
  _ParadeStatsState createState() => _ParadeStatsState();
}

class _ParadeStatsState extends State<ParadeStats> {
  String? selectedParade;
  CollectionReference? paradeCollection;
  bool isLoading = false;
  bool paradeCompleted = false;
  bool paradeStarted = false;
  DateTime? paradeDay;
  Timestamp? startedAt;
  Timestamp? finishedAt;
  List<QueryDocumentSnapshot> groups = [];
  Duration? paradeDuration;

  void selectParade(String parade) async {
    setState(() {
      isLoading = true;
      selectedParade = parade;
    });

    paradeCollection = FirebaseFirestore.instance.collection(parade);
    await fetchParadeStatus();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchParadeStatus() async {
    if (paradeCollection != null) {
      var settingsDoc = await paradeCollection!.doc('settings').get();
      if (settingsDoc.exists) {
        setState(() {
          paradeCompleted = settingsDoc['completed'] ?? false;
          paradeStarted = settingsDoc['started'] ?? false;
          paradeDay = settingsDoc['day']?.toDate();
          startedAt = settingsDoc['started_at'];
          finishedAt = settingsDoc['finished_at'];

          if (startedAt != null && finishedAt != null) {
            paradeDuration =
                finishedAt!.toDate().difference(startedAt!.toDate());
          }
        });

        if (paradeCompleted && paradeStarted) {
          await fetchGroupStats();
        }
      }
    }
  }

  Future<void> fetchGroupStats() async {
    if (paradeCollection != null) {
      var snapshot = await paradeCollection!.orderBy('queue').get();
      setState(() {
        groups = snapshot.docs;
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Στατιστικά Παρέλασης'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
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
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.blue,
                        child: Text(
                          'Επιλογή Παρέλασης',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedParade != null) SizedBox(height: 20),
                if (selectedParade != null)
                  Text(
                    selectedParade == 'saturday_parade'
                        ? 'Στατιστικά για την Παρέλαση Σαββάτου'
                        : 'Στατιστικά για την Παρέλαση Κυριακής',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                if (selectedParade != null &&
                    (!paradeStarted || !paradeCompleted)) ...[
                  SizedBox(height: 20),
                  Text(
                    'Η παρέλαση δεν έχει ξεκινήσει ή δεν έχει τελειώσει ακόμα',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
                if (selectedParade != null &&
                    paradeStarted &&
                    paradeCompleted) ...[
                  if (paradeDay != null) SizedBox(height: 20),
                  if (paradeDay != null)
                    Text(
                      'Ημέρα διεξαγωγής Παρέλασης: ${paradeDay?.day ?? ''}/${paradeDay?.month ?? ''}/${paradeDay?.year ?? ''}',
                      style: TextStyle(fontSize: 18),
                    ),
                  if (startedAt != null) SizedBox(height: 10),
                  if (startedAt != null)
                    Text(
                      'Εκκίνηση Παρέλασης: ${formatTimeOfDay(TimeOfDay.fromDateTime(startedAt!.toDate()))}',
                      style: TextStyle(fontSize: 18),
                    ),
                  if (finishedAt != null) SizedBox(height: 10),
                  if (finishedAt != null)
                    Text(
                      'Λήξη Παρέλασης: ${formatTimeOfDay(TimeOfDay.fromDateTime(finishedAt!.toDate()))}',
                      style: TextStyle(fontSize: 18),
                    ),
                  if (paradeDuration != null) SizedBox(height: 10),
                  if (paradeDuration != null)
                    Text(
                      'Διάρκεια Παρέλασης: ${paradeDuration?.inHours ?? 0} ώρες, ${paradeDuration?.inMinutes.remainder(60) ?? 0} λεπτά',
                      style: TextStyle(fontSize: 18),
                    ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        final data = group.data() as Map<String, dynamic>;
                        final groupStartedAt =
                            (data['started_at'] as Timestamp?)?.toDate();
                        final groupFinishedAt =
                            (data['finished_at'] as Timestamp?)?.toDate();
                        final memberCount = data['member_count'] ?? 'Αγνώστων';
                        final hasArma = data['arma'] ?? null;

                        final groupDuration =
                            groupStartedAt != null && groupFinishedAt != null
                                ? groupFinishedAt.difference(groupStartedAt)
                                : null;

                        return Card(
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group ${group.id}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ξεκίνησε: ${groupStartedAt != null ? formatTimeOfDay(TimeOfDay.fromDateTime(groupStartedAt)) : 'Δεν διατίθεται'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Τερμάτισε: ${groupFinishedAt != null ? formatTimeOfDay(TimeOfDay.fromDateTime(groupFinishedAt)) : 'Δεν διατίθεται'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Διάρκεια: ${groupDuration != null ? '${groupDuration.inHours} ώρες, ${groupDuration.inMinutes.remainder(60)} λεπτά' : 'Δεν διατίθεται'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Μέλη group: $memberCount',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Άρμα: ${hasArma == null ? 'Δεν διατίθεται για την παρέλαση' : hasArma ? 'Ναι' : 'Όχι'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
