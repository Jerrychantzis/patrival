// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print, prefer_is_empty, prefer_typing_uninitialized_variables

import 'package:carnival_app1/features/host_auth/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../global/common/toast.dart';

class AdminList extends StatefulWidget {
  @override
  _AdminListState createState() => _AdminListState();
}

class _AdminListState extends State<AdminList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentSnapshot> _users = [];
  bool _isAddingAdmin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getUsers();
  }

  Future<void> _getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    setState(() {

      _users = snapshot.docs.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['group'] != -1;
      }).toList();
    });
  }

  Future<List<DocumentSnapshot>> _getAdmins() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('admin', isEqualTo: true)
        .get();
    return snapshot.docs;
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  Future<void> _addAdmin(String userId) async {

    bool? confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Επιβεβαίωση Προσθήκης'),
          content: Text(
              'Θέλετε σίγουρα να προσθέσετε τον χρήστη ως διαχειριστή; Ο χρήστης που επιλέξατε θα έχει πρόσβαση σε κομμάτια της εφαρμογής με τη δυνατότητα να επηρρεάζει την εξέλιξη της παρέλασης και της δομής της εφαρμογής!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Ακύρωση'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Επιβεβαίωση'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        var currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception("Δεν βρέθηκε ο χρήστης που προσθέτει τον διαχειριστή.");
        }

        String currentEmail = currentUser.email ?? '';

        QuerySnapshot adminQuerySnapshot = await _firestore.collection('users')
            .where('email', isEqualTo: currentEmail)
            .get();

        if (adminQuerySnapshot.docs.isEmpty) {
          throw Exception("Δεν βρέθηκε ο χρήστης με το email: $currentEmail.");
        }

        DocumentSnapshot adminSnapshot = adminQuerySnapshot.docs.first;

        var adminData = adminSnapshot.data() as Map<String, dynamic>?;
        var adminLiveStream = adminData?['live_stream'];

        await _firestore.collection('users').doc(userId).update({
          'admin': true,
          'captain': false,
          'group': -1,
          'live_stream': adminLiveStream,
          'tags': FieldValue.delete(),
        });

        setState(() {
          _isLoading = false;
        });

        showToastGood(message:"Επιτυχής προσθήκη νέου διαχειριστή!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Σφάλμα κατά την προσθήκη του διαχειριστή: $e');
        showToast(message: 'Προέκυψε σφάλμα κατά την προσθήκη του διαχειριστή');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> filteredUsers = _users.where((userDoc) {
      var user = userDoc.data() as Map<String, dynamic>;
      var username = user['username']?.toLowerCase() ?? '';
      var email = user['email']?.toLowerCase() ?? '';
      return username.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isAddingAdmin ? 'Προσθήκη Διαχειριστών' : 'Λίστα Διαχειριστών',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Expanded(
            child: _isAddingAdmin
                ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Αναζήτηση χρηστών...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    style: TextStyle(
                        color: Colors.black, fontSize: 18.0),
                    onChanged: _updateSearchQuery,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var user = filteredUsers[index].data()
                      as Map<String, dynamic>;
                      var userId = filteredUsers[index].id;
                      var isCaptain = user['captain'] == true;
                      var group = user['group'] ?? 'Χωρίς Group';

                      return Card(
                        elevation: 4.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            user['username'] ?? 'Χωρίς Όνομα',
                            style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              Text(
                                user['email'] ?? 'Χωρίς Email',
                                style:
                                TextStyle(color: Colors.black),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Group: $group',
                                style:
                                TextStyle(color: Colors.grey),
                              ),
                              if (isCaptain)
                                Text(
                                  'Αρχηγός',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _addAdmin(userId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Προσθήκη'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
                : FutureBuilder<List<DocumentSnapshot>>(
              future: _getAdmins(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Προέκυψε σφάλμα'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('Δεν βρέθηκαν διαχειριστές'));
                }

                final admins = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    var admin = admins[index].data()
                    as Map<String, dynamic>;
                    var group = admin['group'] ?? 'Χωρίς Group';

                    return Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Text(
                            admin['username'] ?? 'Χωρίς Όνομα',
                            style: TextStyle(color: Colors.teal)),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(admin['email'] ?? 'Χωρίς Email',
                                style:
                                TextStyle(color: Colors.black)),
                            SizedBox(height: 8.0),
                            Text('Group: $group',
                                style:
                                TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isAddingAdmin = !_isAddingAdmin;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: Text(_isAddingAdmin
                  ? 'Επιστροφή στη λίστα διαχειριστών'
                  : 'Προσθήκη Διαχειριστών'),
            ),
          ),
        ],
      ),
    );
  }
}
