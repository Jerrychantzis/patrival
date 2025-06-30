// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_super_parameters, avoid_print, use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/toast.dart';
import 'group_captain_edit.dart';
import 'package:carnival_app1/global/common/format_id.dart';

class AddExistingMember extends StatefulWidget {
  final String documentID;

  const AddExistingMember({Key? key, required this.documentID})
      : super(key: key);

  @override
  _AddExistingMemberState createState() => _AddExistingMemberState();
}

class _AddExistingMemberState extends State<AddExistingMember> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  Map<String, dynamic>? _selectedUser;
  TextEditingController _searchController = TextEditingController();
  String? _previousCaptainEmail;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
    _fetchPreviousCaptainEmail();
  }

  Future<void> _fetchPreviousCaptainEmail() async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(formatDocumentID(widget.documentID))
          .get();

      setState(() {
        _previousCaptainEmail = groupDoc['captain_email'];
      });
    } catch (e) {
      print('Error fetching previous captain email: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('captain', isEqualTo: false)
          .get();

      List<QueryDocumentSnapshot> allUsers = querySnapshot.docs;

      List<Map<String, dynamic>> filteredUsers = [];

      for (var user in allUsers) {
        Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
        int group = int.tryParse(widget.documentID) ?? 0;
        if (userData['group'] == 0 || userData['group'] == group) {
          filteredUsers.add({
            'id': user.id,
            ...userData,
          });
        }
      }

      return filteredUsers;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _searchUsers(
      List<Map<String, dynamic>> users, String query) {
    query = query.toLowerCase();
    return users
        .where(
            (user) => user['username'].toString().toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Προσθήκη Υπάρχοντος Χρήστη'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Αναζήτηση χρήστη...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Σφάλμα κατά την φόρτωση των χρηστών'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Δεν βρέθηκαν χρήστες'));
                } else {
                  List<Map<String, dynamic>> users = snapshot.data!;
                  if (_searchController.text.isNotEmpty) {
                    users = _searchUsers(users, _searchController.text);
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> user = users[index];
                      String groupInfo = user['group'] == 0
                          ? 'Χωρίς group ακόμα'
                          : 'group: ${user['group'].toString()}';
                      return ListTile(
                        title: Text(user['username'] ?? 'No Name'),
                        subtitle:
                        Text('${user['email'] ?? 'No Email'}\n$groupInfo'),
                        selected: _selectedUser?['id'] == user['id'],
                        onTap: () {
                          setState(() {
                            _selectedUser = user;
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedUser != null ? _confirmNewCaptain : null,
              child: Text('Προσθήκη νέου αρχηγού'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmNewCaptain() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Επιβεβαίωση'),
          content: Text(
            'Θέλετε να ορίσετε σαν αρχηγό του group ${widget.documentID} τον χρήστη ${_selectedUser?['username']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedUser = null;
                });
              },
              child: Text('Όχι'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setNewCaptain();
              },
              child: Text('Ναι'),
            ),
          ],
        );
      },
    );
  }

  void _setNewCaptain() async {
    try {
      String formattedDocID = formatDocumentID(widget.documentID);
      String newCaptainName = _selectedUser?['username'];
      String newCaptainEmail = _selectedUser?['email'];
      int groupNumber = int.parse(widget.documentID);

      // Ενημέρωση του document του group με τα νέα στοιχεία του αρχηγού
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(formattedDocID)
          .update({
        'captain': newCaptainName,
        'captain_email': newCaptainEmail,
      });

      if (_selectedUser?['group'] == 0) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedUser?['id'])
            .update({
          'tags': FieldValue.arrayUnion([groupNumber.toString()]),
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_selectedUser?['id'])
            .update({
          'tags': FieldValue.arrayRemove(['0']),
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_selectedUser?['id'])
          .update({
        'captain': true,
        'group': groupNumber,
        'tags': FieldValue.arrayUnion(['captains']),
      });

      if (_previousCaptainEmail != null && _previousCaptainEmail!.isNotEmpty) {
        QuerySnapshot oldCaptainSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _previousCaptainEmail)
            .limit(1)
            .get();

        if (oldCaptainSnapshot.docs.isNotEmpty) {
          DocumentSnapshot oldCaptainDoc = oldCaptainSnapshot.docs.first;
          await oldCaptainDoc.reference.update({
            'captain': false,
            'tags': FieldValue.arrayRemove(['captains'])
          });
        }
      }

      // Εμφάνιση ειδοποίησης για επιτυχή προσθήκη
      showToastGood(message: "Ο νέος αρχηγός προστέθηκε επιτυχώς");

      // Πλοήγηση στην οθόνη επεξεργασίας των στοιχείων του νέου αρχηγού
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => EditCaptainInfoPage(
            groupDetails: {
              'captain': newCaptainName,
              'captain_email': newCaptainEmail,
              'captain_tel': _selectedUser?['phone'],
            },
            documentID: widget.documentID,
            isAdmin: true,
          ),
        ),
            (route) => false,
      );
    } catch (e) {
      print('Error setting new captain: $e');
      showToast(message: "Υπήρξε πρόβλημα κατά την προσθήκη του νέου αρχηγού");
    }
  }
}
