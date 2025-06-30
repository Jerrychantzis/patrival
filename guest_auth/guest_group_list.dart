// ignore_for_file: prefer_const_constructors, use_super_parameters, avoid_print, sort_child_properties_last, unnecessary_cast

import 'package:carnival_app1/features/guest_auth/guest_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carnival_app1/global/common/format_id.dart';


class GuestGroupsList extends StatefulWidget {
  const GuestGroupsList({Key? key}) : super(key: key);

  @override
  State<GuestGroupsList> createState() => _GuestGroupsListState();
}

class _GuestGroupsListState extends State<GuestGroupsList> {
  String _searchQuery = '';

  void updateSearchQuery(String value) {
    setState(() {
      _searchQuery = reverseFormatDocumentID(value);
    });
  }

  void _onGroupTapped(String groupId, DocumentSnapshot groupSnapshot) {
    if (groupSnapshot.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GuestDetailsPage(
            groupDetails: groupSnapshot.data()! as Map<String, dynamic>,
            documentID: reverseFormatDocumentID(groupId),
          ),
        ),
      );
    } else {
      print('Το συγκεκριμένο έγγραφο δεν υπάρχει.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const String noImageSelect =
        'https://firebasestorage.googleapis.com/v0/b/carnivaldatabase-1f814.appspot.com/o/def_icons%2Fno_image.jpg?alt=media&token=90c83f0b-35ce-455d-aa27-15e7e3f4daf9';

    return Scaffold(
      appBar: AppBar(
        title: Text('Λίστα Γκρουπ'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.lightBlue,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Αναζήτηση αριθμού ή τίτλου γκρουπ',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                fillColor: Colors.lightGreenAccent,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
              FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No data available'),
                  );
                }
                var groups = snapshot.data!.docs;
                List<DocumentSnapshot> filteredGroups = [];
                if (_searchQuery.isNotEmpty) {
                  filteredGroups = groups.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    var documentID = reverseFormatDocumentID(doc.id).toLowerCase();
                    var groupTitle = (data['title'] ?? '').toLowerCase();
                    return documentID.contains(_searchQuery) ||
                        groupTitle.contains(_searchQuery);
                  }).toList();
                } else {
                  filteredGroups = List.from(groups);
                }
                if (filteredGroups.isEmpty) {
                  return Center(
                    child: Text('Δεν βρέθηκαν αποτελέσματα'),
                  );
                }
                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    var documentID = reverseFormatDocumentID(filteredGroups[index].id);
                    var groupData = filteredGroups[index].data()! as Map<String, dynamic>;
                    var groupTitle = groupData['title'] ?? 'No Title';
                    var thumbnail = groupData['thumbnail']?.isNotEmpty == true
                        ? groupData['thumbnail']
                        : noImageSelect;

                    return InkWell(
                      onTap: () =>
                          _onGroupTapped(documentID, filteredGroups[index]),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(28.0),
                          color: Colors.lightGreenAccent,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Group $documentID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('"$groupTitle"'),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(38.0),
                              child: Image.network(
                                thumbnail,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
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
