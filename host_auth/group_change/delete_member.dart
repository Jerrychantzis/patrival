// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, use_build_context_synchronously, prefer_const_constructors, use_super_parameters, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/toast.dart';
import '../group_edit.dart';
import 'package:carnival_app1/global/common/format_id.dart';
import 'package:carnival_app1/features/captain_auth/captain_group_list.dart';

class DeleteMember extends StatefulWidget {
  final String groupId;
  final bool isAdmin;

  const DeleteMember({Key? key, required this.groupId, required this.isAdmin}) : super(key: key);

  @override
  _DeleteMemberState createState() => _DeleteMemberState();
}

class _DeleteMemberState extends State<DeleteMember> {
  List<String> selectedUsers = [];
  late CollectionReference usersCollection;
  late DocumentReference groupRef;
  late int currentMemberCount;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    usersCollection = FirebaseFirestore.instance.collection('users');
    groupRef = FirebaseFirestore.instance.collection('groups').doc(formatDocumentID(widget.groupId));
    _fetchCurrentMemberCount();
  }

  void _fetchCurrentMemberCount() async {
    try {
      DocumentSnapshot groupSnapshot = await groupRef.get();
      if (groupSnapshot.exists) {
        setState(() {
          currentMemberCount = groupSnapshot['member_count'] as int;
        });
      }
    } catch (e) {
      print('Error fetching group data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Διαγραφή Χρηστών'),
        backgroundColor: Colors.lightBlue[100],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersCollection
            .where('group', isEqualTo: int.parse(widget.groupId))
            .where('captain', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Σφάλμα: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: Text('Επιλογή Όλων'),
                value: selectAll,
                onChanged: (checked) {
                  setState(() {
                    selectAll = checked!;
                    if (selectAll) {
                      selectedUsers = documents.map((doc) => doc['username'] as String).toList();
                    } else {
                      selectedUsers.clear();
                    }
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    String username = documents[index]['username'] as String;
                    return CheckboxListTile(
                      title: Text(username),
                      value: selectedUsers.contains(username),
                      onChanged: (checked) {
                        setState(() {
                          if (checked!) {
                            selectedUsers.add(username);
                          } else {
                            selectedUsers.remove(username);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              if (selectedUsers.isNotEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _removeUsersFromGroup();
                    },
                    child: Text('Τελική Διαγραφή'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _removeUsersFromGroup() async {
    List<String> selectedUserIds = [];

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String username in selectedUsers) {
        DocumentSnapshot userSnapshot = await usersCollection.doc(username).get();
        if (userSnapshot.exists) {
          Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
          List<String> tags = List<String>.from(userData['tags'] ?? []);
          tags = tags.map((tag) => tag == widget.groupId ? '0' : tag).toList();
          batch.update(usersCollection.doc(username), {
            'group': 0,
            'tags': tags,
          });
          selectedUserIds.add(username);
        }
      }

      batch.update(
        groupRef,
        {
          'member_count': FieldValue.increment(-selectedUserIds.length),
        },
      );

      await batch.commit();

      showToastGood(message: 'Επιτυχής Διαγραφή Χρηστών');
      if (widget.isAdmin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => GroupsEdit(),
          ),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => CaptainGroupsList(),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      print('Σφάλμα κατά την ενημέρωση της βάσης δεδομένων: $e');
      showToast(message: 'Κάτι πήγε λάθος! Δοκιμάστε ξανά.');
    }
  }
}
