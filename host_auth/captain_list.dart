// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, unused_element

import 'package:carnival_app1/global/common/format_id.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../host_auth/notifications/notifications_to_captains.dart';
import 'notifications/captain_message_history.dart';
import 'admin_list.dart';

class CaptainList extends StatefulWidget {
  @override
  _CaptainListState createState() => _CaptainListState();
}

class _CaptainListState extends State<CaptainList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  List<DocumentSnapshot> _captains = [];

  void _startSearch() {
    ModalRoute.of(context)!.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  Future<String> _getGroupTitle(String groupId) async {
    DocumentSnapshot groupDoc = await _firestore.collection('groups').doc(formatDocumentID(groupId)).get();
    if (groupDoc.exists) {
      var data = groupDoc.data() as Map<String, dynamic>;
      return data['title'] ?? 'Χωρίς Τίτλο';
    } else {
      return 'Χωρίς Τίτλο';
    }
  }

  Future<List<DocumentSnapshot>> _getCaptains() async {
    // Λήψη των εγγράφων από το collection 'groups'
    QuerySnapshot snapshot = await _firestore.collection('groups').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> _filterCaptains(List<DocumentSnapshot> groups) async {
    List<DocumentSnapshot> filteredGroups = [];
    for (var groupDoc in groups) {
      var group = groupDoc.data() as Map<String, dynamic>;
      var captain = group['captain'] ?? '';
      var captainEmail = group['captain_email'] ?? '';
      var groupNumber = reverseFormatDocumentID(groupDoc.id);
      var groupTitle = group['title'] ?? '';


      if (captain.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          captainEmail.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          groupNumber.contains(_searchQuery) ||
          groupTitle.toLowerCase().contains(_searchQuery.toLowerCase())) {
        filteredGroups.add(groupDoc);
      }
    }
    return filteredGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Αναζήτηση...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          onChanged: _updateSearchQuery,
        )
            : Text('Λίστα Αρχηγών & Διαχειριστών', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          _isSearching
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }
              _clearSearchQuery();
            },
          )
              : IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _startSearch,
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsToCaptains()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Αποστολή Ειδοποιήσεων στους Αρχηγούς'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CaptainMessageHistory()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Ιστορικό Μηνυμάτων Αρχηγών'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminList()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text('Διαχειριστές'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _getCaptains(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Προέκυψε σφάλμα'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Δεν βρέθηκαν αρχηγοί'));
                }

                _captains = snapshot.data!;

                return FutureBuilder<List<DocumentSnapshot>>(
                  future: _filterCaptains(_captains),
                  builder: (context, filteredSnapshot) {
                    if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (filteredSnapshot.hasError) {
                      return Center(child: Text('Προέκυψε σφάλμα'));
                    }
                    if (!filteredSnapshot.hasData || filteredSnapshot.data!.isEmpty) {
                      return Center(child: Text('Δεν βρέθηκαν αρχηγοί'));
                    }

                    final filteredCaptains = filteredSnapshot.data!;

                    return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: filteredCaptains.length,
                      itemBuilder: (context, index) {
                        var group = filteredCaptains[index].data() as Map<String, dynamic>;
                        var captain = group['captain'] ?? 'Χωρίς Όνομα';
                        var captainEmail = group['captain_email'] ?? 'Χωρίς Email';
                        var groupNumber = reverseFormatDocumentID(filteredCaptains[index].id);
                        var groupTitle = group['title'] ?? 'Χωρίς Τίτλο';

                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(
                              captain,
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
                                  captainEmail,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Group: $groupNumber - $groupTitle',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
