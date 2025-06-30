// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class GuestLiveView extends StatefulWidget {
  @override
  _GuestLiveViewState createState() => _GuestLiveViewState();
}

class _GuestLiveViewState extends State<GuestLiveView> {
  DateTime? saturdayParadeDay;
  DateTime? sundayParadeDay;

  @override
  void initState() {
    super.initState();
    fetchParadeDays();
  }

  Future<void> fetchParadeDays() async {
    try {
      var saturdayDoc = await FirebaseFirestore.instance.collection('saturday_parade').doc('settings').get();
      var sundayDoc = await FirebaseFirestore.instance.collection('sunday_parade').doc('settings').get();

      setState(() {
        if (saturdayDoc.exists) {
          saturdayParadeDay = saturdayDoc['day']?.toDate();
        }
        if (sundayDoc.exists) {
          sundayParadeDay = sundayDoc['day']?.toDate();
        }
      });
    } catch (e) {
      print('Error fetching parade days: $e');
    }
  }

  Future<void> watchParade() async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc('admin').get();
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
        title: Text('Ζωντανές Παρελάσεις'),
      ),
      backgroundColor: Colors.tealAccent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (saturdayParadeDay != null) ...[
              Card(
                elevation: 4.0,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    'Παρέλαση Σαββάτου:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${saturdayParadeDay!.day}/${saturdayParadeDay!.month}/${saturdayParadeDay!.year} ${saturdayParadeDay!.hour}:${saturdayParadeDay!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
            if (sundayParadeDay != null) ...[
              Card(
                elevation: 4.0,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    'Παρέλαση Κυριακής:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${sundayParadeDay!.day}/${sundayParadeDay!.month}/${sundayParadeDay!.year} ${sundayParadeDay!.hour}:${sundayParadeDay!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: watchParade,
              child: Text('Παρακολούθηση Παρέλασης'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Background color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
