// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, unnecessary_string_interpolations, library_private_types_in_public_api, prefer_const_declarations, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../global/common/format_id.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<QueryDocumentSnapshot>> _futureNotifications;
  String? _currentGroupTag;

  @override
  void initState() {
    super.initState();
    _futureNotifications = _fetchUserTagsAndNotifications();
  }

  Future<List<QueryDocumentSnapshot>> _fetchUserTagsAndNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    final userEmail = user.email;
    if (userEmail == null) {
      return [];
    }
    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();
    if (userQuerySnapshot.docs.isEmpty) {
      return [];
    }
    final userSnapshot = userQuerySnapshot.docs.first;
    final List<dynamic> userTags = userSnapshot.data()['tags'] ?? [];
    final userTag = userTags.firstWhere(
      (tag) => tag != '0',
      orElse: () => null,
    );
    if (userTag != null) {
      if (mounted) {
        setState(() {
          _currentGroupTag = userTag;
        });
      }
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(formatDocumentID(userTag))
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();
      return groupSnapshot.docs;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ειδοποιήσεις'),
          foregroundColor: Colors.white,
          backgroundColor: Colors.purple,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Όλες οι Ειδοποιήσεις'),
              if (_currentGroupTag == null)
                Tab(text: 'Χωρίς Group')
              else
                Tab(text: 'Group $_currentGroupTag'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAllNotificationsTab(),
            _buildGroupNotificationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNotificationsTab() {
    return Container(
      color: Colors.purpleAccent,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('all_notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Δεν υπάρχουν ειδοποιήσεις ακόμα.'));
          }

          return ListView(
            padding: EdgeInsets.all(12.0),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return _buildNotificationCard(data);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildGroupNotificationsTab() {
    return Container(
      color: Colors.purpleAccent,
      child: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα: ${snapshot.error}'));
          }

          if (_currentGroupTag == null ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
                child: Text('Δεν υπάρχουν ειδοποιήσεις για το group.'));
          }

          return ListView(
            padding: EdgeInsets.all(12.0),
            children: snapshot.data!.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return _buildNotificationCard(data);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.blue[50],
      elevation: 3.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.notifications, color: Colors.blue),
        title: Text(
          data['title'] ?? 'Χωρίς τίτλο',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          _formatTimestamp(data['timestamp']),
          style: TextStyle(fontSize: 12.0, color: Colors.grey),
        ),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              data['body'] ?? 'Χωρίς περιεχόμενο',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    String formattedTime =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$formattedDate - $formattedTime';
  }
}
